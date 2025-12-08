import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_event_detail_screen.dart'; // Imports the Event class

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

  // --- STATIC DATA FOR COMPLETED EVENTS ---
  List<Event> _getStaticCompletedEvents() {
    return [
      const Event(
        id: 'static_1',
        title: 'AI & ML Symposium 2023',
        date: '2023-11-10',
        time: '10:00 AM',
        location: 'Main Auditorium',
        description: 'A deep dive into Neural Networks and ML algorithms.',
        status: 'completed', // <--- FIXED: Added status
        posterUrl: '', 
      ),
      const Event(
        id: 'static_2',
        title: 'Cyber Security Hackathon',
        date: '2023-10-05',
        time: '09:00 AM',
        location: 'Computer Lab 3',
        description: '24-hour Capture The Flag (CTF) competition.',
        status: 'completed', // <--- FIXED: Added status
        posterUrl: '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Ongoings'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _currentFilter == EventFilter.completed
                // 1. SHOW STATIC DATA FOR COMPLETED TAB
                ? ListView.builder(
                    itemCount: _getStaticCompletedEvents().length,
                    itemBuilder: (context, index) {
                      return _buildEventItem(
                          context, _getStaticCompletedEvents()[index]);
                    },
                  )
                // 2. SHOW FIRESTORE DATA FOR OTHERS
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No events found.'));
                      }

                      final events = snapshot.data!.docs;
                      List<Event> filteredList = [];

                      // Determine status based on the current tab
                      String dynamicStatus = _currentFilter == EventFilter.upcoming 
                          ? 'upcoming' 
                          : 'ongoing';

                      for (var doc in events) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        
                        // Parse simple date/time logic if needed
                        String datePart = data['date'] ?? '';
                        String timePart = data['time'] ?? '';

                        filteredList.add(Event(
                          id: doc.id,
                          title: data['name'] ?? 'No Title',
                          date: datePart,
                          time: timePart,
                          location: data['venue'] ?? 'Unknown',
                          description:
                              "Department: ${data['department']}\nYear: ${data['year']}",
                          status: dynamicStatus, // <--- FIXED: Passing the status here
                          posterUrl: data['posterUrl'] ?? '',
                        ));
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
        ),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminEventDetailScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: event.status == 'completed'
                      ? Colors.grey.shade200
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event,
                    color: event.status == 'completed'
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${event.date} • ${event.time}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      event.location,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}