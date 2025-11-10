// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// ✅ FIX 1: Import the correct EventDetails model
import '../models/event.dart'; // Assuming you create lib/models/event.dart
import 'certificate_screen.dart'; // Placeholder for other screens
import 'feedback_screen.dart'; // Placeholder for other screens
import 'registration_form_screen.dart'; // Import registration screen

// --- Event Mock Data (Moved from the old file, but kept here for self-contained code) ---
final List<EventDetails> _allEvents = [
  // TECHNICAL EVENTS (3)
  EventDetails(
    name: "Ethical Hacking Workshop",
    date: "2025-11-20",
    location: "MCA Lab 305",
    type: 'Technical',
    description:
        "Learn defensive and offensive cybersecurity techniques, penetration testing, and secure coding practices in this intensive 3-day workshop.",
    imageUrl:
        "https://placehold.co/600x400/0000FF/FFFFFF?text=Ethical+Hacking",
  ),
  EventDetails(
    name: "Code Debugging Challenge",
    date: "2025-12-05",
    location: "Computer Center",
    type: 'Technical',
    description:
        "A timed competition to find and fix tricky bugs in complex JavaScript and Python code snippets. Prizes for the fastest debuggers!",
    imageUrl:
        "https://placehold.co/600x400/FF0000/FFFFFF?text=Debugging+Challenge",
  ),
  EventDetails(
    name: "Cloud Computing with AWS/Azure",
    date: "2026-01-10",
    location: "Seminar Hall A-201",
    type: 'Technical',
    description:
        "Introduction to cloud services, deployment strategies, and managing scalable infrastructure using industry-leading cloud platforms.",
    imageUrl:
        "https://placehold.co/600x400/00FF00/000000?text=Cloud+Computing",
  ),

  // NON-TECHNICAL EVENTS (2)
  EventDetails(
    name: "E-Waste Management Seminar",
    date: "2026-01-25",
    location: "Auditorium",
    type: 'Non-Technical',
    description:
        "A crucial seminar discussing the environmental impact of electronic waste and promoting sustainable disposal and recycling methods.",
    imageUrl:
        "https://placehold.co/600x400/FFFF00/000000?text=E-Waste+Mgmt",
  ),
  EventDetails(
    name: "Startup Pitch Competition",
    date: "2026-02-15",
    location: "Incubation Center",
    type: 'Non-Technical',
    description:
        "Present your innovative business idea or app concept to a panel of judges and potential investors. Open to all students.",
    imageUrl:
        "https://placehold.co/600x400/FF00FF/FFFFFF?text=Startup+Pitch",
  ),

  // WORKSHOPS (2)
  EventDetails(
    name: "Flutter App Development Workshop",
    date: "2026-03-01",
    location: "MCA Lab 306",
    type: 'Workshop',
    description:
        "A comprehensive, hands-on workshop focused on building cross-platform mobile and web applications using Flutter and Dart.",
    imageUrl:
        "https://placehold.co/600x400/00FFFF/000000?text=Flutter+Workshop",
  ),
  EventDetails(
    name: "Resume & Interview Skills Workshop",
    date: "2026-03-20",
    location: "Placement Cell",
    type: 'Workshop',
    description:
        "Professional guidance on crafting winning resumes, mastering behavioral interviews, and acing technical rounds for placements.",
    imageUrl:
        "https://placehold.co/600x400/FFA500/FFFFFF?text=Interview+Prep",
  ),
];

// 2. PLACEHOLDER SCREEN DEFINITIONS (Kept for compilation)
class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Login/Register Screen Placeholder")),
    );
  }
}

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.military_tech, size: 48, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              "Certificate Management Tab",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback, size: 48, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              "Feedback Submission Tab",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ FIX 2: Updated EventDetailScreen to use the imported EventDetails model.
class EventDetailScreen extends StatelessWidget {
  final EventDetails event; // Using imported model
  const EventDetailScreen({super.key, required this.event});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Details for: ${event.name}",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(event.description,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            // ... (Other details)
            ElevatedButton(
              onPressed: () {
                // ✅ FIX 3: Navigate to the RegistrationFormScreen, passing the event object.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegistrationFormScreen(event: event),
                  ),
                );
              },
              child: const Text('Register Now'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HomeScreen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  final List<String> _mainTabs = ['Events', 'Certificates', 'Feedback'];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _mainTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.displayName == null || user!.displayName!.isEmpty
              ? 'MCA Department Hub'
              : 'Welcome, ${user.displayName}',
          style:
              theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.event_note), text: 'Events'),
            Tab(icon: Icon(Icons.military_tech), text: 'Certificates'),
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: const [
          _EventsTabContent(),
          CertificateScreen(),
          FeedbackScreen(),
        ],
      ),
    );
  }
}

// --- Nested Widgets ---

class _EventsTabContent extends StatelessWidget {
  const _EventsTabContent();

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Technical'),
              Tab(text: 'Non-Technical'),
              Tab(text: 'Workshops'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.blueAccent,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _EventList(eventType: 'Technical'),
                _EventList(eventType: 'Non-Technical'),
                _EventList(eventType: 'Workshop'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final String eventType;

  const _EventList({required this.eventType});

  @override
  Widget build(BuildContext context) {
    final filteredEvents =
        _allEvents.where((e) => e.type == eventType).toList();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Text('No $eventType events scheduled right now.',
            style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return UpcomingEventCard(
          event: event,
          eventDate: DateTime.tryParse(event.date) ?? DateTime.now(),
          onTap: () {
            // Navigate to the detail screen, passing the full EventDetails object
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
          },
        );
      },
    );
  }
}

class UpcomingEventCard extends StatelessWidget {
  final EventDetails event;
  final DateTime eventDate;
  final VoidCallback onTap;

  const UpcomingEventCard({
    required this.event,
    required this.eventDate,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = DateFormat('dd').format(eventDate);
    final month = DateFormat('MMM').format(eventDate).toUpperCase();
    final year = DateFormat('yyyy').format(eventDate);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Date Pillar (Visual Element)**
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      month,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      day,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      year,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // **Event Details**
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Type Tag
                    Chip(
                      label: Text(
                        event.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: event.type == 'Technical'
                              ? Colors.blue.shade900
                              : event.type == 'Non-Technical'
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                        ),
                      ),
                      backgroundColor: event.type == 'Technical'
                          ? Colors.blue.shade50
                          : event.type == 'Non-Technical'
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),

              // **Arrow Indicator**
              const Padding(
                padding: EdgeInsets.only(left: 8.0, top: 10.0),
                child:
                    Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}