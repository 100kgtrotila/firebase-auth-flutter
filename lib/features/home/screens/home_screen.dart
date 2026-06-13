import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_auth_flutter/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth_flutter/features/home/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    final error = await context.read<AuthProvider>().signOut();

    if (!context.mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _openProfile(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to view this page.')),
      );
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    final displayName = name == null || name.isEmpty ? 'User' : name;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: isLoading ? null : () => _confirmLogout(context),
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $displayName',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(user?.email ?? 'No email'),
                      const SizedBox(height: 16),
                      const Text(
                        '✅ You are logged in!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openProfile(context),
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Open Protected Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
