import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_flutter/features/auth/screens/login_screen.dart';
import 'package:firebase_auth_flutter/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Authentication state error. Please restart the app.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
