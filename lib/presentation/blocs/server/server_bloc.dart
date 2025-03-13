import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/server.dart';
import '../../../domain/usecases/get_server_by_id.dart';
import '../../../domain/usecases/start_server.dart';
import '../../../domain/usecases/stop_server.dart';
import '../../../domain/usecases/send_command.dart';

// Events
abstract class ServerEvent extends Equatable {
  const ServerEvent();

  @override
  List<Object> get props => [];
}

class LoadServer extends ServerEvent {
  final String serverId;

  const LoadServer(this.serverId);

  @override
  List<Object> get props => [serverId];
}

class StartServer extends ServerEvent {
  final String serverId;

  const StartServer(this.serverId);

  @override
  List<Object> get props => [serverId];
}

class StopServer extends ServerEvent {
  final String serverId;

  const StopServer(this.serverId);

  @override
  List<Object> get props => [serverId];
}

class SendServerCommand extends ServerEvent {
  final String serverId;
  final String command;

  const SendServerCommand(this.serverId, this.command);

  @override
  List<Object> get props => [serverId, command];
}

// States
abstract class ServerState extends Equatable {
  const ServerState();

  @override
  List<Object?> get props => [];
}

class ServerInitial extends ServerState {}

class ServerLoading extends ServerState {}

class ServerLoaded extends ServerState {
  final Server server;

  const ServerLoaded(this.server);

  @override
  List<Object?> get props => [server];
}

class ServerStarting extends ServerState {
  final Server server;

  const ServerStarting(this.server);

  @override
  List<Object?> get props => [server];
}

class ServerStopping extends ServerState {
  final Server server;

  const ServerStopping(this.server);

  @override
  List<Object?> get props => [server];
}

class ServerOperationSuccess extends ServerState {
  final String message;
  final Server server;

  const ServerOperationSuccess(this.message, this.server);

  @override
  List<Object?> get props => [message, server];
}

class ServerOperationFailure extends ServerState {
  final String message;

  const ServerOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ServerBloc extends Bloc<ServerEvent, ServerState> {
  final GetServerByIdUseCase getServerById;
  final StartServerUseCase startServer;
  final StopServerUseCase stopServer;
  final SendCommandUseCase sendCommand;

  ServerBloc({
    required this.getServerById,
    required this.startServer,
    required this.stopServer,
    required this.sendCommand,
  }) : super(ServerInitial()) {
    on<LoadServer>(_onLoadServer);
    on<StartServer>(_onStartServer);
    on<StopServer>(_onStopServer);
    on<SendServerCommand>(_onSendServerCommand);
  }

  Future<void> _onLoadServer(LoadServer event, Emitter<ServerState> emit) async {
    emit(ServerLoading());

    final server = await getServerById(event.serverId);

    if (server != null) {
      emit(ServerLoaded(server));
    } else {
      emit(const ServerOperationFailure('Server non trovato'));
    }
  }

  Future<void> _onStartServer(StartServer event, Emitter<ServerState> emit) async {
    final server = await getServerById(event.serverId);

    if (server == null) {
      emit(const ServerOperationFailure('Server non trovato'));
      return;
    }

    emit(ServerStarting(server));

    final success = await startServer(event.serverId);

    if (success) {
      final updatedServer = await getServerById(event.serverId);
      if (updatedServer != null) {
        emit(ServerOperationSuccess('Server avviato con successo', updatedServer));
      }
    } else {
      emit(const ServerOperationFailure('Impossibile avviare il server'));
    }
  }

  Future<void> _onStopServer(StopServer event, Emitter<ServerState> emit) async {
    final server = await getServerById(event.serverId);

    if (server == null) {
      emit(const ServerOperationFailure('Server non trovato'));
      return;
    }

    emit(ServerStopping(server));

    final success = await stopServer(event.serverId);

    if (success) {
      final updatedServer = await getServerById(event.serverId);
      if (updatedServer != null) {
        emit(ServerOperationSuccess('Server fermato con successo', updatedServer));
      }
    } else {
      emit(const ServerOperationFailure('Impossibile fermare il server'));
    }
  }

  Future<void> _onSendServerCommand(SendServerCommand event, Emitter<ServerState> emit) async {
    final success = await sendCommand(event.serverId, event.command);

    if (!success) {
      emit(const ServerOperationFailure('Impossibile inviare il comando'));
    }
  }
}