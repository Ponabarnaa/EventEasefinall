// lib/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login&register.dart'; // Import for sign-out

// --- NEW: Model for Pending Event (from Firestore) ---
class PendingEvent {
  final String id;
  final String name;
  final String location;
  final String date;
  final String time;
  final String eventType;
  final String collegeReach;
  final String department;
  final String description;
  final String studentCoordinator;
  final String coordinatorPhone;
  final String staffCoordinator;
  final String hodName;
  final String hodPhone;
  final String requestedByEmail;

  PendingEvent({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.eventType,
    required this.collegeReach,
    required this.department,
    required this.description,
    required this.studentCoordinator,
    required this.coordinatorPhone,
    required this.staffCoordinator,
    required this.hodName,
    required this.hodPhone,
    required this.requestedByEmail,
  });

  // Factory constructor to create a PendingEvent from a Firestore document
  factory PendingEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String getString(String key) => data[key]?.toString() ?? 'N/A';

    return PendingEvent(
      id: doc.id,
      name: getString('name'),
      location: getString('location'),
      date: getString('date'),
      time: getString('time'),
      eventType: getString('eventType'),
      collegeReach: getString('collegeReach'),
      department: getString('department'),
      description: getString('description'),
      studentCoordinator: getString('studentCoordinator'),
      coordinatorPhone: getString('coordinatorPhone'),
      staffCoordinator: getString('staffCoordinator'),
      hodName: getString('hodName'),
      hodPhone: getString('hodPhone'),
      requestedByEmail: getString('requestedByEmail'),
    );
  }
}

// --- Main Admin Screen (Manages Tabs) ---
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _adminPages = <Widget>[
    AdminEventRequestsScreen(),
    AdminDashboardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Text _getAppBarTitle() {
    if (_selectedIndex == 0) {
      return const Text('Event Requests');
    } else {
      return const Text('Admin Dashboard');
    }
  }

  // --- Sign-Out Function ---
  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getAppBarTitle(),
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(child: _adminPages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Event Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red.shade900,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- PAGE 1: The "Event list" Screen (DYNAMIC) ---
class AdminEventRequestsScreen extends StatelessWidget {
  const AdminEventRequestsScreen({super.key});

  // --- Handle Approval/Denial ---
  void _handleEventStatus(String docId, String newStatus, {String? reason}) {
    Map<String, dynamic> dataToUpdate = {'status': newStatus};
    if (newStatus == 'declined' && reason != null) {
      dataToUpdate['rejectionReason'] = reason;
    }
    FirebaseFirestore.instance
        .collection('pendingEvents')
        .doc(docId)
        .update(dataToUpdate);
  }

  // --- Show Decline with Reason Dialog ---
  void _showDeclineDialog(BuildContext context, PendingEvent event) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Decline "${event.name}"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for declining this event.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A reason is required to decline.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _handleEventStatus(
                    event.id,
                    'declined',
                    reason: reasonController.text,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event Declined.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit Decline'),
            ),
          ],
        );
      },
    );
  }

  // --- Show Details Modal ---
  void _showEventDetails(BuildContext context, PendingEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // --- 1. BUG FIX: Replaced RoundedRectangleSymmetricBorder ---
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // This 'context' is the one for the modal sheet
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // --- 2. BUG FIX: Pass 'context' to the helper method ---
                    _buildDetailRow(
                      context,
                      Icons.person,
                      'Requested by',
                      event.requestedByEmail,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.category,
                      'Type',
                      '${event.eventType} (${event.collegeReach})',
                    ),
                    _buildDetailRow(
                      context,
                      Icons.school,
                      'Department',
                      event.department,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Location',
                      event.location,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.calendar_today,
                      'Date',
                      event.date,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Time',
                      event.time,
                    ),
                    const Divider(height: 30),
                    _buildDetailRow(
                      context,
                      Icons.person,
                      'Student Coordinator',
                      '${event.studentCoordinator} (${event.coordinatorPhone})',
                    ),
                    _buildDetailRow(
                      context,
                      Icons.person_outline,
                      'Staff Coordinator',
                      event.staffCoordinator,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.person_pin,
                      'HOD',
                      '${event.hodName} (${event.hodPhone})',
                    ),
                    const Divider(height: 30),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. BUG FIX: Helper widget now accepts 'context' ---
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                // --- 2. BUG FIX: This line now has the 'context' it needs ---
                width: MediaQuery.of(context).size.width - 100,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event list',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // --- StreamBuilder to get live data ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pendingEvents')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('requestedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // This 'context' is from the StreamBuilder
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final eventDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: eventDocs.length,
                  itemBuilder: (context, index) {
                    // This 'context' is from the ListView.builder
                    final event = PendingEvent.fromFirestore(eventDocs[index]);
                    return EventRequestCard(
                      event: event,
                      onApprove: () {
                        _handleEventStatus(event.id, 'approved');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event Approved!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onDecline: () {
                        // Pass the correct context
                        _showDeclineDialog(context, event);
                      },
                      onViewDetails: () {
                        // Pass the correct context
                        _showEventDetails(context, event);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for when no requests are pending
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 150, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No pending event requests.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// --- Card for each event request ---
class EventRequestCard extends StatelessWidget {
  final PendingEvent event;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onViewDetails;

  const EventRequestCard({
    super.key,
    required this.event,
    required this.onApprove,
    required this.onDecline,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(event.location, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(event.date, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: onDecline,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAGE 2: The Original "Welcome" Screen (No change) ---
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text(
            'Welcome, Admin!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('This is the dedicated Admin Area.'),
        ],
      ),
    );
  }
}
