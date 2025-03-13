import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/minecraft_server_repository.dart';

part 'console_event.dart';
part 'console_state.dart';

class ConsoleBloc extends Bloc<ConsoleEvent, ConsoleState> {
  final MinecraftServerRepository repository;
  StreamSubscription? _outputSubscription;
  final List<String> _consoleLines = [];
  final int _maxLines = 1000; // Limita il numero di linee memorizzate

  ConsoleBloc({required this.repository}) : super(ConsoleInitial()) {
    on<StartConsoleStreaming>(_onStartConsoleStreaming);
    on<StopConsoleStreaming>(_onStopConsoleStreaming);
    on<ConsoleLineReceived>(_onConsoleLineReceived);
    on<ClearConsole>(_onClearConsole);
  }

  Future<void> _onStartConsoleStreaming(
      StartConsoleStreaming event,
      Emitter<ConsoleState> emit,
      ) async {
    await _outputSubscription?.cancel();

    _outputSubscription = repository
        .getServerOutput(event.serverId)
        .listen((output) {
      add(ConsoleLineReceived(output));
    });

    emit(ConsoleUpdated(List<String>.from(_consoleLines)));
  }

  Future<void> _onStopConsoleStreaming(
      StopConsoleStreaming event,
      Emitter<ConsoleState> emit,
      ) async {
    await _outputSubscription?.cancel();
    _outputSubscription = null;
  }

  void _onConsoleLineReceived(
      ConsoleLineReceived event,
      Emitter<ConsoleState> emit,
      ) {
    _consoleLines.add(event.line);

    // Limita il numero di linee memorizzate
    if (_consoleLines.length > _maxLines) {
      _consoleLines.removeRange(0, _consoleLines.length - _maxLines);
    }

    emit(ConsoleUpdated(List<String>.from(_consoleLines)));
  }

  void _onClearConsole(
      ClearConsole event,
      Emitter<ConsoleState> emit,
      ) {
    _consoleLines.clear();
    emit(ConsoleUpdated([]));
  }

  @override
  Future<void> close() {
    _outputSubscription?.cancel();
    return super.close();
  }
}