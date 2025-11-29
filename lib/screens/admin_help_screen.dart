// lib/screens/admin_help_screen.dart

import 'package:flutter/material.dart';

class AdminHelpScreen extends StatelessWidget {
  const AdminHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Admin Help & Support',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          Text(
            'Content for the Help/Profile section goes here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
