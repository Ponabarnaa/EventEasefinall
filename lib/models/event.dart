class EventDetails {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;
  final String status;
  final String posterUrl; // <--- Add this

  EventDetails({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.status,
    required this.posterUrl, // <--- Add this
  });

  // Update your factory method to read the URL from Firestore
  factory EventDetails.fromFirestore(Map<String, dynamic> data, String id) {
    return EventDetails(
      id: id,
      title: data['name'] ?? 'No Title',
      // Handle the complex date string if needed, or just pass it
      date: data['dateTime']?.split(' at ')[0] ?? '', 
      time: data['dateTime']?.split(' at ')[1] ?? '',
      location: data['venue'] ?? '',
      description: "Dept: ${data['department']} | Year: ${data['year']}",
      status: data['status'] ?? 'Upcoming',
      posterUrl: data['posterUrl'] ?? '', // <--- Fetch the URL here
    );
  }
}