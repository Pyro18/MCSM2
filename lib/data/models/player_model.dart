import '../../domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required String id,
    required String name,
    required bool isOnline,
    String? uuid,
    DateTime? lastSeen,
  }) : super(
    id: id,
    name: name,
    isOnline: isOnline,
    uuid: uuid,
    lastSeen: lastSeen,
  );

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      name: json['name'],
      isOnline: json['isOnline'] ?? false,
      uuid: json['uuid'],
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
      'uuid': uuid,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  factory PlayerModel.fromEntity(Player player) {
    return PlayerModel(
      id: player.id,
      name: player.name,
      isOnline: player.isOnline,
      uuid: player.uuid,
      lastSeen: player.lastSeen,
    );
  }
}