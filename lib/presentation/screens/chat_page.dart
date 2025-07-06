//
// import 'dart:convert';
//
// import 'package:chat_message_websocket/models/message.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';
// import 'login_page.dart';
//
// class ChatPage extends StatelessWidget {
//   final String username;
//   final WebSocketChannel channel;
//
//   const ChatPage({
//     super.key,
//     required this.username,
//     required this.channel,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ChatBloc(channel: channel)..add(ConnectToChat(username: username)),
//       child: Builder(
//         builder: (context) {
//           final navigator = Navigator.of(context, rootNavigator: true);
//
//           return BlocListener<ChatBloc, ChatState>(
//             listener: (context, state) {
//               if (state is ChatError) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.err)),
//                 );
//               } else if (state is ChatDisconnected) {
//                 navigator.pushReplacement(
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                 );
//               }
//             },
//             child: Scaffold(
//               appBar: AppBar(
//                 title: const Text('💬 Chat App'),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.logout),
//                     onPressed: () => _logout(context),
//                   )
//                 ],
//               ),
//               body: BlocBuilder<ChatBloc, ChatState>(
//                 builder: (context, state) {
//                   if (state is ChatConnected) {
//                     return _ChatView(
//                       messages: state.messages,
//                       onlineUsers: state.onlineUsers,
//                       username: username,
//                       channel: channel,
//                     );
//                   } else if (state is ChatError) {
//                     return Center(child: Text('Error: ${state.err}'));
//                   }
//                   return const Center(child: CircularProgressIndicator());
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//   void _logout(BuildContext context) {
//     context.read<ChatBloc>().add(Disconnect());
//   }
// }
//
// class _ChatView extends StatelessWidget {
//   final List<Message> messages;
//   final List<String> onlineUsers;
//   final String username;
//   final WebSocketChannel channel;
//
//   const _ChatView({
//     required this.messages,
//     required this.onlineUsers,
//     required this.username,
//     required this.channel,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final textController = TextEditingController();
//
//     return Column(
//       children: [
//         // Online users list
//         SizedBox(
//           height: 40,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: onlineUsers.length,
//             itemBuilder: (context, index) {
//               final name = onlineUsers[index];
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 6),
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.green[700],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(name, style: const TextStyle(color: Colors.white)),
//               );
//             },
//           ),
//         ),
//
//         // Messages list
//         Expanded(
//           child: ListView.builder(
//             reverse: true,
//             itemCount: messages.length,
//             itemBuilder: (context, i) {
//               final msg = messages[messages.length - 1 - i];
//               final isMe = msg.username == username;
//               return _buildMessageBubble(msg, isMe, Key(msg.id)); // 👈 thêm key
//             },
//           ),
//         ),
//
//         // Message input
//         _MessageInput(
//           controller: textController,
//           username: username,
//           onSendMessage: (text) {
//             context.read<ChatBloc>().add(SendMessage(text: text, username: username));
//             textController.clear();
//           },
//           onSendImage: () async {
//             final image = await ImagePicker().pickImage(source: ImageSource.gallery);
//             if (image != null) {
//               final bytes = await image.readAsBytes();
//               final base64Image = base64Encode(bytes);
//               context.read<ChatBloc>().add(SendImage(base64Image: base64Image, username: username));
//             }
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMessageBubble(Message msg, bool isMe, Key key) {
//     return KeyedSubtree(
//       key: key,
//       child: () {
//         if (msg.username == '📢 Hệ thống') {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 msg.text,
//                 style: const TextStyle(
//                     color: Colors.orange, fontWeight: FontWeight.bold),
//               ),
//             ),
//           );
//         }
//         if (msg.imageBase64 != null) {
//           return Align(
//             alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//             child: Column(
//               crossAxisAlignment:
//               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   margin: const EdgeInsets.all(8),
//                   constraints: const BoxConstraints(maxWidth: 250),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.memory(base64Decode(msg.imageBase64!)),
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}",
//                       style: const TextStyle(fontSize: 10, color: Colors.white60),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       msg.isPending ? Icons.hourglass_bottom : Icons.check,
//                       size: 14,
//                       color: Colors.white54,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Align(
//           alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//             padding: const EdgeInsets.all(10),
//             constraints: const BoxConstraints(maxWidth: 280),
//             decoration: BoxDecoration(
//               color: isMe ? Colors.blue : Colors.grey[800],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment:
//               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg.username,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.white70),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   msg.text,
//                   style: const TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//                 const SizedBox(height: 4),
//                 if (isMe)
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         "${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}",
//                         style:
//                         const TextStyle(fontSize: 10, color: Colors.white60),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         msg.isPending ? Icons.hourglass_bottom : Icons.check,
//                         size: 14,
//                         color: Colors.white54,
//                       ),
//                     ],
//                   )
//                 else
//                   Text(
//                     "${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}",
//                     style: const TextStyle(fontSize: 10, color: Colors.white60),
//                   ),
//               ],
//             ),
//           ),
//         );
//       }(),
//     );
//   }
// }
//
// class _MessageInput extends StatelessWidget {
//   final TextEditingController controller;
//   final String username;
//   final Function(String) onSendMessage;
//   final Function() onSendImage;
//
//   const _MessageInput({
//     required this.controller,
//     required this.username,
//     required this.onSendMessage,
//     required this.onSendImage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.image),
//             onPressed: onSendImage,
//           ),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 hintText: "Nhập tin nhắn...",
//                 border: OutlineInputBorder(),
//               ),
//               onSubmitted: onSendMessage,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: () => onSendMessage(controller.text),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
