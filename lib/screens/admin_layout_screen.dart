// lib/screens/admin_layout_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login&register.dart';
import 'admin_events_screen.dart';
import 'admin_post_screen.dart';
import 'admin_help_screen.dart';
// NEW Imports for AppBar navigation
import 'admin_notifications_screen.dart';
import 'admin_profile_screen.dart';

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

  // --- Logout Function (Kept as-is) ---
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
        );
      }
    } catch (e) {
      // NOTE: Using a simple placeholder for error message due to lack of real `Text` context
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error signing out')));
    }
  }

  // --- Navigation Handlers ---
  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AdminProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Notification Icon - NOW NAVIGATES
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _navigateToNotifications,
          ),
          // Logout button only visible on the Home/Events tab (index 1)
          if (_selectedIndex == 1)
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          // Profile Icon - NOW NAVIGATES
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _navigateToProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Display the selected screen based on the bottom navigation index
      body: _widgetOptions.elementAt(_selectedIndex),

      // Bottom Navigation Bar (Kept as-is)
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}
