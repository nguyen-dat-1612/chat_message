import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/exceptions.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final loginRes = await authRepository.login(
        username: event.username,
        password: event.password,
      );
      emit(AuthLoginSuccess(loginRes));
    } catch (e) {
      if (e is ServerException) {
        emit(AuthFailure(e.message));
      } else {
        emit(AuthFailure('An unexpected error occurred'));
      }
    }
  }

  FutureOr<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    try {
      authRepository.register(
        username: event.username,
        email: event.email,
        password: event.password,
        displayName: event.displayName
      );
      emit(AuthRegisterSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(AuthFailure(e.message));
      } else {
        emit(AuthFailure('An unexpected error occurred'));
      }
    }
  }

  FutureOr<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    try {
      authRepository.logout();
      emit(AuthLogoutSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(AuthFailure(e.message));
      } else {
        emit(AuthFailure('An unexpected error occurred'));
      }
    }
  }

  FutureOr<void> _onRefreshToken(RefreshTokenEvent event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    try {
      authRepository.refreshToken();
      emit(AuthRefreshTokenSuccess());
      } catch (e) {
      if (e is ServerException) {
        emit(AuthFailure(e.message));
      } else {
        emit(AuthFailure('An unexpected error occurred'));
        }
    }
  }
}