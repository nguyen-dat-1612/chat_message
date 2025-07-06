import 'package:chat_message_websocket/services/WebSocketService.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../data/repositories/user_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final WebSocketService webSocket;
  final UserRepository repository;

  HomeBloc({required this.webSocket, required this.repository})
      : super(HomeInitial()) {
    on<FetchUserEvent>(_onFetchUser);
  }

  Future<void> _onFetchUser(
      FetchUserEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final user = await repository.getUserProfile();

      // ✅ Bật socket tại đây
      await webSocket.connect(user.username);

      emit(UserSuccess(user));
    } catch (e) {
      emit(UserFailure(e.toString()));
    }
  }
}

