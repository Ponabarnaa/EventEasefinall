import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
  });

  /// Factory constructor to create an Event from a Firestore document.
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      description: data['description'] ?? 'No Description',
      location: data['location'] ?? 'No Location',
      // Convert Firestore Timestamp to DateTime
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '', // Handle missing image URL
    );
  }
}
