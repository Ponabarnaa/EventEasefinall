import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetails {
  final String name;
  final String venue;
  final String time;
  final String department;
  final String posterUrl;
  final String status;
  final Timestamp createdAt;

  EventDetails({
    required this.name,
    required this.venue,
    required this.time,
    required this.department,
    required this.posterUrl,
    required this.status,
    required this.createdAt,
  });

  factory EventDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventDetails(
      name: data['name'] ?? '',
      venue: data['venue'] ?? '',
      time: data['time'] ?? '',
      department: data['department'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      status: data['status'] ?? 'Upcoming',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
