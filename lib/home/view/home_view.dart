import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../controller/home_controller.dart';
import '../model/home_model.dart';
import '../../auth/controller/auth_controller.dart'; // To handle sign out

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instantiate controllers
    final HomeController homeController = HomeController();
    final AuthController authController = AuthController();

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
                authController.signOut();
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
            EventList(stream: homeController.getUpcomingEvents()),

            // --- PAST EVENTS TAB ---
            EventList(stream: homeController.getPastEvents()),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget to display a list of events from a stream.
class EventList extends StatelessWidget {
  final Stream<List<Event>> stream;

  const EventList({Key? key, required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: stream,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error State
        if (snapshot.hasError) {
          // You can log the error: print(snapshot.error);
          return const Center(
            child: Text(
              'Error loading events.\nHave you created the Firestore index?',
              textAlign: TextAlign.center,
            ),
          );
        }

        // 3. No Data State
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No events found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // 4. Data Ready State
        final events = snapshot.data!;
        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(event: event);
          },
        );
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
