import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_flutter/core/utils/auth_error_mapper.dart';
import 'package:firebase_auth_flutter/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _runAuthAction(
      () => _authService.signUp(name: name, email: email, password: password),
    );
  }

  Future<String?> signIn({required String email, required String password}) {
    return _runAuthAction(
      () => _authService.signIn(email: email, password: password),
    );
  }

  Future<String?> resetPassword(String email) {
    return _runAuthAction(() => _authService.sendPasswordResetEmail(email));
  }

  Future<String?> signOut() {
    return _runAuthAction(_authService.signOut);
  }

  Future<String?> _runAuthAction(Future<void> Function() action) async {
    _setLoading(true);

    try {
      await action();
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthErrorMapper.messageFromCode(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
