import 'package:dio/dio.dart';
import '../../domain/entities/paper_version.dart';

/// Client per l'API di PaperMC
class PaperApiClient {
  final Dio _dio;
  static const String baseUrl = 'https://api.papermc.io/v2';

  PaperApiClient({Dio? dio}) : _dio = dio ?? Dio();

  /// Ottiene tutte le versioni disponibili per Paper
  Future<List<String>> getAvailableVersions() async {
    try {
      final response = await _dio.get('$baseUrl/projects/paper');
      final versions = List<String>.from(response.data['versions']);
      return versions;
    } catch (e) {
      throw Exception('Failed to load Paper versions: $e');
    }
  }

  /// Ottiene le build disponibili per una specifica versione
  Future<List<int>> getBuildsForVersion(String version) async {
    try {
      final response = await _dio.get('$baseUrl/projects/paper/versions/$version');
      final builds = List<int>.from(response.data['builds']);
      return builds;
    } catch (e) {
      throw Exception('Failed to load builds for version $version: $e');
    }
  }

  /// Ottiene informazioni dettagliate su una build specifica
  Future<PaperBuild> getBuildInfo(String version, int build) async {
    try {
      final response = await _dio.get('$baseUrl/projects/paper/versions/$version/builds/$build');
      return PaperBuild.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load build info for version $version, build $build: $e');
    }
  }

  /// Ottiene l'URL di download per una build specifica
  String getDownloadUrl(String version, int build, String fileName) {
    return '$baseUrl/projects/paper/versions/$version/builds/$build/downloads/$fileName';
  }

  /// Ottiene la build più recente per una versione
  Future<PaperBuild> getLatestBuild(String version) async {
    try {
      final builds = await getBuildsForVersion(version);
      if (builds.isEmpty) {
        throw Exception('No builds found for version $version');
      }

      final latestBuildNumber = builds.last; // Assumes builds are sorted
      return await getBuildInfo(version, latestBuildNumber);
    } catch (e) {
      throw Exception('Failed to get latest build for version $version: $e');
    }
  }

  /// Filtra le versioni per ottenere solo quelle più recenti di minVersion
  Future<List<String>> getVersionsNewerThan(String minVersion) async {
    try {
      final allVersions = await getAvailableVersions();

      // Filtra le versioni che sono maggiori o uguali a minVersion
      return allVersions.where((version) {
        return _compareVersions(version, minVersion) >= 0;
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter versions: $e');
    }
  }

  /// Compara due versioni semantiche
  /// Restituisce:
  /// - numero positivo se v1 > v2
  /// - 0 se v1 == v2
  /// - numero negativo se v1 < v2
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    // Aggiungi zeri per rendere le liste della stessa lunghezza
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }

    // Confronta ogni componente della versione
    for (int i = 0; i < v1Parts.length; i++) {
      final comp = v1Parts[i].compareTo(v2Parts[i]);
      if (comp != 0) {
        return comp;
      }
    }

    return 0; // Versioni identiche
  }
}