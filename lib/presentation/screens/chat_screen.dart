import 'dart:async';

import 'package:chat_message_websocket/data/models/message_type.dart';
import 'package:chat_message_websocket/logic/blocs/call/call_state.dart';
import 'package:chat_message_websocket/presentation/screens/video_call_screen.dart';
import 'package:chat_message_websocket/services/WebSocketService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/chat/chat_bloc.dart';
import '../../logic/blocs/chat/chat_state.dart';
import '../../logic/blocs/chat/chat_event.dart';
import '../../data/models/message.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../services/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String currentUsername;
  final String chatPartner;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUsername,
    required this.chatPartner,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Timer? _typingTimer;
  final _textController = TextEditingController();
  Timer? _typingDebounce;
  VideoCallScreen? _currentVideoCallScreen;


  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      final text = _textController.text.trim();
      _typingTimer?.cancel();

      // Gửi `isTyping: false` nếu không còn text
      if (text.isEmpty ) {
        _typingTimer?.cancel();
        _typingDebounce?.cancel();

        context.read<ChatBloc>().add(SendTypingEvent(
          conversationId: widget.conversationId,
          receiver: widget.chatPartner,
          isTyping: false,
        ));
        return;
      }

      // ✅ DEBOUNCE 500ms trước khi gửi `isTyping: true`
      _typingDebounce?.cancel();

      _typingDebounce = Timer(const Duration(milliseconds: 300), () {
        context.read<ChatBloc>().add(SendTypingEvent(
          conversationId: widget.conversationId,
          receiver: widget.chatPartner,
          isTyping: true,
        ));
      });

      // ✅ Sau 2s không gõ nữa thì gửi `false`
      _typingTimer = Timer(const Duration(seconds: 2), () {
        context.read<ChatBloc>().add(SendTypingEvent(
          conversationId: widget.conversationId,
          receiver: widget.chatPartner,
          isTyping: false,
        ));
      });
    });

    context.read<WebSocketService>().onTyping = (conversationId, sender, isTyping) {
      if (conversationId == widget.conversationId && sender == widget.chatPartner) {
        context.read<ChatBloc>().add(
          PartnerTypingChanged(
            sender: sender,
            conversationId: conversationId,
            isTyping: isTyping,
          ),
        );
      }
    };

    // ✅ Sửa: Xử lý cuộc gọi đến
    context.read<WebSocketService>().onIncomingCall = (from, conversationId) {
      if (conversationId == widget.conversationId && from == widget.chatPartner) {
        _handleIncomingCall(from, conversationId);
      }
    };
  }
  // ✅ Sửa: Xử lý cuộc gọi đến đúng cách
  void _handleIncomingCall(String from, String conversationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Cuộc gọi đến'),
        content: Text('$from đang gọi cho bạn'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              // Từ chối cuộc gọi - có thể gửi signal reject
            },
            child: const Text('Từ chối'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              _acceptCall();
            },
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
  }

  // ✅ Sửa: Chấp nhận cuộc gọi
  void _acceptCall() async {
    final granted = await requestCameraAndMicPermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cần quyền camera và microphone để gọi")),
      );
      return;
    }

    try {
      _startVideoCall(isCaller: false);
    } catch (e, stack) {
      print('❌ Lỗi khi chấp nhận cuộc gọi: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể chấp nhận cuộc gọi")),
      );
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _typingDebounce?.cancel();
    // ✅ Sửa: Reset callbacks khi dispose
    context.read<WebSocketService>().onTyping = null;
    context.read<WebSocketService>().onIncomingCall = null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: _prepareCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  print("Loaded messages: ${state.messages.length}");
                  final messages = state.messages;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[messages.length - 1 - index];
                      print("Rendering message at index: ${msg.sender  }");
                      final isMe = msg.sender == widget.currentUsername;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text("Lỗi: ${state.error}"));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    // 👇 Nếu là tin nhắn giả "đang nhập"
    if (msg.isTypingFake) {
      final isMe = msg.sender == widget.currentUsername;
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${msg.sender} đang nhập...",
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 👇 Nội dung hiển thị tùy theo loại
            if (msg.type == MessageType.text && msg.content != null)
              Text(
                msg.content!,
                style: const TextStyle(color: Colors.white),
              )
            else if (msg.type == MessageType.image && msg.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  msg.imageUrl!,
                  errorBuilder: (_, __, ___) =>
                  const Text('[Lỗi ảnh]', style: TextStyle(color: Colors.white)),
                ),
              )
            else if (msg.type == MessageType.file  && msg.fileUrl != null)
                Text('[Tệp] ${msg.fileUrl}',
                    style: const TextStyle(color: Colors.white70))
              else if (msg.type ==  MessageType.sticker && msg.stickerId != null)
                  Text('[Sticker: ${msg.stickerId}]',
                      style: const TextStyle(color: Colors.white70))
                else
                  const Text('[Không xác định]',
                      style: TextStyle(color: Colors.white60)),

            const SizedBox(height: 6),
            Text(
              '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _sendImage,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(hintText: 'Nhập tin nhắn...'),
                onSubmitted: _sendMessage,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(conversationId: widget.conversationId, text: text, type: 'text'));
    _textController.clear();
  }

  void _sendImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      final base64Image = base64Encode(bytes);
      // context.read<ChatCubit>().sendImage(base64Image);
    }
  }

  // ✅ Sửa: Bắt đầu cuộc gọi video với tham số isCaller
  void _startVideoCall({bool isCaller = true}) {
    final ws = context.read<WebSocketService>();

    // ✅ Chỉ gửi call offer nếu là người gọi
    if (isCaller) {
      ws.sendCallOffer(
        conversationId: widget.conversationId,
        sender: widget.currentUsername,
        receiver: widget.chatPartner,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          currentUsername: widget.currentUsername,
          partnerUsername: widget.chatPartner,
          isCaller: isCaller,
        ),
      ),
    ).then((_) {
      // ✅ Reset sau khi pop
      _currentVideoCallScreen = null;
    });
  }

  void _prepareCall() async {
    final granted = await requestCameraAndMicPermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cần quyền camera và microphone để gọi")),
      );
      return;
    }

    try {
      _startVideoCall(isCaller: true); // ✅ Sửa: Truyền tham số isCaller
    } catch (e, stack) {
      print('❌ Lỗi khi bắt đầu cuộc gọi: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể bắt đầu cuộc gọi")),
      );
    }
  }
}