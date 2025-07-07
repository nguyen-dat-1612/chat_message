
import 'package:chat_message_websocket/data/repositories/conversation_repository.dart';
import 'package:chat_message_websocket/services/websocket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/simple_user.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {

  final ConversationRepository repository;
  final WebSocketService socket;

  ConversationBloc({required this.repository, required this.socket}) : super(ConversationInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<CreateConversationEvent>(_onCreateConversation);
    on<UpdateLastMessageEvent>(_onUpdateLastMessage);

  }


  Future<void> _onFetchConversations(FetchConversationsEvent event, Emitter<ConversationState> emit) async {
    emit(ConversationLoading());
    try {
      final conversations = await repository.fetchConversations();
      emit(ConversationSuccess(conversations));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }

  Future<void> _onCreateConversation(CreateConversationEvent event, Emitter<ConversationState> emit) async {
    emit(ConversationLoading());
    try {
      final conversation = await repository.createConversation(username: event.username);
      emit(ConversationSuccess([conversation]));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }

  void _onUpdateLastMessage(
      UpdateLastMessageEvent event,
      Emitter<ConversationState> emit,
      ) {
    final currentState = state;

    if (currentState is ConversationSuccess) {
      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(lastMessage: event.message);
        }
        return c;
      }).toList();

      emit(ConversationSuccess(updatedConversations));
    }
  }
}