import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../api/paper_api_client.dart';
import '../constants/api_constants.dart';
import '../../domain/entities/paper_version.dart';
import '../../core/constants/server_version.dart';

class DownloadService {
  final Dio _dio = Dio();
  final PaperApiClient _paperApiClient = PaperApiClient();

  Stream<double> downloadProgressStream(String url, String savePath) async* {
    try {
      final controller = StreamController<double>();

      _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            controller.add(received / total);
          }
        },
      ).then((_) {
        controller.add(1.0);
        controller.close();
      }).catchError((e) {
        controller.add(-1);
        controller.close();
      });

      await for (final progress in controller.stream) {
        yield progress;
      }
    } catch (e) {
      yield -1;
    }
  }

  Future<bool> downloadSpigotJar(String version, String destinationPath) async {
    try {
      final url = ApiConstants.getSpigotUrlForVersion(version);
      final fileName = path.basename(url);
      final savePath = path.join(destinationPath, fileName);

      final directory = Directory(destinationPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final response = await _dio.download(url, savePath);
      return response.statusCode == 200;
    } catch (e) {
      print('Errore durante il download di Spigot: $e');
      return false;
    }
  }

  Future<bool> downloadPaperJar(String version, String destinationPath, {int? buildNumber}) async {
    try {
      PaperBuild build;

      if (buildNumber == null) {
        build = await _paperApiClient.getLatestBuild(version);
      } else {
        build = await _paperApiClient.getBuildInfo(version, buildNumber);
      }

      final download = build.downloads['application'];
      if (download == null) {
        throw Exception('Download not found for Paper version $version build ${build.build}');
      }

      final downloadUrl = _paperApiClient.getDownloadUrl(version, build.build, download.name);
      final savePath = path.join(destinationPath, 'paper-$version.jar');

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

  Stream<double> downloadServerVersion(ServerVersion serverVersion, String destinationPath) async* {
    try {
      final directory = Directory(destinationPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      switch (serverVersion.type) {
        case 'paper':
          PaperBuild build;

          if (serverVersion.build == null) {
            build = await _paperApiClient.getLatestBuild(serverVersion.version);
          } else {
            build = await _paperApiClient.getBuildInfo(serverVersion.version, int.parse(serverVersion.build!));
          }

          final download = build.downloads['application'];
          if (download == null) {
            throw Exception('Download not found for Paper version ${serverVersion.version} build ${build.build}');
          }

          final downloadUrl = _paperApiClient.getDownloadUrl(serverVersion.version, build.build, download.name);
          final savePath = path.join(destinationPath, serverVersion.getJarFileName());

          yield* downloadProgressStream(downloadUrl, savePath);
          break;

        case 'spigot':
          final url = ApiConstants.getSpigotUrlForVersion(serverVersion.version);
          final savePath = path.join(destinationPath, serverVersion.getJarFileName());

          yield* downloadProgressStream(url, savePath);
          break;

        case 'vanilla':
          yield -1;
          break;

        default:
          yield -1;
      }
    } catch (e) {
      print('Errore durante il download del server: $e');
      yield -1;
    }
  }

  Future<List<String>> getAvailablePaperVersions({String minVersion = '1.8.9'}) async {
    return await _paperApiClient.getVersionsNewerThan(minVersion);
  }

  Future<List<int>> getPaperBuildsForVersion(String version) async {
    return await _paperApiClient.getBuildsForVersion(version);
  }

  Future<bool> jarExists(String serverPath, String jarName) async {
    final file = File(path.join(serverPath, jarName));
    return await file.exists();
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}