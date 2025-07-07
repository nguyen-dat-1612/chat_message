import 'package:chat_message_websocket/data/repositories/message_repository.dart';
import 'package:chat_message_websocket/presentation/screens/home_screen.dart';
import 'package:chat_message_websocket/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/conversation.dart';
import '../../logic/blocs/chat/chat_bloc.dart';
import '../../logic/blocs/chat/chat_event.dart';
import '../screens/chat_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true, // Bật log debug cho routing
      routes: [
        GoRoute(
          path: '/login',
          name: 'login', // Thêm tên route để dễ điều hướng
          pageBuilder: (context, state) =>
              MaterialPage(
                key: state.pageKey,
                child: const LoginScreen(),
              ),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (context, state) =>
              MaterialPage(
                key: state.pageKey,
                child: const RegisterScreen(),
              ),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) =>
              MaterialPage(
                key: state.pageKey,
                child: HomeScreen(),
              ),
        ),
        GoRoute(
          path: '/message',
          name: 'message',
          pageBuilder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            final conversation = data['conversation'] as Conversation;
            final currentUsername = data['currentUsername'] as String;
            final chatPartner = conversation.participants.firstWhere(
                  (p) => p != currentUsername,
              orElse: () => '',
            );
            return MaterialPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) =>
                ChatBloc(
                  webSocket: context.read<WebSocketService>(),
                  repository: MessageRepository(),
                )
                  ..add(FetchMessages(conversationId: conversation.id)),
                child: ChatScreen(
                  conversationId: conversation.id,
                  currentUsername: currentUsername,
                  chatPartner: chatPartner,
                ),
              ),
            );
          },
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(
            body: Center(
              child: Text('Route not found: ${state.error}'),
            ),
          ),
    );
  }
}