part of 'console_bloc.dart';

abstract class ConsoleState extends Equatable {
  const ConsoleState();

  @override
  List<Object> get props => [];
}

class ConsoleInitial extends ConsoleState {}

class ConsoleUpdated extends ConsoleState {
  final List<String> outputLines;

  const ConsoleUpdated(this.outputLines);

  @override
  List<Object> get props => [outputLines];
}