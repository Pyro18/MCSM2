import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../constants/api_constants.dart';

class DownloadService {
  final Dio _dio = Dio();

  // Stream con il progresso del download
  Stream<double> downloadProgressStream(String url, String savePath) async* {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            yield received / total;
        }
        },
      );
      yield 1.0; // Completo
    } catch (e) {
      yield -1; // Errore
    }
  }

  // Download di un file Spigot
  Future<bool> downloadSpigotJar(String version, String destinationPath) async {
    try {
      final url = ApiConstants.getSpigotUrlForVersion(version);
      final fileName = path.basename(url);
      final savePath = path.join(destinationPath, fileName);

      // Crea la directory se non esiste
      final directory = Directory(destinationPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final response = await _dio.download(url, savePath);
      return response.statusCode == 200;
    } catch (e) {
      print('Errore durante il download: $e');
      return false;
    }
  }

  // Download di una versione di Paper (alternativa a Spigot)
  Future<bool> downloadPaperJar(String version, String build, String destinationPath) async {
    try {
      // Ottieni le build disponibili
      final buildsUrl = '${ApiConstants.paperBaseUrl}/versions/$version/builds';
      final buildsResponse = await _dio.get(buildsUrl);

      // Se non è specificato un build, usa l'ultimo
      String buildNumber = build;
      if (build.isEmpty) {
        final builds = buildsResponse.data['builds'] as List;
        buildNumber = builds.last['build'].toString();
      }

      // Effettua il download
      final downloadUrl = '${ApiConstants.paperBaseUrl}/versions/$version/builds/$buildNumber/downloads/paper-$version-$buildNumber.jar';
      final savePath = path.join(destinationPath, 'paper-$version.jar');

      // Crea la directory se non esiste
      final directory = Directory(destinationPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final response = await _dio.download(downloadUrl, savePath);
      return response.statusCode == 200;
    } catch (e) {
      print('Errore durante il download di Paper: $e');
      return false;
    }
  }

  // Verifica l'esistenza di un file JAR
  Future<bool> jarExists(String serverPath, String jarName) async {
    final file = File(path.join(serverPath, jarName));
    return await file.exists();
  }

  // Verifica la disponibilità della connessione Internet
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}