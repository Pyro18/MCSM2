class ApiConstants {
  // URL per il download di Spigot
  static const String spigotBaseUrl = 'https://download.getbukkit.org/spigot';

  // URL per il download di Paper (alternativa a Spigot)
  static const String paperBaseUrl = 'https://api.papermc.io/v2/projects/paper';

  // Versioni più comuni di Minecraft
  static const Map<String, String> commonVersions = {
    '1.20.4': 'spigot-1.20.4.jar',
    '1.20.2': 'spigot-1.20.2.jar',
    '1.19.4': 'spigot-1.19.4.jar',
    '1.19.2': 'spigot-1.19.2.jar',
    '1.18.2': 'spigot-1.18.2.jar',
    '1.17.1': 'spigot-1.17.1.jar',
    '1.16.5': 'spigot-1.16.5.jar',
    '1.15.2': 'spigot-1.15.2.jar',
    '1.14.4': 'spigot-1.14.4.jar',
    '1.12.2': 'spigot-1.12.2.jar',
  };

  static String getSpigotUrlForVersion(String version) {
    final fileName = commonVersions[version] ?? 'spigot-$version.jar';
    return '$spigotBaseUrl/$fileName';
  }
}