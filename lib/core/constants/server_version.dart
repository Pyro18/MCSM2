class ServerVersion {
  final String version;
  final String type; // 'spigot', 'paper', 'vanilla'
  final String? build; // Opzionale, solo per paper

  const ServerVersion({
    required this.version,
    required this.type,
    this.build,
  });

  factory ServerVersion.spigot(String version) {
    return ServerVersion(
      version: version,
      type: 'spigot',
    );
  }

  factory ServerVersion.paper(String version, {String? build}) {
    return ServerVersion(
      version: version,
      type: 'paper',
      build: build,
    );
  }

  factory ServerVersion.vanilla(String version) {
    return ServerVersion(
      version: version,
      type: 'vanilla',
    );
  }

  @override
  String toString() {
    switch (type) {
      case 'paper':
        return 'Paper $version${build != null ? " (Build $build)" : ""}';
      case 'spigot':
        return 'Spigot $version';
      case 'vanilla':
        return 'Vanilla $version';
      default:
        return '$type $version';
    }
  }

  // Nome del file JAR per questa versione
  String getJarFileName() {
    switch (type) {
      case 'paper':
        return 'paper-$version.jar';
      case 'spigot':
        return 'spigot-$version.jar';
      case 'vanilla':
        return 'minecraft_server.$version.jar';
      default:
        return '$type-$version.jar';
    }
  }
}