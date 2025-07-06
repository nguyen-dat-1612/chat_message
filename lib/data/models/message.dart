import 'package:chat_message_websocket/data/models/message_type.dart';

class Message {
  final String id;
  final String conversationId;
  final String sender;
  final MessageType type;
  final String? content;
  final String? imageUrl;
  final String? fileUrl;
  final String? stickerId;
  final List<String> readBy;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.type,
    this.content,
    this.imageUrl,
    this.fileUrl,
    this.stickerId,
    required this.readBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      conversationId: json['conversationId'],
      sender: json['sender'],
      type: _typeFromString(json['type']),
      content: json['content'],
      imageUrl: json['imageUrl'],
      fileUrl: json['fileUrl'],
      stickerId: json['stickerId'],
      readBy: List<String>.from(json['readBy'] ?? []),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'conversationId': conversationId,
      'sender': sender,
      'type': _typeToString(type),
      'readBy': readBy,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (content != null) data['content'] = content;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (fileUrl != null) data['fileUrl'] = fileUrl;
    if (stickerId != null) data['stickerId'] = stickerId;

    return data;
  }

  static MessageType _typeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'sticker':
        return MessageType.sticker;
      case 'system':
        return MessageType.system;
      case 'typingFake':
        return MessageType.typingFake;
      default:
        return MessageType.text;
    }
  }

  static String _typeToString(MessageType type) {
    return type.toString().split('.').last;
  }

  bool get isTypingFake => id == 'typing_fake';

  factory Message.fakeTyping({required String sender, required String conversationId}) {
    return Message(
      id: 'typing_fake',
      conversationId: conversationId,
      sender: sender,
      type: MessageType.text,
      content: '__typing__',
      readBy: [],
      status: 'sent',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}
