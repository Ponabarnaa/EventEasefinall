// lib/screens/admin_event_detail_screen.dart

import 'package:flutter/material.dart';

// Simple structure for a mock Event
class Event {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
  });
}

class AdminEventDetailScreen extends StatelessWidget {
  final Event event;

  const AdminEventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            _buildDetailRow(context, Icons.calendar_today, 'Date', event.date),
            _buildDetailRow(context, Icons.access_time, 'Time', event.time),
            _buildDetailRow(
              context,
              Icons.location_on,
              'Location',
              event.location,
            ),

            const SizedBox(height: 20),
            Text('Description', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 40),
            // Example of an Admin Action button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement functionality to edit event details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature Tapped!')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Event'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
