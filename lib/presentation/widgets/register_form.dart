import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../logic/blocs/auth/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildInput(
            controller: _usernameController,
            hint: 'Username',
            icon: Icons.person_outline,
            validator: (v) =>
            (v == null || v.length < 4) ? 'Tối thiểu 4 ký tự' : null,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _emailController,
            hint: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
            (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _displayNameController,
            hint: 'Display name (tuỳ chọn)',
            icon: Icons.face,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _passwordController,
            hint: 'Password',
            obscure: _obscurePassword,
            toggle: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hint: 'Confirm Password',
            obscure: _obscureConfirmPassword,
            toggle: () =>
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            validator: (v) =>
            v != _passwordController.text ? 'Mật khẩu không khớp' : null,
          ),
          const SizedBox(height: 32),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthRegisterSuccess) {
                context.goNamed('login');
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.err),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) return const CircularProgressIndicator();

              return Column(
                children: [
                  FilledButton(
                    onPressed: _submitForm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create Account'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.goNamed('login'),
                    child: const Text(
                      "Already have an account? Log in",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterEvent(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
      ));
    }
  }
}
