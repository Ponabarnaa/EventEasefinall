// 
// lib/screens/admin_event_detail_screen.dart

import 'package:flutter/material.dart';
import 'admin_event_participants_screen.dart'; // <--- Import the new screen

// Ensure your Event class definition is consistent
class Event {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;
  final String posterUrl; // Ensure this is here if you want the image

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    this.posterUrl = '', // Default to empty string if missing
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
            // Display Poster if available
            if (event.posterUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(event.posterUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

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
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Column(
              children: [
                // 1. View Participants Button (NEW)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEventParticipantsScreen(
                            eventId: event.id,
                            eventName: event.title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('View Participants'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Distinct color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),

                // 2. Edit Event Button (Existing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit functionality pending')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Event'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
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