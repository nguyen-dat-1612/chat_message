
import 'package:chat_message_websocket/models/message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];

}

class ChatInitial extends ChatState {}

class ChatConnected extends ChatState with EquatableMixin  {
  final List<Message> messages;
  final List<String> onlineUsers;

  const ChatConnected({required this.messages, required this.onlineUsers});

  @override
  List<Object?> get props => [messages, onlineUsers];
}

class ChatError extends ChatState {
  final String err;

  const ChatError({required this.err});

  @override
  List<Object?> get props => [err];

}