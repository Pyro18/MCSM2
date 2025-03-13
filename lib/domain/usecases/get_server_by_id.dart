import '../entities/server.dart';
import '../repositories/minecraft_server_repository.dart';

class GetServerByIdUseCase {
  final MinecraftServerRepository repository;

  GetServerByIdUseCase(this.repository);

  Future<Server?> call(String serverId) {
    return repository.getServerById(serverId);
  }
}