import 'package:equatable/equatable.dart';
import '../../../data/models/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatConnecting extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}