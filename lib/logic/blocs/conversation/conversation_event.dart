
import 'package:chat_message_websocket/data/models/message.dart';
import 'package:chat_message_websocket/data/models/user_status.dart';
import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();
}

class FetchConversationsEvent extends ConversationEvent {
  const FetchConversationsEvent();
  @override
  List<Object?> get props => [];
}

class CreateConversationEvent extends ConversationEvent {
  final String username;
  const CreateConversationEvent(this.username);
  @override
  List<Object?> get props => [username];
}

class UserOnlineEvent extends ConversationEvent {
  final List<UserStatus> user;
  const UserOnlineEvent({required this.user});
  @override
  List<Object?> get props => [user];

}

class UpdateContactStatusEvent extends ConversationEvent {
  final List<UserStatus> users;

  UpdateContactStatusEvent({required this.users});

  @override
  List<Object?> get props => [users];
}

class UpdateLastMessageEvent extends ConversationEvent {
  final String conversationId;
  final Message message;
  UpdateLastMessageEvent({required this.conversationId, required this.message});
  @override
  List<Object?> get props => [conversationId, message];
}