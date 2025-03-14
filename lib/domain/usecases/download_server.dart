import '../repositories/minecraft_server_repository.dart';
import '../../core/constants/server_version.dart';

class DownloadServerUseCase {
  final MinecraftServerRepository repository;

  DownloadServerUseCase(this.repository);

  // Scarica un server. Restituisce uno stream con il progresso del download.
  Stream<double> call(ServerVersion version, String destinationPath) {
    return repository.downloadServer(version, destinationPath);
  }

  // Verifica se un server esiste già
  Future<bool> serverExists(String serverPath, String jarName) {
    return repository.serverJarExists(serverPath, jarName);
  }
}