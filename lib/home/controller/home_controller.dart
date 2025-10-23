// We no longer need cloud_firestore for this static version
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/home_model.dart';

class HomeController {
  // --- Create Static Data ---

  // Get a date for "tomorrow" and "next week"
  final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  final DateTime nextWeek = DateTime.now().add(const Duration(days: 7));

  // Get a date for "last week" and "last month"
  final DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
  final DateTime lastMonth = DateTime.now().subtract(const Duration(days: 30));

  // A list of all our static events
  late final List<Event> _staticEvents = [
    Event(
      id: '1',
      name: 'Tech Conference 2025',
      description:
          'Join the biggest tech conference of the year. Keynotes, workshops, and networking.',
      location: 'Grand Convention Hall',
      date: tomorrow.copyWith(hour: 9, minute: 0), // Tomorrow at 9:00 AM
      imageUrl:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&q=80',
    ),
    Event(
      id: '2',
      name: 'Annual Music Fest',
      description:
          'Live performances from top bands. Food, fun, and music under the stars.',
      location: 'City Park Amphitheater',
      date: nextWeek.copyWith(hour: 18, minute: 30), // Next week at 6:30 PM
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=80',
    ),
    Event(
      id: '3',
      name: 'Flutter Workshop',
      description:
          'A deep dive into Flutter state management and advanced animations.',
      location: 'Online / Virtual',
      date: lastWeek.copyWith(hour: 10, minute: 0), // Last week at 10:00 AM
      imageUrl:
          'https://images.unsplash.com/photo-1633356122102-3fe601e05a7c?w=600&q=80',
    ),
    Event(
      id: '4',
      name: 'Design Thinking Seminar',
      description:
          'Learn the principles of design thinking to solve complex problems.',
      location: 'University Library, Room 204',
      date: lastMonth.copyWith(hour: 14, minute: 0), // Last month at 2:00 PM
      imageUrl:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600&q=80',
    ),
  ];

  /// Gets all static events
  List<Event> getAllEvents() {
    return _staticEvents;
  }

  /// Gets a stream of UPCOMING events.
  Stream<List<Event>> getUpcomingEvents() {
    final now = DateTime.now();

    // Filter the list to find events happening "now" or in the future
    final upcoming = _staticEvents
        .where(
          (event) =>
              event.date.isAfter(now) || event.date.isAtSameMomentAs(now),
        )
        .toList();

    // Sort them to show the nearest event first
    upcoming.sort((a, b) => a.date.compareTo(b.date));

    // Return the list as a broadcast stream to allow multiple listeners
    return Stream.value(upcoming).asBroadcastStream();
  }

  /// Gets a stream of PAST events.
  Stream<List<Event>> getPastEvents() {
    final now = DateTime.now();

    // Filter the list to find events that happened in the past
    final past = _staticEvents
        .where((event) => event.date.isBefore(now))
        .toList();

    // Sort them to show the most recent past event first
    past.sort((a, b) => b.date.compareTo(a.date));

    // Return the list as a broadcast stream to allow multiple listeners
    return Stream.value(past).asBroadcastStream();
  }
}
