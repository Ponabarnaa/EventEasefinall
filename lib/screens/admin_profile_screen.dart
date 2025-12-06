// lib/screens/admin_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  // Get the current logged-in user (Firebase Admin User)
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Determine the user's information
    final String? email = _currentUser?.email;
    final String uid = _currentUser?.uid ?? 'N/A';
    final String displayEmail = email ?? 'Email not available';
    final String initial = email?.isNotEmpty == true
        ? email![0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              // Display Email
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(
                    displayEmail,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Display User ID (Optional, for admin purposes)
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('User ID (UID)'),
                  subtitle: Text(uid),
                ),
              ),
              const SizedBox(height: 40),
              // You can add more profile details or a "Change Password" button here
            ],
          ),
        ),
      ),
    );
  }
}
