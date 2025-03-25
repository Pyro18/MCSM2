import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../domain/entities/server.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/plugin.dart';
import '../../domain/repositories/minecraft_server_repository.dart';
import '../datasources/local/process_manager.dart';
import '../datasources/local/preferences_datasource.dart';
import '../models/server_model.dart';
import '../models/player_model.dart';
import '../models/plugin_model.dart';
import '../../core/constants/server_version.dart';
import '../../core/services/download_service.dart';

class MinecraftServerRepositoryImpl implements MinecraftServerRepository {
  final PreferencesDatasource _preferences;
  final DownloadService _downloadService;
  final Map<String, ProcessManager> _serverProcesses = {};

  MinecraftServerRepositoryImpl(this._preferences)
      : _downloadService = DownloadService();

  @override
  Future<List<Server>> getServers() async {
    final serverJsonList = await _preferences.getServerList();
    return serverJsonList.map((json) => ServerModel.fromJson(json)).toList();
  }

  @override
  Future<Server?> getServerById(String id) async {
    final servers = await getServers();
    try {
      return servers.firstWhere((server) => server.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Server> addServer(Server server) async {
    final serverModel = ServerModel.fromEntity(server);
    final List<Map<String, dynamic>> servers = await _preferences.getServerList();
    servers.add(serverModel.toJson());
    await _preferences.saveServerList(servers);
    return serverModel;
  }

  @override
  Future<bool> updateServer(Server server) async {
    final serverModel = ServerModel.fromEntity(server);
    final List<Map<String, dynamic>> servers = await _preferences.getServerList();
    final index = servers.indexWhere((s) => s['id'] == server.id);

    if (index != -1) {
      servers[index] = serverModel.toJson();
      await _preferences.saveServerList(servers);
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteServer(String id) async {
    final List<Map<String, dynamic>> servers = await _preferences.getServerList();
    final initialLength = servers.length;
    servers.removeWhere((server) => server['id'] == id);

    if (servers.length != initialLength) {
      await _preferences.saveServerList(servers);

      // Ferma il processo se in esecuzione
      if (_serverProcesses.containsKey(id)) {
        await _serverProcesses[id]!.stopServer();
        _serverProcesses[id]!.dispose();
        _serverProcesses.remove(id);
      }

      return true;
    }
    return false;
  }

  @override
  Future<bool> startServer(String id) async {
    final server = await getServerById(id);
    if (server == null) return false;

    // Crea un nuovo process manager se non esiste
    if (!_serverProcesses.containsKey(id)) {
      _serverProcesses[id] = ProcessManager();
    }

    // Avvia il server
    final result = await _serverProcesses[id]!.startServer(
      javaPath: 'java', // Potrebbe essere recuperato dalle preferenze
      serverPath: server.path,
      jarName: '', // Lascia vuoto per trovare automaticamente il JAR
      ramAllocation: server.ramAllocation,
    );

    // Aggiorna lo stato del server
    if (result) {
      final updatedServer = ServerModel(
        id: server.id,
        name: server.name,
        path: server.path,
        ramAllocation: server.ramAllocation,
        isRunning: true,
        port: server.port,
        version: server.version,
      );
      await updateServer(updatedServer);
    }

    return result;
  }

  @override
  Future<bool> stopServer(String id) async {
    if (!_serverProcesses.containsKey(id)) return false;

    final result = await _serverProcesses[id]!.stopServer();

    // Aggiorna lo stato del server
    if (result) {
      final server = await getServerById(id);
      if (server != null) {
        final updatedServer = ServerModel(
          id: server.id,
          name: server.name,
          path: server.path,
          ramAllocation: server.ramAllocation,
          isRunning: false,
          port: server.port,
          version: server.version,
        );
        await updateServer(updatedServer);
      }
    }

    return result;
  }

  @override
  Future<bool> sendCommand(String id, String command) {
    if (!_serverProcesses.containsKey(id)) return Future.value(false);
    return Future.value(_serverProcesses[id]!.sendCommand(command));
  }

  @override
  Stream<String> getServerOutput(String id) {
    if (!_serverProcesses.containsKey(id)) {
      return Stream.empty();
    }
    return _serverProcesses[id]!.outputStream;
  }

  @override
  Stream<List<Player>> getOnlinePlayers(String id) {
    if (!_serverProcesses.containsKey(id)) {
      return Stream.value([]);
    }

    // Trasforma lo stream di output per estrarre i giocatori
    final playerStream = _serverProcesses[id]!.outputStream
        .where((line) => line.contains('joined the game') || line.contains('left the game'))
        .map((line) {
      // Estrai il nome del giocatore e l'azione (join/leave)
      // Logica semplificata, potrebbe richiedere regex più robuste
      final isJoining = line.contains('joined the game');
      final startIndex = line.indexOf(']') + 2;
      final endIndex = isJoining
          ? line.indexOf('joined') - 1
          : line.indexOf('left') - 1;

      if (startIndex >= 0 && endIndex > startIndex) {
        final playerName = line.substring(startIndex, endIndex).trim();
        return MapEntry<String, bool>(playerName, isJoining);
      }
      return null;
    })
        .where((entry) => entry != null);

    final playerListSubject = BehaviorSubject<List<String>>.seeded([]);

    playerStream.listen((entry) {
      if (entry != null) {
        final currentList = List<String>.from(playerListSubject.value);
        if (entry.value) {
          if (!currentList.contains(entry.key)) {
            currentList.add(entry.key);
          }
        } else {
          currentList.remove(entry.key);
        }
        playerListSubject.add(currentList);
      }
    });

    return playerListSubject.stream.map((playerNames) {
      return playerNames.map((name) => PlayerModel(
        id: name,
        name: name,
        isOnline: true,
      )).toList();
    });
  }

  @override
  Future<List<Plugin>> getInstalledPlugins(String id) async {
    final server = await getServerById(id);
    if (server == null) return [];

    try {
      final pluginsDir = Directory('${server.path}${Platform.pathSeparator}plugins');
      if (!await pluginsDir.exists()) return [];

      final pluginFiles = await pluginsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.jar'))
          .toList();

      return pluginFiles.map((file) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        final pluginName = fileName.replaceAll('.jar', '');

        return PluginModel(
          id: pluginName,
          name: pluginName,
          version: 'Unknown', // Sarebbe necessario estrarre dal plugin.yml
          isEnabled: true, // Assunzione semplificata
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<double> downloadServer(ServerVersion version, String destinationPath) {
    return _downloadService.downloadServerVersion(version, destinationPath);
  }

  @override
  Future<bool> serverJarExists(String serverPath, String jarName) {
    return _downloadService.jarExists(serverPath, jarName);
  }

  @override
  Future<List<String>> getAvailablePaperVersions({String minVersion = '1.8.9'}) {
    return _downloadService.getAvailablePaperVersions(minVersion: minVersion);
  }

  @override
  Future<List<int>> getPaperBuildsForVersion(String version) {
    return _downloadService.getPaperBuildsForVersion(version);
  }
}