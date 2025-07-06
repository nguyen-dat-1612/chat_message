import 'package:flutter/material.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight, // fix trắng dưới
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB2FEFA), // xanh mint nhạt
                  Color(0xFFFA709A), // hồng dâu nhạt
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      SizedBox(height: 64),
                      LoginHeader(),
                      SizedBox(height: 32.0),
                      LoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}