// lib/screens/participation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipationListScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  const ParticipationListScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  // Function to get the real-time stream of participants
  Stream<QuerySnapshot> _getParticipantsStream() {
    // Assumes participants are stored in a subcollection: events/{eventId}/participants
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .orderBy(
          'registeredAt',
          descending: false,
        ) // Assuming a timestamp field 'registeredAt' exists
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participants for: $eventName'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getParticipantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading participants: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sentiment_dissatisfied,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No participants have registered for "$eventName" yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final participants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant =
                  participants[index].data() as Map<String, dynamic>;

              // Assuming participant document contains: name, email, department, year
              final String name = participant['name'] ?? 'N/A';
              final String email = participant['email'] ?? 'N/A';
              final String dept = participant['department'] ?? 'N/A';
              final String year = participant['year'] ?? 'N/A';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    foregroundColor: Colors.teal,
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: $email'),
                      Text('Dept: $dept, Year: $year'),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
