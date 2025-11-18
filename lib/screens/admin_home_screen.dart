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
    Map<String, dynamic> dataToUpdate = {
      'status': newStatus,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    };

    if (newStatus == 'approved') {
      // When approving, mark that Form 2 needs to be submitted
      dataToUpdate['form2Submitted'] = false;
    }

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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: 'Pending Approvals'),
              Tab(text: 'Form 2 Verifications'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Pending Approvals (Form 1)
                _buildPendingApprovalsTab(context),
                // Tab 2: Form 2 Submissions
                _buildForm2VerificationsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Pending Form 1 Approvals
  Widget _buildPendingApprovalsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Pending Approvals',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.hourglass_top, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pendingEvents')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('requestedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
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
                    final doc = eventDocs[index];
                    final event = PendingEvent.fromFirestore(doc);
                    final status =
                        (doc.data() as Map<String, dynamic>)['status'] ??
                        'pending';

                    return EventRequestCard(
                      event: event,
                      status: status,
                      onApprove: () {
                        _handleEventStatus(event.id, 'approved');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Event Approved! User can now submit details.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onDecline: () {
                        _showDeclineDialog(context, event);
                      },
                      onViewDetails: () {
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

  // Tab 2: Form 2 Verifications (events with status = 'form2_submitted')
  Widget _buildForm2VerificationsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Form 2 Submissions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.upload_file, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pendingEvents')
                  .where('status', isEqualTo: 'form2_submitted')
                  .orderBy('form2SubmittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 150, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'No Form 2 submissions pending verification.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final eventDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: eventDocs.length,
                  itemBuilder: (context, index) {
                    final doc = eventDocs[index];
                    final eventData = doc.data() as Map<String, dynamic>;

                    return Form2VerificationCard(
                      eventId: doc.id,
                      eventData: eventData,
                      onPublish: () {
                        FirebaseFirestore.instance
                            .collection('pendingEvents')
                            .doc(doc.id)
                            .update({
                              'status': 'published',
                              'publishedAt': FieldValue.serverTimestamp(),
                            });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Event Published! Now visible to all users.',
                            ),
                            backgroundColor: Colors.purple,
                          ),
                        );
                      },
                      onReject: () {
                        _showForm2RejectDialog(
                          context,
                          doc.id,
                          eventData['name'] ?? 'Event',
                        );
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

  // Dialog to reject Form 2
  void _showForm2RejectDialog(
    BuildContext context,
    String docId,
    String eventName,
  ) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reject Form 2 for "$eventName"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please provide a reason for rejecting these details.',
                ),
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
                      return 'A reason is required.';
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
                  FirebaseFirestore.instance
                      .collection('pendingEvents')
                      .doc(docId)
                      .update({
                        'status':
                            'approved', // Back to approved so user can resubmit Form 2
                        'form2Submitted': false,
                        'form2RejectionReason': reasonController.text,
                      });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Form 2 Rejected. User can resubmit.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
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

// --- MODIFIED: Card redesigned to match your 2nd image's layout ---
class EventRequestCard extends StatelessWidget {
  final PendingEvent event;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onViewDetails;

  const EventRequestCard({
    super.key,
    required this.event,
    required this.status,
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
            // --- NEW: Header section like your image ---
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.red.shade100,
                  child: Icon(Icons.event_note, color: Colors.red.shade800),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name, // Event name
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.requestedByEmail, // Requester email
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 2),
                    Chip(
                      label: Text(
                        status == 'approved'
                            ? 'Approved'
                            : status == 'declined'
                            ? 'Declined'
                            : 'Pending',
                      ),
                      labelStyle: TextStyle(
                        color: status == 'approved'
                            ? Colors.green
                            : (status == 'declined'
                                  ? Colors.red
                                  : Colors.orange),
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: status == 'approved'
                          ? Colors.green.shade50
                          : (status == 'declined'
                                ? Colors.red.shade50
                                : Colors.orange.shade50),
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: 0.0,
                        vertical: -4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),

            // --- NEW: Details section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Details:',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.location,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // --- MODIFIED: Show action buttons only for pending events ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Full Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorDark,
                  ),
                ),
                // Only show approve/decline buttons if status is pending
                if (status == 'pending')
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
                // Show status message for already processed events
                if (status != 'pending')
                  Chip(
                    label: Text(
                      status == 'approved' ? 'Already Approved' : 'Declined',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: status == 'approved'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
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

// --- Form 2 Verification Card ---
class Form2VerificationCard extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;
  final VoidCallback onPublish;
  final VoidCallback onReject;

  const Form2VerificationCard({
    super.key,
    required this.eventId,
    required this.eventData,
    required this.onPublish,
    required this.onReject,
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
            // Event Name
            Row(
              children: [
                const Icon(Icons.event, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    eventData['name'] ?? 'Unnamed Event',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Basic Info
            _buildInfoRow(
              Icons.email,
              'Submitted by:',
              eventData['requestedByEmail'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.category,
              'Type:',
              eventData['eventType'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              'Location:',
              eventData['location'] ?? 'N/A',
            ),

            const Divider(height: 24),

            // Form 2 Details
            const Text(
              'Form 2 Details:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.link,
              'Registration Link:',
              eventData['registrationLink'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Event Date:',
              eventData['finalEventDate'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.image,
              'Poster:',
              eventData['posterUrl'] != null ? 'Uploaded ✓' : 'Not uploaded',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.video_library,
              'Promo Video:',
              eventData['promoVideoLink'] ?? 'N/A',
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onReject,
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onPublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.public),
                  label: const Text('Publish Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
