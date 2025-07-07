import 'package:chat_message_websocket/logic/blocs/profile/profile_event.dart';
import 'package:chat_message_websocket/logic/blocs/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/websocket_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final AuthRepository repository;
  final WebSocketService webSocket;

  ProfileBloc( {
    required this.repository,
    required this.webSocket
  }) : super(ProfileInitial()) {
    // on<FetchProfileEvent>(_onFetchProfile);
    // on<UpdateProfileEvent>(_onUpdateProfile);
    // on<DeleteProfileEvent>(_onDeleteProfile);
    on<LogoutProfileEvent>(_onLogoutProfile);
  }

  Future<void> _onLogoutProfile(LogoutProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await repository.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(Error(error: e.toString()));
    }
  }
}