part of 'version_selector_bloc.dart';

abstract class VersionSelectorEvent extends Equatable {
  const VersionSelectorEvent();

  @override
  List<Object?> get props => [];
}

// Carica le versioni disponibili di Paper
class LoadPaperVersions extends VersionSelectorEvent {
  final String minVersion;

  const LoadPaperVersions({this.minVersion = '1.8.9'});

  @override
  List<Object> get props => [minVersion];
}

// Carica le build disponibili per una versione specifica
class LoadPaperBuilds extends VersionSelectorEvent {
  final String version;

  const LoadPaperBuilds(this.version);

  @override
  List<Object> get props => [version];
}

// Seleziona una versione
class SelectVersion extends VersionSelectorEvent {
  final ServerVersion version;

  const SelectVersion(this.version);

  @override
  List<Object> get props => [version];
}

// Avvia il download di una versione
class DownloadServerVersion extends VersionSelectorEvent {
  final ServerVersion version;
  final String destinationPath;

  const DownloadServerVersion(this.version, this.destinationPath);

  @override
  List<Object> get props => [version, destinationPath];
}

// Aggiorna il progresso del download
class DownloadProgressUpdate extends VersionSelectorEvent {
  final double progress;

  const DownloadProgressUpdate(this.progress);

  @override
  List<Object> get props => [progress];
}

// Annulla il download
class CancelDownload extends VersionSelectorEvent {}