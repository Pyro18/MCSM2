import '../../domain/repositories/minecraft_server_repository.dart';

class StartServerUseCase {
  final MinecraftServerRepository repository;

  StartServerUseCase(this.repository);

  Future<bool> call(String serverId) {
    return repository.startServer(serverId);
  }
}