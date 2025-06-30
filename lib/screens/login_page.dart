import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../core/constants.dart';
import '../models/auth_model.dart';
import '../repositories/auth_repository.dart';
import 'chat_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final  _usernameController = TextEditingController();
  final  _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _enterChat(AuthModel auth) {
    final String username = _usernameController.text.trim();
    if (username.isEmpty)  return;
    final channel = WebSocketChannel.connect(Uri.parse("${baseSocket}?token=${auth.token}"));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(channel: channel, username: username)
      )
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            AuthBloc(
              authRepository: AuthRepository(client: http.Client()),
            ),
        child: Scaffold(
            appBar: AppBar(title: const Text('Đăng nhập vào ứng dụng')),
            body: BlocConsumer <AuthBloc, AuthState>(
              listener: (context, state)  {
                if (state is AuthSuccess) {
                  _enterChat(state.authModel);
                }
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.err))
                  );
                }
              }, builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên người dùng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Mật khẩu',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                LoginEvent(
                                  username: _usernameController.text,
                                  password: _passwordController.text,
                                ),
                              );
                            },
                            child: const Text('Đăng nhập')
                        )
                      ]
                  ),
                );
              },
            )
        )
    );
  }
}
