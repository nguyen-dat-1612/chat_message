import 'dart:async';
import 'dart:convert';
import 'package:chat_message_websocket/models/message.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final WebSocketChannel channel;
  StreamSubscription? _channelSubscription;
  List<Message> _messages = [];
  List<String> _onlineUsers = [];
  final _uuid = Uuid();

  ChatBloc({required this.channel}) : super(ChatInitial()) {
    on<ConnectToChat>(_onConnectToChat);
    on<SendMessage>(_onSendMessage);
    on<SendImage>(_onSendImage);
    on<UserLeft>(_onUserLeft);
    on<Disconnect>(_onDisconnect);
  }

  _onConnectToChat(ConnectToChat event, Emitter<ChatState> emit) {
    emit(ChatInitial());
    channel.sink.add(jsonEncode({
      "type": "join",
      "username": event.username,
    }));

    _channelSubscription = channel.stream.listen((message) {
      _handleIncomingMessage(message);
    }, onError: (error) {
      emit(ChatError(err: error.toString()));
      print("Đã có lỗi xảy ra: ${error.toString()}");
    });
  }

  _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    final message = Message(
      id: _uuid.v4(),
      type: 'chat',
      username: event.username,
      text: event.text,
      time: DateTime.now(),
      isPending: true,
    );

    channel.sink.add(jsonEncode(message.toJson()));
    // _messages.add(message);
    emit(ChatConnected(messages: _messages, onlineUsers: _onlineUsers));

  }

  _onSendImage(SendImage event, Emitter<ChatState> emit) {
    final message = Message(
        id: _uuid.v4(),
        type: 'image',
        username:  event.username,
        text: '[image]',
        imageBase64: event.base64Image,
        time: DateTime.now(),
        isPending: true
    );

    channel.sink.add(jsonEncode(message.toJson()));
    // _messages.add(message);
    // _messages.add(Message(
    //   username: event.username,
    //   text: "[image]",
    //   time: DateTime.now(),
    //   imageBase64: event.base64Image,
    //   isPending: true,
    // ));
    emit(ChatConnected(messages: _messages, onlineUsers: _onlineUsers));

  }

  void _onUserLeft(UserLeft event, Emitter<ChatState> emit) {
    final leaveMsg = {
      "type": "leave",
      "username": event.username,
    };
    channel.sink.add(jsonEncode(leaveMsg));
  }

  void _onDisconnect(Disconnect event, Emitter<ChatState> emit) {
    _channelSubscription?.cancel();
    channel.sink.close();
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      final decoded = message is List<int> ? utf8.decode(message) : message.toString();
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      print("🔥 Received: $json");

      final type = json['type']?.toString();
      if (type == null) {
        emit(ChatError(err: "Tin nhắn không có type"));
        return;
      }

      switch (type) {
        case 'history':
          final history = json['messages'] as List<dynamic>? ?? [];
          _messages = history.map((msg) => Message.fromJson(msg)).toList();
          break;

        case 'user_list':
          final newUsers = (json['users'] as List<dynamic>? ?? [])
              .whereType<String>()
              .toList();

          // Chỉ cập nhật nếu danh sách thực sự thay đổi
          if (!const ListEquality().equals(_onlineUsers, newUsers)) {
            _onlineUsers = newUsers;
          }
          break;
        case 'join':
        case 'leave':
          final username = json['username']?.toString() ?? 'Ẩn danh';
          _messages = [
            ..._messages,
            Message(
              id: _uuid.v4(),
              type: type,
              username: '📢 Hệ thống',
              text: type == "join"
                  ? '$username vừa tham gia phòng chat'
                  : '$username vừa rời phòng chat',
              time: DateTime.now()
            )
          ];
          break;

        case 'ack':
          final ackTime = DateTime.tryParse(json['time']?.toString() ?? '');
          if (ackTime != null) {
            _messages = _messages.map((m) {
              return m.isPending && m.time.isAtSameMomentAs(ackTime)
                  ? m.copyWith(isPending: false)
                  : m;
            }).toList();
          }
          break;

        default: // Xử lý tin nhắn thường (chat/image)
          _messages = [..._messages, Message.fromJson(json)];
      }

      emit(ChatConnected(messages: _messages, onlineUsers: _onlineUsers));
    } catch (e) {
      print("Đã có lỗi xảy ra: ${e.toString()}");
      emit(ChatError(err: "Lỗi khi xử lý tin nhắn: $e"));
    }
  }

  @override
  Future<void> close() {
    _channelSubscription?.cancel();
    channel.sink.close();
    return super.close();
  }
}