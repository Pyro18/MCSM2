import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final bool isOnline;
  final String? uuid;
  final DateTime? lastSeen;

  const Player({
    required this.id,
    required this.name,
    required this.isOnline,
    this.uuid,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [id, name, isOnline, uuid, lastSeen];
}