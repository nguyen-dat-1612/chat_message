import 'package:chat_message_websocket/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'core/constants.dart';
import 'screens/chat_page.dart';


class MyApp extends StatelessWidget {
  final String? initialUsername;
  final String? initialToken;
  const MyApp({super.key, this.initialUsername, this.initialToken});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: initialUsername != null && initialToken != null
          ? ChatPage(username: initialUsername!, channel: WebSocketChannel.connect(Uri.parse("$baseSocket?token=$initialToken")))
          : const LoginPage(),
      debugShowCheckedModeBanner: false
    );
  }
}
