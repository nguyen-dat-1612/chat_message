// features/auth/widgets/login_header.dart
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Messenger
        Image.asset(
          'assets/images/messenger_logo.png', // bạn phải có file ảnh và khai báo pubspec.yaml
          height: 100,
        ),
        const SizedBox(height: 16),
        const Text(
          'Log in with your my account',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
