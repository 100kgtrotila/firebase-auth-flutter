import 'package:flutter/material.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text),
      ),
    );
  }
}
