import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'certificate_generator_screen.dart';
import 'admin_event_participants_screen.dart';
import 'admin_create_event_screen.dart';

class Event {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;
  final String posterUrl;
  final String status;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.status,
    this.posterUrl = '',
  });
}

class AdminEventDetailScreen extends StatelessWidget {
  final Event event;

  const AdminEventDetailScreen({super.key, required this.event});

  Future<void> _deleteEvent(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Event?"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEventScreen(eventToEdit: event))),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteEvent(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Poster Image
            if (event.posterUrl.isNotEmpty)
              Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: NetworkImage(event.posterUrl), fit: BoxFit.cover),
                ),
              )
            else
              Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.image, size: 50)),
            
            const SizedBox(height: 20),
            
            // Details
            _buildDetailRow(context, Icons.calendar_today, "Date", "${event.date} at ${event.time}"),
            _buildDetailRow(context, Icons.location_on, "Venue", event.location),
            _buildDetailRow(context, Icons.info, "Status", event.status.toUpperCase()),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // BUTTON 1: View Participants
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text("View Registered Participants"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEventParticipantsScreen(eventId: event.id, eventName: event.title)));
                },
              ),
            ),
            
            const SizedBox(height: 15),

            // BUTTON 2: Generate Certificates
            // This button is now ALWAYS VISIBLE regardless of status
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], 
                  foregroundColor: Colors.white
                ),
                icon: const Icon(Icons.workspace_premium),
                label: const Text("Generate Certificates"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CertificateGeneratorScreen(eventName: event.title)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [Icon(icon, color: Theme.of(context).primaryColor), const SizedBox(width: 10), Expanded(child: Text(value, style: const TextStyle(fontSize: 16)))]),
    );
  }
}