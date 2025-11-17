//
// lib/models/event.dart

class EventDetails {
  final String name;
  final String date;
  final String location;
  final String type;
  final String description;
  final String imageUrl;
  final String? coordinatorName;
  final String? coordinatorPhone;
  final String? time;

  EventDetails({
    required this.name,
    required this.date,
    required this.location,
    required this.type,
    required this.description,
    required this.imageUrl,
    this.coordinatorName,
    this.coordinatorPhone,
    this.time,
  });
}
