// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the new screen components
import 'event_request_screen.dart'; // <-- RENAMED/NEW FILE
import 'profile_screen.dart';

// --- 1. Event Model (Kept here for simplicity) ---
class Event {
  const Event({
    required this.title,
    required this.category,
    required this.date,
    required this.icon,
  });

  final String title;
  final String category;
  final String date;
  final IconData icon;
}

// --- 2. Static Event Data ---
const List<Event> _allEvents = [
  Event(
    title: 'Code Sprint: Dart & Flutter',
    category: 'Technical',
    date: '12/12/25',
    icon: Icons.code,
  ),
  Event(
    title: 'Design Thinking Workshop',
    category: 'Workshop',
    date: '10/12/25',
    icon: Icons.lightbulb_outline,
  ),
  Event(
    title: 'Intra-Department Quiz',
    category: 'Non-Technical',
    date: '15/12/25',
    icon: Icons.psychology_outlined,
  ),
];

// --- 3. HomeScreen Wrapper Widget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Start on the 'Home' screen (index 1)

  // State variables for the Event List view (Home content)
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Technical',
    'Non-Technical',
    'Workshop',
  ];

  // List of titles for the App Bar
  final List<String> _screenTitles = [
    'Event Request', // Updated title for the Inbox tab
    'EventEase Home',
    'User Profile',
  ];

  // List of widgets corresponding to the bottom navigation bar items
  late final List<Widget> _screenBodies;

  @override
  void initState() {
    super.initState();
    // Initialize the screens here
    _screenBodies = [
      const EventRequestScreen(), // Index 0: Event Request/Approval Page
      _buildEventListContent(), // Index 1: Home (Event List)
      const ProfileScreen(), // Index 2: Profile
    ];
  }

  // Helper method to dynamically build the Event List content (for Home tab)
  Widget _buildEventListContent() {
    // Logic for filtering is placed directly here for simplicity
    List<Event> filteredEvents = _allEvents;
    if (_selectedCategory != 'All') {
      filteredEvents = _allEvents
          .where((event) => event.category == _selectedCategory)
          .toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // --- Category Filter Dropdown ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (String? newCategory) {
                      if (newCategory != null) {
                        setState(() {
                          _selectedCategory = newCategory;
                          // Force rebuild of the screen body to update the list
                          _screenBodies[1] = _buildEventListContent();
                        });
                      }
                    },
                    items: _categories.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // --- Event List ---
        Expanded(
          child: filteredEvents.isEmpty
              ? Center(
                  child: Text(
                    'No ${_selectedCategory.toLowerCase()} events currently available.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return EventTile(event: event);
                  },
                ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
    String appBarTitle = _screenTitles[_selectedIndex];

    if (_selectedIndex == 1) {
      // Custom title for the Home screen
      appBarTitle = 'Welcome, $userName!';
    }

    return Scaffold(
      // Dynamic App Bar
      appBar: AppBar(
        title: Text(appBarTitle),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),

      // Dynamic Body Content using IndexedStack for smooth switching
      body: IndexedStack(index: _selectedIndex, children: _screenBodies),

      // Functional Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline), // Inbox/Message icon
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Home icon
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Profile icon
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// --- Event Card Widget (Kept here for simplicity) ---
class EventTile extends StatelessWidget {
  final Event event;

  const EventTile({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Card(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        elevation: 4,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Tapped on ${event.title}')));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Event Icon/Visual ---
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Icon(
                      event.icon,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // --- Event Details ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.category,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // --- Date ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.date,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
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
