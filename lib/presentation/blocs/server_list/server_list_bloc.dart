import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/server.dart';
import '../../../domain/repositories/minecraft_server_repository.dart';

part 'server_list_event.dart';
part 'server_list_state.dart';

class ServerListBloc extends Bloc<ServerListEvent, ServerListState> {
  final MinecraftServerRepository repository;

  ServerListBloc({required this.repository}) : super(ServerListInitial()) {
    on<LoadServerList>(_onLoadServerList);
    on<AddServer>(_onAddServer);
    on<UpdateServer>(_onUpdateServer);
    on<DeleteServer>(_onDeleteServer);
  }

  Future<void> _onLoadServerList(
      LoadServerList event,
      Emitter<ServerListState> emit,
      ) async {
    emit(ServerListLoading());

    try {
      final servers = await repository.getServers();
      emit(ServerListLoaded(servers));
    } catch (e) {
      emit(ServerListError(e.toString()));
    }
  }

  Future<void> _onAddServer(
      AddServer event,
      Emitter<ServerListState> emit,
      ) async {
    if (state is ServerListLoaded) {
      try {
        final newServer = await repository.addServer(event.server);
        final currentServers = (state as ServerListLoaded).servers;
        emit(ServerListLoaded([...currentServers, newServer]));
      } catch (e) {
        emit(ServerListError(e.toString()));
        // Ripristina lo stato precedente
        emit(state);
      }
    }
  }

  Future<void> _onUpdateServer(
      UpdateServer event,
      Emitter<ServerListState> emit,
      ) async {
    if (state is ServerListLoaded) {
      try {
        final success = await repository.updateServer(event.server);
        if (success) {
          final currentServers = (state as ServerListLoaded).servers;
          final updatedServers = currentServers.map((server) {
            return server.id == event.server.id ? event.server : server;
          }).toList();
          emit(ServerListLoaded(updatedServers));
        }
      } catch (e) {
        emit(ServerListError(e.toString()));
        // Ripristina lo stato precedente
        emit(state);
      }
    }
  }

  Future<void> _onDeleteServer(
      DeleteServer event,
      Emitter<ServerListState> emit,
      ) async {
    if (state is ServerListLoaded) {
      try {
        final success = await repository.deleteServer(event.serverId);
        if (success) {
          final currentServers = (state as ServerListLoaded).servers;
          final updatedServers = currentServers
              .where((server) => server.id != event.serverId)
              .toList();
          emit(ServerListLoaded(updatedServers));
        }
      } catch (e) {
        emit(ServerListError(e.toString()));
        // Ripristina lo stato precedente
        emit(state);
      }
    }
  }
}