import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/server_version.dart';
import '../../../domain/usecases/download_server.dart';

part 'version_selector_event.dart';
part 'version_selector_state.dart';

class VersionSelectorBloc extends Bloc<VersionSelectorEvent, VersionSelectorState> {
  final DownloadServerUseCase downloadServer;
  StreamSubscription? _downloadSubscription;

  VersionSelectorBloc({
    required this.downloadServer,
  }) : super(VersionSelectorInitial()) {
    on<LoadPaperVersions>(_onLoadPaperVersions);
    on<LoadPaperBuilds>(_onLoadPaperBuilds);
    on<SelectVersion>(_onSelectVersion);
    on<DownloadServerVersion>(_onDownloadServerVersion);
    on<DownloadProgressUpdate>(_onDownloadProgressUpdate);
    on<CancelDownload>(_onCancelDownload);
  }

  Future<void> _onLoadPaperVersions(
      LoadPaperVersions event,
      Emitter<VersionSelectorState> emit,
      ) async {
    emit(VersionsLoading());
    try {
      final versions = await downloadServer.getAvailablePaperVersions(minVersion: event.minVersion);
      emit(VersionsLoaded(versions));
    } catch (e) {
      emit(VersionsError('Impossibile caricare le versioni: $e'));
    }
  }

  Future<void> _onLoadPaperBuilds(
      LoadPaperBuilds event,
      Emitter<VersionSelectorState> emit,
      ) async {
    emit(BuildsLoading());
    try {
      final builds = await downloadServer.getPaperBuildsForVersion(event.version);
      emit(BuildsLoaded(event.version, builds));
    } catch (e) {
      emit(BuildsError('Impossibile caricare le build per la versione ${event.version}: $e'));
    }
  }

  void _onSelectVersion(
      SelectVersion event,
      Emitter<VersionSelectorState> emit,
      ) {
    emit(VersionSelected(event.version));
  }

  Future<void> _onDownloadServerVersion(
      DownloadServerVersion event,
      Emitter<VersionSelectorState> emit,
      ) async {
    emit(DownloadStarted(event.version));
    await _downloadSubscription?.cancel();

    _downloadSubscription = downloadServer(event.version, event.destinationPath)
        .listen((progress) {
      add(DownloadProgressUpdate(progress));
    });
  }

  void _onDownloadProgressUpdate(
      DownloadProgressUpdate event,
      Emitter<VersionSelectorState> emit,
      ) {
    if (event.progress < 0) {
      emit(DownloadFailed('Si è verificato un errore durante il download'));
    } else if (event.progress >= 1.0) {
      emit(DownloadCompleted());
    } else {
      emit(DownloadInProgress(event.progress));
    }
  }

  Future<void> _onCancelDownload(
      CancelDownload event,
      Emitter<VersionSelectorState> emit,
      ) async {
    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    emit(DownloadCancelled());
  }

  @override
  Future<void> close() {
    _downloadSubscription?.cancel();
    return super.close();
  }
}