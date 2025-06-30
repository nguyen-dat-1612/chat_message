import 'package:equatable/equatable.dart';
import '../../models/auth_model.dart';

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

class AuthSuccess extends AuthState {

  final AuthModel authModel;

  const AuthSuccess(this.authModel);

  @override
  List<Object?> get props => [authModel];
}

class AuthFailure extends AuthState {
  final String err;
  const AuthFailure(this.err);
  @override
  List<Object?> get props => [err];
}