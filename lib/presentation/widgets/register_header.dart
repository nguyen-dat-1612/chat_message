import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/messenger_logo.png',
          height: 100,
        ),
        const SizedBox(height: 16),
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
