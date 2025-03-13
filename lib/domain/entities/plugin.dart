import 'package:equatable/equatable.dart';

class Plugin extends Equatable {
  final String id;
  final String name;
  final String version;
  final bool isEnabled;
  final String? description;
  final List<String>? authors;

  const Plugin({
    required this.id,
    required this.name,
    required this.version,
    required this.isEnabled,
    this.description,
    this.authors,
  });

  @override
  List<Object?> get props => [id, name, version, isEnabled, description, authors];
}