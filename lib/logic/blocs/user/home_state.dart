import 'package:chat_message_websocket/data/models/user.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class UserSuccess extends HomeState {
  final User currentUser;

  const UserSuccess(this.currentUser);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserSuccess && currentUser == other.currentUser;

  @override
  int get hashCode => currentUser.hashCode;
}

class UserFailure extends HomeState {
  final String err;

  const UserFailure(this.err);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserFailure && err == other.err;

  @override
  int get hashCode => err.hashCode;
}
