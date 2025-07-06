import 'package:equatable/equatable.dart';
import '../../../data/models/login_response.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoginSuccess extends AuthState {
  final LoginResponse loginRes;
  const AuthLoginSuccess(this.loginRes);
  @override
  List<Object?> get props => [loginRes];
}

class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess();
  @override
  List<Object?> get props => [];
}

class AuthLogoutSuccess extends AuthState {
  const AuthLogoutSuccess();
  @override
  List<Object?> get props => [];
}

class AuthRefreshTokenSuccess extends AuthState {
  const AuthRefreshTokenSuccess();
  @override
  List<Object?> get props => [];
}

class AuthFailure extends AuthState {
  final String err;
  const AuthFailure(this.err);
  @override
  List<Object?> get props => [err];
}