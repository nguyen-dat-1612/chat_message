import 'dart:async';
import 'dart:convert';
import 'package:chat_message_websocket/core/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../core/constants/constants.dart';
import '../data/models/message.dart';
import '../data/models/user_status.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  late final Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool _isConnected = false;
  bool _manuallyDisconnected = false;
  bool _isReconnecting = false;

  late String username;

  WebSocketService() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_handleNetworkChange);
  }

  void _handleNetworkChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none && !_isConnected && !_manuallyDisconnected) {
      print('[🌐] Network back - trying to reconnect WebSocket');
      connect(username);
    }
    if (result == ConnectivityResult.none && _isConnected) {
      print('[🚫] Lost network - closing WebSocket');
      disconnect();
    }
  }

  // ==== Callback dành cho phần chat (tin nhắn, trạng thái, typing, cuộc gọi) ====
  void Function(Message)? onMessage; // Khi nhận tin nhắn mới
  void Function(List<UserStatus>)? onPresence; // Khi nhận danh sách người online
  void Function(String conversationId, Message message)? onConversationUpdate; // Khi có tin nhắn mới trong cuộc trò chuyện
  void Function(String conversationId, String sender, bool isTyping)? onTyping; // Khi có người đang gõ
  void Function(String caller, String conversationId)? onIncomingCall; // Khi có cuộc gọi đến
  void Function(String from)? onCallAccepted;
  // ==== Callback dành cho WebRTC (video call) ====
  void Function(String from, Map<String, dynamic> data)? onSdp; // Khi nhận SDP
  void Function(String from, Map<String, dynamic> data)? onIce; // Khi nhận ICE
  void Function(String from)? onHangup; // Khi đầu kia dập máy

  /// Kết nối đến WebSocket server
  Future<void> connect(String username) async {
    if (_isConnected) return;

    this.username = username;
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse('$baseSocket?username=$username'));
      _isConnected = true;
      _manuallyDisconnected = false;

      _channel!.stream.listen(
          _handleData,
          onDone: _onDisconnected,
          onError: (err) => _onDisconnected()
      );
    } catch (e) {
      logger.e('❌ Lỗi kết nối WebSocket: $e');
      throw(Exception(e));
    }
  }

  void disconnect() {
    _manuallyDisconnected = true;
    _channel?.sink.close();
    _isConnected = false;
    _channel = null;
  }

  void _onDisconnected() {
    _isConnected = false;
    if (!_manuallyDisconnected && !_isReconnecting) {
      _tryReconnect();
    }
  }

  void _tryReconnect() async {
    _isReconnecting = true;
    await Future.delayed(Duration(seconds: 3));
    if (!_isConnected) {
      await connect(username);
    }
    _isReconnecting = false;
  }

  /// Xử lý dữ liệu nhận được từ WebSocket
  void _handleData(dynamic rawData) {
    try {
      final decoded = jsonDecode(rawData);
      final type = decoded['type'];
      final payload = decoded['data'];

      print('Thanh Dat: 📨 Nhận tin nhắn WebSocket: $type');

      switch (type) {
        case 'message':
          onMessage?.call(Message.fromJson(payload));
          break;

        case 'presence':
          final list = (payload as List).map((e) => UserStatus.fromJson(e)).toList();
          onPresence?.call(list);
          break;

        case 'conversation_update':
          final conversationId = payload['conversationId'];
          final message = Message.fromJson(payload['data']['message']);
          onConversationUpdate?.call(conversationId, message);
          break;

        case 'typing':
          onTyping?.call(payload['conversationId'], payload['sender'], payload['isTyping']);
          break;

        case 'call':
          print('Thanh Dat: 📞 Cuộc gọi đến từ ${payload['from']}');
          onIncomingCall?.call(payload['from'], payload['conversationId']);
          break;
        case 'call_accept':
          print('📞 Người kia đã chấp nhận cuộc gọi: ${payload['from']}');
          onCallAccepted?.call(payload['from']);
          break;
        case 'sdp':
          print("Thanh Dat: 📡 Nhận SDP từ ${payload['from']}");
          _handleSdp(payload);
          break;

        case 'ice':
          print("Thanh Dat: 🧊 Nhận ICE từ ${payload['from']}");
          _handleIce(payload);
          break;

        case 'hangup':
          _handleHangup(payload);
          break;

        default:
          print('Thanh Dat: ⚠️ Loại dữ liệu không xác định: $type');
          break;
      }
    } catch (e) {
      print('Thanh Dat: ❌ Lỗi khi parse dữ liệu WebSocket: $e');
    }
  }

  void _handleSdp(Map payload) {
    print('Thanh Dat: 📡 Đang xử lý SDP từ ${payload}');
    final from = payload['from'];
    final sdp = payload['sdp'];
    final type = payload['type'];

    // Kiểm tra kỹ dữ liệu nhận được
    if (from == null || sdp == null || type == null) {
      print('Thanh Dat: ❌ Dữ liệu SDP không hợp lệ: $payload');
      return;  // Dừng lại nếu dữ liệu không hợp lệ
    }

    print('Thanh Dat: 📡 Đang xử lý SDP từ $from | Loại: $type');

    // Gọi callback onSdp nếu dữ liệu hợp lệ
    onSdp?.call(from, {
      'sdp': sdp,
      'type': type,
    });
  }

  /// Xử lý gói ICE nhận được
  void _handleIce(Map payload) {
    final from = payload['from'];
    final candidate = payload['candidate'];
    final sdpMid = payload['sdpMid'];
    final sdpMLineIndex = payload['sdpMLineIndex'];

    if (from != null && candidate != null) {
      print('Thanh Dat: 🧊 Đang xử lý ICE từ $from');
      onIce?.call(from, {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      });
    } else {
      print('Thanh Dat: ❌ Dữ liệu ICE không hợp lệ');
    }
  }

  /// Xử lý khi bên kia kết thúc cuộc gọi
  void _handleHangup(Map payload) {
    final from = payload['from'];
    if (from != null) {
      print('Thanh Dat: 📞 Đầu kia đã dập máy: $from');
      onHangup?.call(from);
    }
  }

  // ================================
  // ===== Gửi dữ liệu ra socket ====
  // ================================

  /// Gửi tín hiệu "đang gõ"
  void sendTyping({required String conversationId, required String receiver, required bool isTyping}) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'typing',
      'data': {
        'conversationId': conversationId,
        'sender': username,
        'receiver': receiver,
        'isTyping': isTyping,
      },
    }));
  }

  /// Gửi lời mời gọi video
  void sendCallOffer({required String conversationId, required String sender, required String receiver}) {
    if (_channel == null) return;
    print('Thanh Dat: 📞 Gửi lời mời gọi tới $receiver');
    _channel!.sink.add(jsonEncode({
      'type': 'call',
      'data': {
        'conversationId': conversationId,
        'from': sender,
        'to': receiver
      }
    }));
  }

  // Gửi chấp nhận gọi video
  void sendCallAccept({required String to}) {
    if (_channel == null) return;
    print('📞 Gửi call_accept đến $to');
    _channel!.sink.add(jsonEncode({
      'type': 'call_accept',
      'data': {
        'from': username,
        'to': to
      }
    }));
  }

  /// Gửi SDP (offer hoặc answer)
  void sendSDP(String to, RTCSessionDescription sdp) {
    if (_channel == null)  {
      print('Thanh Dat: ❌ Không thể gửi SDP vì chưa kết nối WebSocket');
      return;
    };

    print('📡 Gửi SDP tới $to: ${sdp.type}');

    _channel!.sink.add(jsonEncode({
      'type': 'sdp',
      'data': {
        'to': to,
        'from': username,
        'sdp': sdp.sdp,
        'type': sdp.type
      }
    }));
  }

  /// Gửi ICE candidate
  void sendICE(String to, RTCIceCandidate candidate) {
    if (_channel == null) return;
    print('Thanh Dat: 🧊 Gửi ICE tới $to: ${candidate.candidate}');
    _channel!.sink.add(jsonEncode({
      'type': 'ice',
      'data': {
        'to': to,
        'from': username,
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex
      }
    }));
  }

  /// Gửi tín hiệu dập máy
  void sendHangup(String to) {
    if (_channel == null) return;
    print('Thanh Dat: 📞 Gửi tín hiệu kết thúc cuộc gọi tới $to');
    _channel!.sink.add(jsonEncode({
      'type': 'hangup',
      'data': {
        'to': to,
        'from': username
      }
    }));
  }

  /// Kiểm tra trạng thái kết nối
  bool get isConnected => _isConnected;
}
