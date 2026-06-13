import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }
}
