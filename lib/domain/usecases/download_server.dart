import '../repositories/minecraft_server_repository.dart';
import '../../core/constants/server_version.dart';

class DownloadServerUseCase {
  final MinecraftServerRepository repository;

  DownloadServerUseCase(this.repository);

  Stream<double> call(ServerVersion version, String destinationPath) {
    return repository.downloadServer(version, destinationPath);
  }

  Future<bool> serverExists(String serverPath, String jarName) {
    return repository.serverJarExists(serverPath, jarName);
  }

  Future<List<String>> getAvailablePaperVersions({String minVersion = '1.8.9'}) {
    return repository.getAvailablePaperVersions(minVersion: minVersion);
  }

  Future<List<int>> getPaperBuildsForVersion(String version) {
    return repository.getPaperBuildsForVersion(version);
  }
}