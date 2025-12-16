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
        status: 'completed',
        posterUrl: '', 
      ),
      const Event(
        id: 'static_2',
        title: 'Cyber Security Hackathon',
        date: '2023-10-05',
        time: '09:00 AM',
        location: 'Computer Lab 3',
        description: '24-hour Capture The Flag (CTF) competition.',
        status: 'completed',
        posterUrl: '',
      ),
    ];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Icons.schedule_rounded;
      case 'ongoing':
        return Icons.play_circle_filled_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Enhanced Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _currentFilter == EventFilter.completed
                  // 1. SHOW STATIC DATA FOR COMPLETED TAB
                  ? _getStaticCompletedEvents().isEmpty
                      ? _buildEmptyState('No completed events yet')
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
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
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading events...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState('No events found');
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
                            status: dynamicStatus,
                            posterUrl: data['posterUrl'] ?? '',
                          ));
                        }

                        if (filteredList.isEmpty) {
                          return _buildEmptyState('No events in this category');
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildEventItem(context, filteredList[index]);
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Events will appear here when added',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminEventDetailScreen(event: event),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Event Image/Icon Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(event.status),
                        _getStatusColor(event.status).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(event.status).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: event.posterUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            event.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  _getStatusIcon(event.status),
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            _getStatusIcon(event.status),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(event.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Event Title
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Date & Time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${event.date} • ${event.time}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}