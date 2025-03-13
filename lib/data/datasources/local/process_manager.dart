import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ProcessManager {
  Process? _serverProcess;
  final StreamController<String> _outputController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  Stream<String> get outputStream => _outputController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isServerRunning => _serverProcess != null;

  Future<bool> startServer({
    required String javaPath,
    required String serverPath,
    required String jarName,
    required int ramAllocation,
  }) async {
    try {
      if (_serverProcess != null) {
        return false; // Server già in esecuzione
      }

      // Verifica se il percorso del server esiste
      final directory = Directory(serverPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Cerca il file JAR se non specificato
      String finalJarName = jarName;
      if (finalJarName.isEmpty) {
        final files = await directory.list().where((f) => f.path.endsWith('.jar')).toList();
        if (files.isEmpty) {
          _errorController.add('Nessun file .jar trovato nella directory del server');
          return false;
        }
        finalJarName = files.first.path.split(Platform.pathSeparator).last;
      }

      // Verifica EULA
      final eulaFile = File('$serverPath${Platform.pathSeparator}eula.txt');
      if (!await eulaFile.exists()) {
        // Esegui il server una volta per generare eula.txt
        final tempProcess = await Process.start(
          javaPath,
          ['-jar', finalJarName],
          workingDirectory: serverPath,
        );

        await for (final line in tempProcess.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
          _outputController.add(line);
          if (line.contains('You need to agree to the EULA in order to run the server')) {
            break;
          }
        }

        // Attendi che il file eula.txt venga creato
        await Future.delayed(const Duration(seconds: 2));
        tempProcess.kill();

        // Verifica nuovamente e accetta EULA
        if (await eulaFile.exists()) {
          final eulaContent = await eulaFile.readAsString();
          await eulaFile.writeAsString(eulaContent.replaceAll('eula=false', 'eula=true'));
          _outputController.add('EULA accettata automaticamente');
        } else {
          _errorController.add('Impossibile creare o trovare il file eula.txt');
          return false;
        }
      }

      // Avvia il server con l'allocazione RAM specificata
      _serverProcess = await Process.start(
        javaPath,
        [
          '-Xmx${ramAllocation}M',
          '-Xms${ramAllocation}M',
          '-jar',
          finalJarName,
          'nogui'
        ],
        workingDirectory: serverPath,
      );

      _outputController.add('Server avviato con allocazione RAM: ${ramAllocation}MB');

      // Gestisci l'output del server
      _serverProcess!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        _outputController.add(line);
      });

      _serverProcess!.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        _errorController.add(line);
      });

      // Gestisci la chiusura del processo
      _serverProcess!.exitCode.then((exitCode) {
        _outputController.add('Server terminato con codice: $exitCode');
        _serverProcess = null;
      });

      return true;
    } catch (e) {
      _errorController.add('Errore nell\'avvio del server: $e');
      return false;
    }
  }

  Future<bool> stopServer() async {
    try {
      if (_serverProcess == null) {
        return false; // Server non in esecuzione
      }

      // Invia comando stop al server
      sendCommand('stop');

      // Attendi che il processo termini
      bool terminated = false;
      final completer = Completer<bool>();

      // Timeout dopo 10 secondi
      Timer(const Duration(seconds: 10), () {
        if (!terminated && !completer.isCompleted) {
          _serverProcess?.kill();
          _outputController.add('Server terminato forzatamente');
          _serverProcess = null;
          completer.complete(true);
        }
      });

      // Attendi normalmente
      _serverProcess!.exitCode.then((exitCode) {
        terminated = true;
        if (!completer.isCompleted) {
          _outputController.add('Server terminato con codice: $exitCode');
          _serverProcess = null;
          completer.complete(true);
        }
      });

      return await completer.future;
    } catch (e) {
      _errorController.add('Errore nell\'arresto del server: $e');

      // In caso di errore, termina forzatamente
      _serverProcess?.kill();
      _serverProcess = null;

      return false;
    }
  }

  bool sendCommand(String command) {
    try {
      if (_serverProcess == null) {
        return false;
      }

      _serverProcess!.stdin.writeln(command);
      _outputController.add('> $command');
      return true;
    } catch (e) {
      _errorController.add('Errore nell\'invio del comando: $e');
      return false;
    }
  }

  void dispose() {
    if (_serverProcess != null) {
      stopServer();
    }
    _outputController.close();
    _errorController.close();
  }
}