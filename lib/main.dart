import 'package:firebase_auth_flutter/core/theme.dart';
import 'package:firebase_auth_flutter/features/auth/auth_gate.dart';
import 'package:firebase_auth_flutter/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth_flutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Firebase Auth LR16',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
