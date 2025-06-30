
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToChat extends ChatEvent {
  final String username;

  const ConnectToChat({required this.username});
  @override
  List<Object?> get props => [username];
}

class SendMessage extends ChatEvent {
  final String text;
  final String username;

  const SendMessage({required this.text, required this.username});
  @override
  List<Object?> get props => [text, username];

}

class SendImage extends ChatEvent {
  final String base64Image;
  final String username;

  const SendImage({required this.base64Image, required this.username});
  @override
  List<Object?> get props => [base64Image, username];
}

class UserLeft extends ChatEvent {
  final String username;

  const UserLeft({required this.username});

  @override
  List<Object?> get props => [username];
}

class Disconnect extends ChatEvent {}
