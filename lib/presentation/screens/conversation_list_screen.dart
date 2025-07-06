import 'package:chat_message_websocket/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/simple_user.dart';
import '../../logic/blocs/contact/contact_bloc.dart';
import '../../logic/blocs/contact/contact_event.dart';
import '../../logic/blocs/contact/contact_state.dart';
import '../../logic/blocs/conversation/conversation_bloc.dart';
import '../../logic/blocs/conversation/conversation_event.dart';
import '../../logic/blocs/conversation/conversation_state.dart';
import '../../services/WebSocketService.dart';
import '../widgets/conversation_item.dart';
import '../widgets/search_user_bar.dart';

class ConversationListScreen extends StatefulWidget {
  final User currentUser;

  const ConversationListScreen({super.key, required this.currentUser});

  @override
  State<ConversationListScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    final initialContacts = widget.currentUser.contacts.map((contact) {
      final user = contact.user;
      return SimpleUser(
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        status: 'offline',
        lastSeen: user.lastSeen,
      );
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactBloc>().add(SetInitialContacts(initialContacts));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = context.read<WebSocketService>();
      final bloc = context.read<ConversationBloc>();

      // Gán callback nhận cập nhật hội thoại từ socket
      socket.onConversationUpdate = (conversationId, message) {
        bloc.add(UpdateLastMessageEvent(
          conversationId: conversationId,
          message: message,
        ));
      };

      context.read<ContactBloc>().add(SetInitialContacts(initialContacts));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2FEFA), // xanh nhạt
              Color(0xFFFA709A), // hồng nhạt
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 16),
                            child: Text(
                              'Messages',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SearchUserBar(),
                        const SizedBox(height: 8),
                        BlocBuilder<ContactBloc, ContactState>(
                          builder: (context, state) {
                            if (state is ContactLoaded) {
                              return _buildContactList(state.contacts);
                            }
                            if (state is ContactLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<ConversationBloc, ConversationState>(
                          builder: (context, state) {
                            if (state is ConversationLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state is ConversationSuccess) {
                              final conversations = state.conversations;
                              if (conversations.isEmpty) {
                                return const Center(
                                  child: Text("Không có cuộc trò chuyện nào"),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: conversations.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final conversation = conversations[index];
                                  return ConversationItem(
                                    conversation: conversation,
                                    currentUsername: widget.currentUser.username,
                                  );
                                },
                              );
                            }
                            if (state is ConversationFailure) {
                              return Center(child: Text('Lỗi: ${state.err}'));
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContactList(List<SimpleUser> contacts) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final user = contacts[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.status == 'online' ? Colors.green : Colors.grey,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
