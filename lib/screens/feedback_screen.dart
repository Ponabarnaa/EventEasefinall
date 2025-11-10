// lib/screens/feedback_screen.dart
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.feedback, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Share Your Feedback',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'We value your input! Please provide your feedback to help us improve.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Implement feedback form navigation or dialog here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback form coming soon!')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Give Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}