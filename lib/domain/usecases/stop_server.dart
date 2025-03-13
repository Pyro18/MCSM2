import '../repositories/minecraft_server_repository.dart';

class StopServerUseCase {
  final MinecraftServerRepository repository;

  StopServerUseCase(this.repository);

  Future<bool> call(String serverId) {
    return repository.stopServer(serverId);
  }
}