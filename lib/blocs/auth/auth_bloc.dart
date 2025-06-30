

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final authModel = await authRepository.login(
        username: event.username,
        password: event.password,
      );
      emit(AuthSuccess(authModel));
    } catch (e) {
      if (e is ServerException) {
        emit(AuthFailure(e.message));
      } else {
        emit(AuthFailure('An unexpected error occurred'));
      }
    }
  }

}