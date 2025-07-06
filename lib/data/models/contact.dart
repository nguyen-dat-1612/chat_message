import 'package:chat_message_websocket/data/models/simple_user.dart';
import 'package:chat_message_websocket/data/models/user.dart';

class Contact {
  final String id;
  final SimpleUser user;
  final String nickname;
  final DateTime addedAt;

  Contact({
    required this.id,
    required this.user,
    required this.nickname,
    required this.addedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'] ?? json['id'],
      user: SimpleUser.fromJson(json['user']),
      nickname: json['nickname'] ?? '',
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}