import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_auth_flutter/core/utils/snack_bar_helper.dart';
import 'package:firebase_auth_flutter/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth_flutter/features/home/screens/profile_screen.dart';
import 'package:firebase_auth_flutter/features/notes/screens/notes_screen.dart';
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
      SnackBarHelper.showMessage(context, error);
    }
  }

  void _openProfile(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      SnackBarHelper.showMessage(context, 'Please login to view this page.');
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _openNotes(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      SnackBarHelper.showMessage(context, 'Please login to view your notes.');
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotesScreen()));
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $displayName',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.email ?? 'No email',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'You are logged in!',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _openNotes(context),
                  icon: const Icon(Icons.note_alt_outlined),
                  label: const Text('My Notes'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openProfile(context),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Open Protected Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
