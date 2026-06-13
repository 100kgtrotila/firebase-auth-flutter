import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:firebase_auth_flutter/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/auth_submit_button.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/auth_text_field.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final error = await context.read<AuthProvider>().signUp(
      name: _nameController.text,
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
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    controller: _nameController,
                    labelText: 'Name',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthSubmitButton(
                    text: 'CREATE ACCOUNT',
                    isLoading: isLoading,
                    onPressed: _signUp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
