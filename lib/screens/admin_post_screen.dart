// lib/screens/admin_post_screen.dart

import 'package:flutter/material.dart';
import 'create_event_screen.dart'; // Import the Event Creation Page

class AdminPostScreen extends StatelessWidget {
  const AdminPostScreen({super.key});

  // Function to navigate to the Event Creation Page
  void _navigateToCreateEvent(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateEventScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Central Post Button
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateEvent(context),
            icon: const Icon(Icons.star, color: Colors.white),
            label: const Text('Post', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, // Indigo color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
