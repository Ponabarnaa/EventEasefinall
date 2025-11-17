// lib/models/event.dart

class EventDetails {
  final String name;
  final String date;
  final String location;
  final String type;
  final String description;
  final String imageUrl;

  // --- ADD THESE NEW FIELDS ---
  // Make them optional (nullable) by adding the '?'
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

    // --- ADD THEM TO THE CONSTRUCTOR ---
    this.coordinatorName,
    this.coordinatorPhone,
    this.time,
  });
}
