import '../../domain/entities/plugin.dart';

class PluginModel extends Plugin {
  const PluginModel({
    required String id,
    required String name,
    required String version,
    required bool isEnabled,
    String? description,
    List<String>? authors,
  }) : super(
    id: id,
    name: name,
    version: version,
    isEnabled: isEnabled,
    description: description,
    authors: authors,
  );

  factory PluginModel.fromJson(Map<String, dynamic> json) {
    return PluginModel(
      id: json['id'],
      name: json['name'],
      version: json['version'] ?? 'Unknown',
      isEnabled: json['isEnabled'] ?? true,
      description: json['description'],
      authors: json['authors'] != null ? List<String>.from(json['authors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'isEnabled': isEnabled,
      'description': description,
      'authors': authors,
    };
  }

  factory PluginModel.fromEntity(Plugin plugin) {
    return PluginModel(
      id: plugin.id,
      name: plugin.name,
      version: plugin.version,
      isEnabled: plugin.isEnabled,
      description: plugin.description,
      authors: plugin.authors,
    );
  }
}