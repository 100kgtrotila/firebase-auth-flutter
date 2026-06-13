import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:firebase_auth_flutter/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/auth_submit_button.dart';
import 'package:firebase_auth_flutter/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final error = await context.read<AuthProvider>().resetPassword(
      _emailController.text,
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

    setState(() {
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessState(context) : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            text: 'SEND RESET LINK',
            isLoading: isLoading,
            onPressed: _sendResetLink,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text('Email Sent!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Check your email inbox and follow the reset link.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}
