import 'message.dart';

class Conversation {
  final String id;
  final String type;
  final List<String> participants;
  final Map<String, int> unreadCount;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? displayName;
  final String? avatarUrl;
  final String? status;
  final DateTime? lastSeen;

  Conversation({
    required this.id,
    required this.type,
    required this.participants,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.displayName,
    this.avatarUrl,
    this.status,
    this.lastSeen,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final lastMessageJson = json['lastMessage'];

    return Conversation(
      id: json['_id'] as String,
      type: json['type'] as String,
      participants: List<String>.from(json['participants'] ?? []),
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
      lastMessage: lastMessageJson != null ? Message.fromJson(lastMessageJson) : null,

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String?,
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'])
          : null,
    );
  }
  Conversation copyWith({
    Message? lastMessage,
    Map<String, int>? unreadCount,
  }) {
    return Conversation(
      id: id,
      type: type,
      participants: participants,
      displayName: displayName,
      avatarUrl: avatarUrl,
      lastSeen: lastSeen,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
