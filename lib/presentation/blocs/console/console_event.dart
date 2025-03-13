part of 'console_bloc.dart';

abstract class ConsoleEvent extends Equatable {
  const ConsoleEvent();

  @override
  List<Object> get props => [];
}

class StartConsoleStreaming extends ConsoleEvent {
  final String serverId;

  const StartConsoleStreaming(this.serverId);

  @override
  List<Object> get props => [serverId];
}

class StopConsoleStreaming extends ConsoleEvent {}

class ConsoleLineReceived extends ConsoleEvent {
  final String line;

  const ConsoleLineReceived(this.line);

  @override
  List<Object> get props => [line];
}

class ClearConsole extends ConsoleEvent {}