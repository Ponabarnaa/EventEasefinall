import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Logout
import 'login&register.dart'; // Import to navigate back to Login Screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. State for the Dropdown Filter
  String _selectedFilter = 'Upcoming'; // Default view
  final List<String> _filterOptions = ['Upcoming', 'Ongoing', 'Completed'];

  // 2. Dummy Data (Used for list structure demonstration)
  final List<Map<String, String>> _allEvents = [
    // {'title': 'Tech Conference 2024', 'status': 'Upcoming', 'date': 'Dec 12'},
    // {'title': 'Music Festival', 'status': 'Ongoing', 'date': 'Now'},
  ];

  // 3. Bottom Navigation State (0=Message, 1=Home, 2=Profile)
  int _selectedIndex = 1;

  // --- NEW: Logout Function ---
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to the LoginRegisterScreen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
        );
      }
    } catch (e) {
      // Handle potential sign-out errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter the events based on the dropdown selection
    final filteredEvents = _allEvents
        .where((event) => event['status'] == _selectedFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // The Dropdown Filter
          DropdownButton<String>(
            value: _selectedFilter,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            underline: Container(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            items: _filterOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedFilter = newValue!;
              });
            },
          ),
          const SizedBox(width: 8),

          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Handle notification tap
            },
          ),

          // --- NEW: Logout Icon (Top Right Corner) ---
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedFilter Events',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            // --- Empty State Check ---
            Expanded(
              child: filteredEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "No $_selectedFilter events available.",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              color: _getStatusColor(_selectedFilter),
                              height: double.infinity,
                            ),
                            title: Text(
                              filteredEvents[index]['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Date: ${filteredEvents[index]['date']}",
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          // 0: Message button
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Message',
          ),
          // 1: Home button
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // 2: Profile button
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
