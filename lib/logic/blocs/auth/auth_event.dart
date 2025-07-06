
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String displayName;

  const RegisterEvent({required this.username,required this.email,
    required this.password, required this.displayName});

  @override
  List<Object?> get props => [username, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();

  @override
  List<Object?> get props => [];
}

