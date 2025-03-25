part of 'version_selector_bloc.dart';

abstract class VersionSelectorState extends Equatable {
  const VersionSelectorState();

  @override
  List<Object?> get props => [];
}

// Stato iniziale
class VersionSelectorInitial extends VersionSelectorState {}

// Stati per il caricamento delle versioni
class VersionsLoading extends VersionSelectorState {}

class VersionsLoaded extends VersionSelectorState {
  final List<String> versions;

  const VersionsLoaded(this.versions);

  @override
  List<Object> get props => [versions];
}

class VersionsError extends VersionSelectorState {
  final String message;

  const VersionsError(this.message);

  @override
  List<Object> get props => [message];
}

// Stati per il caricamento delle build
class BuildsLoading extends VersionSelectorState {}

class BuildsLoaded extends VersionSelectorState {
  final String version;
  final List<int> builds;

  const BuildsLoaded(this.version, this.builds);

  @override
  List<Object> get props => [version, builds];
}

class BuildsError extends VersionSelectorState {
  final String message;

  const BuildsError(this.message);

  @override
  List<Object> get props => [message];
}

// Stato di versione selezionata
class VersionSelected extends VersionSelectorState {
  final ServerVersion version;

  const VersionSelected(this.version);

  @override
  List<Object> get props => [version];
}

// Stati per il download
class DownloadStarted extends VersionSelectorState {
  final ServerVersion version;

  const DownloadStarted(this.version);

  @override
  List<Object> get props => [version];
}

class DownloadInProgress extends VersionSelectorState {
  final double progress;

  const DownloadInProgress(this.progress);

  @override
  List<Object> get props => [progress];
}

class DownloadCompleted extends VersionSelectorState {}

class DownloadFailed extends VersionSelectorState {
  final String message;

  const DownloadFailed(this.message);

  @override
  List<Object> get props => [message];
}

class DownloadCancelled extends VersionSelectorState {}