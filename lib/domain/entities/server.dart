import 'package:equatable/equatable.dart';

class Server extends Equatable {
  final String id;
  final String name;
  final String path;
  final int ramAllocation;
  final bool isRunning;
  final int port;
  final String version;

  const Server({
    required this.id,
    required this.name,
    required this.path,
    required this.ramAllocation,
    required this.isRunning,
    this.port = 25565,
    required this.version,
  });

  @override
  List<Object?> get props => [id, name, path, ramAllocation, isRunning, port, version];
}
