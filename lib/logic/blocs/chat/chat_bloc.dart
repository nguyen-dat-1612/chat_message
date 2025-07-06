import 'package:chat_message_websocket/data/repositories/message_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/message.dart';
import '../../../services/WebSocketService.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessageRepository repository;
  final WebSocketService webSocket;
  final List<Message> _messages = [];

  ChatBloc({required this.webSocket, required this.repository}) : super(ChatInitial()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<SendTypingEvent>(_onSendTyping);
    on<PartnerTypingChanged>(_onPartnerTypingChanged);
    // Lắng nghe socket ngay khi Bloc được tạo
    webSocket.onMessage = (message) {
      add(MessageReceived(message: message));
    };
  }

  Future<void> _onFetchMessages(FetchMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await repository.fetchMessages(
          conversationId: event.conversationId);
      _messages.addAll(messages);
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final message = await repository.sendMessage(event.conversationId, event.text, event.type);
      print("Message sent: ${message.toString()}");
      _messages.add(message);
      emit(ChatLoaded(List.from(_messages)));
    } catch (e) {
      print("Message sent error: ${e.toString()}");
      emit(ChatError(e.toString()));
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    _messages.add(event.message);
    print(_messages.toString());
    emit(ChatLoaded(List.from(_messages)));
  }

  void _onSendTyping(SendTypingEvent event, Emitter<ChatState> emit) {
    webSocket.sendTyping(
      conversationId: event.conversationId,
      receiver: event.receiver,
      isTyping: event.isTyping,
    );
  }

  void _onPartnerTypingChanged(PartnerTypingChanged event, Emitter<ChatState> emit) {
    if (event.isTyping) {
      final typingMessage = Message.fakeTyping(
        sender: event.sender,
        conversationId: event.conversationId,
      );

      _messages.removeWhere((m) => m.isTypingFake); // tránh trùng
      _messages.add(typingMessage);
    } else {
      _messages.removeWhere((m) => m.isTypingFake);
    }

    emit(ChatLoaded(List.from(_messages)));
  }
}
