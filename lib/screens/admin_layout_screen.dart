// lib/screens/admin_layout_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login&register.dart'; // To navigate back after logout
import 'admin_events_screen.dart'; // NEW: Screen for Events List
import 'admin_post_screen.dart'; // NEW: Screen for Post Button
import 'admin_help_screen.dart'; // NEW: Placeholder for Help/Profile

class AdminLayoutScreen extends StatefulWidget {
  const AdminLayoutScreen({super.key});

  @override
  State<AdminLayoutScreen> createState() => _AdminLayoutScreenState();
}

class _AdminLayoutScreenState extends State<AdminLayoutScreen> {
  int _selectedIndex = 1; // Start on Home/Events tab

  final List<Widget> _widgetOptions = <Widget>[
    const AdminPostScreen(), // 0: Message Icon (Post Button)
    const AdminEventsScreen(), // 1: Home Icon (Events List)
    const AdminHelpScreen(), // 2: Help Icon (Placeholder)
  ];

  // --- Logout Function ---
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          // Logout button only visible on the Home/Events tab (index 1)
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout, // Call the logout function
            ),
          // Profile Icon
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),

      // Display the selected screen based on the bottom navigation index
      body: _widgetOptions.elementAt(_selectedIndex),

      // Bottom Navigation Bar (Used to switch between the 3 screens)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          // 0: Message Icon (Post Button Screen)
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Post',
          ),
          // 1: Home Icon (Events List Screen)
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // 2: Help Icon (Placeholder Screen)
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}
