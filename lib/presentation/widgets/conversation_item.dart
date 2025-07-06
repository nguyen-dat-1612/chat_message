import 'package:chat_message_websocket/data/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/conversation.dart';

class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final String currentUsername;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context) {
    final otherUsername = conversation.participants.firstWhere(
          (p) => p != currentUsername,
      orElse: () => 'Không rõ',
    );

    final isUnread = (conversation.unreadCount[currentUsername] ?? 0) > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: CircleAvatar(
        backgroundImage: conversation.avatarUrl?.isNotEmpty == true
            ? NetworkImage(conversation.avatarUrl!)
            : null,
        child: conversation.avatarUrl?.isEmpty != false ? const Icon(Icons.person) : null,
      ),
      title: Text(
        conversation.displayName ?? otherUsername,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isUnread ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      subtitle: Text(
        _buildLastMessageText(conversation, currentUsername),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isUnread ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      trailing: Text(
        conversation.lastMessage?.createdAt != null
            ? DateFormat.Hm().format(conversation.lastMessage!.createdAt)
            : '',
        style: isUnread ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      onTap: () {
        context.pushNamed(
          'message',
          extra: {
            'conversation': conversation,
            'currentUsername': currentUsername,
          },
        );
      },
    );
  }
  String _buildLastMessageText(Conversation conversation, String currentUsername) {
    final message = conversation.lastMessage;

    if (message == null || (message.content?.trim().isEmpty ?? true)) {
      return 'Chưa có tin nhắn';
    }

    final isMe = message.sender == currentUsername;
    final prefix = isMe ? 'Bạn: ' : '${conversation.displayName}: ';
    final content = message.content ?? '';

    return '$prefix$content';
  }
}
