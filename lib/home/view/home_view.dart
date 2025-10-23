import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../controller/home_controller.dart';
import '../model/home_model.dart';
import '../../auth/controller/auth_controller.dart'; // To handle sign out

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Create controller once and keep it
  late final HomeController _homeController;
  late final AuthController _authController;

  // Store the event lists directly instead of streams
  late final List<Event> _upcomingEvents;
  late final List<Event> _pastEvents;

  @override
  void initState() {
    super.initState();
    _homeController = HomeController();
    _authController = AuthController();

    // Get the events once during initialization
    final now = DateTime.now();
    final allEvents = _homeController.getAllEvents();

    _upcomingEvents =
        allEvents
            .where(
              (event) =>
                  event.date.isAfter(now) || event.date.isAtSameMomentAs(now),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    _pastEvents = allEvents.where((event) => event.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Upcoming and Past
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Dashboard'),
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          actions: [
            // Sign Out Button
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () {
                // Call the AuthController to sign out
                _authController.signOut();
                // The AuthGate in main.dart will handle navigation
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming Events'),
              Tab(text: 'Past Events'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.blue,
          ),
        ),
        body: TabBarView(
          children: [
            // --- UPCOMING EVENTS TAB ---
            StaticEventList(events: _upcomingEvents),

            // --- PAST EVENTS TAB ---
            StaticEventList(events: _pastEvents),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget to display a static list of events (no streams).
class StaticEventList extends StatelessWidget {
  final List<Event> events;

  const StaticEventList({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no events, show empty state
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Display the events
    return ListView.builder(
      itemCount: events.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(event: event);
      },
    );
  }
}

/// A reusable card widget to display a single event's details.
class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date nicely
    final String formattedDate = DateFormat.yMMMd().add_jm().format(event.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Clips the image
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          if (event.imageUrl.isNotEmpty)
            Image.network(
              event.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              // Show a placeholder while loading
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      );
              },
              // Show an icon if the image fails to load
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 180,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name
                Text(
                  event.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Date and Time
                InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: formattedDate,
                ),
                const SizedBox(height: 8),

                // Location
                InfoRow(icon: Icons.location_on_outlined, text: event.location),
                const SizedBox(height: 12),

                // Description
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small helper widget for icon + text rows
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({Key? key, required this.icon, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.titleSmall),
        ),
      ],
    );
  }
}
