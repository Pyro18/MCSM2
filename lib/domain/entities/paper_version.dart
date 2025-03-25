import 'package:equatable/equatable.dart';

class PaperVersion extends Equatable {
  final String version;
  final List<int> builds;

  const PaperVersion({
    required this.version,
    required this.builds,
  });

  @override
  List<Object?> get props => [version, builds];
}

class PaperBuild extends Equatable {
  final String projectId;
  final String projectName;
  final String version;
  final int build;
  final String time;
  final String channel;
  final bool promoted;
  final Map<String, PaperDownload> downloads;

  const PaperBuild({
    required this.projectId,
    required this.projectName,
    required this.version,
    required this.build,
    required this.time,
    required this.channel,
    required this.promoted,
    required this.downloads,
  });

  factory PaperBuild.fromJson(Map<String, dynamic> json) {
    final downloadsJson = json['downloads'] as Map<String, dynamic>;
    final downloads = <String, PaperDownload>{};

    downloadsJson.forEach((key, value) {
      downloads[key] = PaperDownload.fromJson(value);
    });

    return PaperBuild(
      projectId: json['project_id'],
      projectName: json['project_name'],
      version: json['version'],
      build: json['build'],
      time: json['time'],
      channel: json['channel'],
      promoted: json['promoted'] ?? false,
      downloads: downloads,
    );
  }

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    version,
    build,
    time,
    channel,
    promoted,
    downloads,
  ];
}

class PaperDownload extends Equatable {
  final String name;
  final String sha256;

  const PaperDownload({
    required this.name,
    required this.sha256,
  });

  factory PaperDownload.fromJson(Map<String, dynamic> json) {
    return PaperDownload(
      name: json['name'],
      sha256: json['sha256'],
    );
  }

  @override
  List<Object?> get props => [name, sha256];
}