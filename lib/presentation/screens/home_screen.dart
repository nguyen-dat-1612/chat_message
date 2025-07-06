import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_message_websocket/data/repositories/user_repository.dart';
import 'package:chat_message_websocket/data/repositories/conversation_repository.dart';
import 'package:chat_message_websocket/services/WebSocketService.dart';
import 'package:chat_message_websocket/logic/blocs/user/home_bloc.dart';
import 'package:chat_message_websocket/logic/blocs/user/home_event.dart';
import 'package:chat_message_websocket/logic/blocs/user/home_state.dart';
import 'package:chat_message_websocket/logic/blocs/conversation/conversation_bloc.dart';
import 'package:chat_message_websocket/logic/blocs/contact/contact_bloc.dart';
import 'package:chat_message_websocket/presentation/screens/conversation_list_screen.dart';
import 'package:chat_message_websocket/presentation/screens/user_profile_screen.dart';
import '../../logic/blocs/conversation/conversation_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final webSocket = context.read<WebSocketService>();
    print("Rebuild Home Screen");
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc(
            repository: UserRepository(),
            webSocket: webSocket,
          )..add(FetchUserEvent()),
        ),
        BlocProvider(
          create: (_) => ConversationBloc(
            repository: ConversationRepository(),
            socket: webSocket,
          )..add(FetchConversationsEvent()),
        ),
        BlocProvider(
          create: (_) => ContactBloc(socket: webSocket),
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is UserSuccess) {
            final currentUser = state.currentUser;

            return Scaffold(
              body: [
                ConversationListScreen(currentUser: currentUser),
                UserProfileScreen(currentUser: currentUser),
              ][_selectedIndex],
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline, size: 28),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline, size: 28),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is UserFailure) {
            return Center(child: Text('Lỗi tải thông tin user: ${state.err}'));
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

