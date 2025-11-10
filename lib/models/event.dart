// lib/models/event.dart

class EventDetails {
  final String name;
  final String date;
  final String location;
  final String type;
  final String description;
  final String imageUrl;

  const EventDetails({
    required this.name,
    required this.date,
    required this.location,
    required this.type,
    required this.description,
    required this.imageUrl,
  });
}