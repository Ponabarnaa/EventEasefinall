// lib/screens/admin_events_screen.dart (UPDATED)

import 'package:flutter/material.dart';
import 'admin_event_detail_screen.dart'; // Import the new detail screen

// Mock Event data for demonstration
const List<Event> _mockEvents = [
  Event(
    id: 'e1',
    title: 'Community Clean-up Drive',
    date: 'December 15, 2025',
    time: '9:00 AM - 12:00 PM',
    location: 'Central Park Entrance',
    description:
        'Join us for our annual community clean-up drive. Supplies will be provided. Please wear comfortable clothes and shoes.',
  ),
  Event(
    id: 'e2',
    title: 'Year-End Gala Dinner',
    date: 'December 31, 2025',
    time: '7:00 PM onwards',
    location: 'Grand Ballroom, City Hall',
    description:
        'A formal event to celebrate the achievements of the year. RSVP required by Dec 20th. Dress code: Black Tie.',
  ),
  Event(
    id: 'e3',
    title: 'Upcoming Events Tab Test',
    date: 'January 10, 2026',
    time: '4:00 PM - 5:00 PM',
    location: 'Online Webinar',
    description:
        'This is a test event for the upcoming events tab. Check the details and navigation.',
  ),
];

// Helper to filter events based on the tab
enum EventFilter { upcoming, ongoings, completed }

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EventFilter _currentFilter = EventFilter.upcoming;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentFilter = EventFilter.upcoming;
            break;
          case 1:
            _currentFilter = EventFilter.ongoings;
            break;
          case 2:
            _currentFilter = EventFilter.completed;
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  // NOTE: In a real app, this function would filter events based on their actual date/status
  List<Event> _getFilteredEvents() {
    if (_currentFilter == EventFilter.completed) {
      // Show only one completed event for visual distinction
      return [_mockEvents[0].copyWith(title: 'Completed: Clean-up Drive')];
    }
    // For Upcoming and Ongoings, we'll just show the main list for the mock
    return _mockEvents;
  }

  // --- Widget for a single event item ---
  Widget _buildEventItem(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(event.date, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 15),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(event.time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 15),
            // The "View details" button
            ElevatedButton.icon(
              icon: const Icon(Icons.star), // Icon from your mockup
              label: const Text('View details'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdminEventDetailScreen(event: event),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Column(
      children: [
        // Tab Bar for Upcoming/Ongoings/Completed Events
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Upcoming Events'),
            Tab(text: 'Ongoings Events'),
            Tab(text: 'Completed events'),
          ],
        ),

        // Event List
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    'Event list',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: filteredEvents.isEmpty
                      ? const Center(
                          child: Text('No events found for this category.'),
                        )
                      : ListView.builder(
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            return _buildEventItem(
                              context,
                              filteredEvents[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Extension to allow copying of the mock Event object with modifications
extension on Event {
  Event copyWith({String? title}) {
    return Event(
      id: id,
      title: title ?? this.title,
      date: date,
      time: time,
      location: location,
      description: description,
    );
  }
}
