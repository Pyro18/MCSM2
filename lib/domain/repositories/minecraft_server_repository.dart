import '../../domain/entities/server.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/plugin.dart';
import '../../core/constants/server_version.dart';

abstract class MinecraftServerRepository {
  // Gestione dei server
  Future<List<Server>> getServers();
  Future<Server?> getServerById(String id);
  Future<Server> addServer(Server server);
  Future<bool> updateServer(Server server);
  Future<bool> deleteServer(String id);

  // Controllo del server
  Future<bool> startServer(String id);
  Future<bool> stopServer(String id);
  Future<bool> sendCommand(String id, String command);

  // Streaming di dati dal server
  Stream<String> getServerOutput(String id);
  Stream<List<Player>> getOnlinePlayers(String id);

  // Plugin e mod
  Future<List<Plugin>> getInstalledPlugins(String id);

  // Download e gestione file
  Stream<double> downloadServer(ServerVersion version, String destinationPath);
  Future<bool> serverJarExists(String serverPath, String jarName);

  // Paper API
  Future<List<String>> getAvailablePaperVersions({String minVersion = '1.8.9'});
  Future<List<int>> getPaperBuildsForVersion(String version);
}