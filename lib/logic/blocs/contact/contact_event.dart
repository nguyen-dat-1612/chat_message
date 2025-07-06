import 'package:chat_message_websocket/data/models/simple_user.dart';

abstract class ContactEvent {}

class SetInitialContacts extends ContactEvent {
  final List<SimpleUser> contacts;
  SetInitialContacts(this.contacts);
}

class UpdateStatuses extends ContactEvent {
  final List<SimpleUser> updatedUsers;
  UpdateStatuses(this.updatedUsers);
}