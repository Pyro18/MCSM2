import '../repositories/minecraft_server_repository.dart';

class SendCommandUseCase {
  final MinecraftServerRepository repository;

  SendCommandUseCase(this.repository);

  Future<bool> call(String serverId, String command) {
    return repository.sendCommand(serverId, command);
  }
}