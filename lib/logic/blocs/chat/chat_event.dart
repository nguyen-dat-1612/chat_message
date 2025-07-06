import 'package:equatable/equatable.dart';

import '../../../data/models/message.dart';

abstract class ChatEvent extends Equatable{
  const ChatEvent();
}

class ConnectToChat extends ChatEvent {
  final String username;
  ConnectToChat({required this.username});

  @override
  List<Object> get props => [username];
}

class FetchMessages extends ChatEvent {
  final String conversationId;

  FetchMessages({required this.conversationId});

  @override
  List<Object> get props => [conversationId];

}

class SendMessage extends ChatEvent {
  final String conversationId;
  final String text;
  final String type;
  SendMessage({ required this.conversationId, required this.text, required this.type});

  @override
  List<Object> get props => [conversationId, text, type];

}

class MessageReceived extends ChatEvent {
  final Message message;
  MessageReceived({required this.message});

  @override
  List<Object> get props => [message];

}

class DisconnectChat extends ChatEvent {
  DisconnectChat();

  @override
  List<Object> get props => [];
}

class SendTypingEvent extends ChatEvent {
  final String conversationId;
  final String receiver;
  final bool isTyping;

  SendTypingEvent({
    required this.conversationId,
    required this.receiver,
    required this.isTyping,
  });

  @override
  List<Object> get props => [conversationId, receiver, isTyping];
}

class PartnerTypingChanged extends ChatEvent {
  final String sender;
  final String conversationId;
  final bool isTyping;

  PartnerTypingChanged({
    required this.sender,
    required this.conversationId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [sender, conversationId, isTyping];
}
