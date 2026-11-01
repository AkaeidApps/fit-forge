import 'package:flutter/material.dart';

import '../core/responsive_content.dart';
import '../core/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Join FITFORGE and start your fitness journey',
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 30),
            _inputField('Full Name', Icons.person, required: true),
            const SizedBox(height: 16),
            _inputField(
              'Email Address',
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                    ? null
                    : 'Enter a valid email address';
              },
            ),
            const SizedBox(height: 16),
            _inputField(
              'Password',
              Icons.lock,
              obscure: true,
              controller: _passwordController,
              validator: (value) => (value?.length ?? 0) < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 16),
            _inputField(
              'Confirm Password',
              Icons.lock,
              obscure: true,
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account details validated successfully'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Sign Up'),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String hint,
    IconData icon, {
    bool obscure = false,
    bool required = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppTheme.cardDarkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator ??
          (required
              ? (value) => value == null || value.trim().isEmpty
                  ? 'This field is required'
                  : null
              : null),
    );
  }
}
