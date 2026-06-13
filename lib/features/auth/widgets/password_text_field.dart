import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    required this.controller,
    required this.labelText,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscureText ? 'Show password' : 'Hide password',
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}
