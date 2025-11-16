// lib/screens/message_screen.dart
import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Inbox is empty!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'All your event updates and messages will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
