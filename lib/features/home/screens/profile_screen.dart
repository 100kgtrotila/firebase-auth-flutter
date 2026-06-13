import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: user == null ? _buildLoggedOutState() : _buildProfile(user),
        ),
      ),
    );
  }

  Widget _buildLoggedOutState() {
    return const Center(child: Text('Please login to view this page.'));
  }

  Widget _buildProfile(User user) {
    final name = user.displayName?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('UID'),
                subtitle: Text(user.uid),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Name'),
                subtitle: Text(name == null || name.isEmpty ? 'User' : name),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email ?? 'No email'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
