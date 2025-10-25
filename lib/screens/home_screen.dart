// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login&register.dart'; // Import for navigation on logout

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Mock Data for Events ---
  // In a real app, you'd fetch this from Firestore
  final List<Map<String, String>> mockEvents = const [
    {
      "name": "Global Tech Summit 2025",
      "date": "Oct 28, 2025",
      "location": "Metropolis Convention Center"
    },
    {
      "name": "Indie Music Festival",
      "date": "Nov 1-2, 2025",
      "location": "City Park Amphitheater"
    },
    {
      "name": "Startup Pitch Night",
      "date": "Nov 5, 2025",
      "location": "Innovation Hub"
    },
    {
      "name": "Community Food Fair",
      "date": "Nov 12, 2025",
      "location": "Downtown Plaza"
    },
  ];

  // --- Logout Function ---
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to login screen and remove all other routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
        (Route<dynamic> route) => false, // This predicate removes all routes
      );
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log out: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Use user's display name, or "Events" as a fallback
          user?.displayName == null || user!.displayName!.isEmpty
              ? 'Upcoming Events'
              : 'Welcome, ${user.displayName}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockEvents.length,
        itemBuilder: (context, index) {
          final event = mockEvents[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Icon(
                Icons.event_available,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              ),
              title: Text(
                event['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${event['date']} • ${event['location']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // TODO: Navigate to event details screen
                print('Tapped on ${event['name']}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to a "Create Event" screen
        },
        tooltip: 'Create Event',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}