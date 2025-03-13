import '../../domain/entities/server.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/plugin.dart';

abstract class MinecraftServerRepository {
  Future<List<Server>> getServers();
  Future<Server?> getServerById(String id);
  Future<Server> addServer(Server server);
  Future<bool> updateServer(Server server);
  Future<bool> deleteServer(String id);

  Future<bool> startServer(String id);
  Future<bool> stopServer(String id);
  Future<bool> sendCommand(String id, String command);

  Stream<String> getServerOutput(String id);
  Stream<List<Player>> getOnlinePlayers(String id);
  Future<List<Plugin>> getInstalledPlugins(String id);
}