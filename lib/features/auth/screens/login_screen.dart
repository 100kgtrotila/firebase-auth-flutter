import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:firebase_auth_flutter/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth_flutter/features/auth/screens/forgot_password_screen.dart';
import 'package:firebase_auth_flutter/features/auth/screens/sign_up_screen.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/auth_submit_button.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/auth_text_field.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final error = await context.read<AuthProvider>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('🔐 Welcome')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.validatePassword,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthSubmitButton(
                      text: 'LOGIN',
                      isLoading: isLoading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                      child: const Text("Don't have account? Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
