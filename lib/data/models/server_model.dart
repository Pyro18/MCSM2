import 'dart:convert';
import '../../domain/entities/server.dart';

class ServerModel extends Server {
  const ServerModel({
    required String id,
    required String name,
    required String path,
    required int ramAllocation,
    required bool isRunning,
    int port = 25565,
    required String version,
  }) : super(
    id: id,
    name: name,
    path: path,
    ramAllocation: ramAllocation,
    isRunning: isRunning,
    port: port,
    version: version,
  );

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      ramAllocation: json['ramAllocation'],
      isRunning: json['isRunning'],
      port: json['port'] ?? 25565,
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'ramAllocation': ramAllocation,
      'isRunning': isRunning,
      'port': port,
      'version': version,
    };
  }

  factory ServerModel.fromEntity(Server server) {
    return ServerModel(
      id: server.id,
      name: server.name,
      path: server.path,
      ramAllocation: server.ramAllocation,
      isRunning: server.isRunning,
      port: server.port,
      version: server.version,
    );
  }
}