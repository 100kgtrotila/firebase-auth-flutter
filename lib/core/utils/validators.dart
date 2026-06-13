class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
