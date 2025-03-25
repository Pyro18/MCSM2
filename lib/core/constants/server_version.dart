class ServerVersion {
  final String version;
  final String type;
  final String? build;

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

  static ServerVersion? fromJarFileName(String fileName) {
    final paperRegex = RegExp(r'paper-(\d+\.\d+(\.\d+)?)(\.jar)$');
    if (paperRegex.hasMatch(fileName)) {
      final match = paperRegex.firstMatch(fileName);
      final version = match?.group(1);
      if (version != null) {
        return ServerVersion.paper(version);
      }
    }

    final spigotRegex = RegExp(r'spigot-(\d+\.\d+(\.\d+)?)(\.jar)$');
    if (spigotRegex.hasMatch(fileName)) {
      final match = spigotRegex.firstMatch(fileName);
      final version = match?.group(1);
      if (version != null) {
        return ServerVersion.spigot(version);
      }
    }

    final vanillaRegex = RegExp(r'minecraft_server\.(\d+\.\d+(\.\d+)?)(\.jar)$');
    if (vanillaRegex.hasMatch(fileName)) {
      final match = vanillaRegex.firstMatch(fileName);
      final version = match?.group(1);
      if (version != null) {
        return ServerVersion.vanilla(version);
      }
    }

    return null;
  }
}