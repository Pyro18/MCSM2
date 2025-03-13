part of 'server_list_bloc.dart';

abstract class ServerListEvent extends Equatable {
  const ServerListEvent();

  @override
  List<Object> get props => [];
}

class LoadServerList extends ServerListEvent {}

class AddServer extends ServerListEvent {
  final Server server;

  const AddServer(this.server);

  @override
  List<Object> get props => [server];
}

class UpdateServer extends ServerListEvent {
  final Server server;

  const UpdateServer(this.server);

  @override
  List<Object> get props => [server];
}

class DeleteServer extends ServerListEvent {
  final String serverId;

  const DeleteServer(this.serverId);

  @override
  List<Object> get props => [serverId];
}