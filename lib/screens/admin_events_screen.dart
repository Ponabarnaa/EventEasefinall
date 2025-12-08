import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_event_detail_screen.dart';

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
          case 0: _currentFilter = EventFilter.upcoming; break;
          case 1: _currentFilter = EventFilter.ongoings; break;
          case 2: _currentFilter = EventFilter.completed; break;
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

  Widget _buildEventItem(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: Container(
        // padding: const EdgeInsets.all(16.0), // Removed padding to let image flush with edges
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
            // --- NEW: DISPLAY POSTER IMAGE ---
            if (event.posterUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  event.posterUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(), // Hide if error
                ),
              ),
            
            // Content Container
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                          child: Text(
                        event.location,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.star),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No events found.'));
                      }

                      final allDocs = snapshot.data!.docs;
                      final List<Event> filteredList = [];

                      for (var doc in allDocs) {
                        final data = doc.data() as Map<String, dynamic>;
                        String status = data['status'] ?? 'Upcoming';

                        bool matchesFilter = false;
                        if (_currentFilter == EventFilter.upcoming && status == 'Upcoming') matchesFilter = true;
                        if (_currentFilter == EventFilter.ongoings && status == 'Ongoing') matchesFilter = true;
                        if (_currentFilter == EventFilter.completed && status == 'Completed') matchesFilter = true;

                        if (matchesFilter) {
                          String dateTimeStr = data['dateTime'] ?? '';
                          String datePart = dateTimeStr;
                          String timePart = '';
                          if (dateTimeStr.contains(' at ')) {
                            final parts = dateTimeStr.split(' at ');
                            datePart = parts[0];
                            timePart = parts.length > 1 ? parts[1] : '';
                          }

                          filteredList.add(Event(
                            id: doc.id,
                            title: data['name'] ?? 'No Title',
                            date: datePart,
                            time: timePart,
                            location: data['venue'] ?? 'Unknown',
                            description: "Department: ${data['department']}\nYear: ${data['year']}",
                            posterUrl: data['posterUrl'] ?? '', // <--- MAPPED HERE
                          ));
                        }
                      }

                      if (filteredList.isEmpty) {
                        return const Center(child: Text('No events found.'));
                      }

                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildEventItem(context, filteredList[index]);
                        },
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