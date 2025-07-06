import 'package:chat_message_websocket/data/models/simple_user.dart';

abstract class ContactState {

}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactLoaded extends ContactState {
  final List<SimpleUser> contacts;

  ContactLoaded(this.contacts);
}

class ContactError extends ContactState {
  final String message;

  ContactError(this.message);
}
