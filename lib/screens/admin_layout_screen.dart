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
      // Enhanced AppBar with gradient background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            actions: [
              // Notification Icon with enhanced styling
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  iconSize: 26,
                  onPressed: _navigateToNotifications,
                  tooltip: 'Notifications',
                ),
              ),
              // Logout button with enhanced styling (only on Home/Events tab)
              if (_selectedIndex == 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    iconSize: 26,
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ),
              // Profile Icon with enhanced styling
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  iconSize: 26,
                  onPressed: _navigateToProfile,
                  tooltip: 'Profile',
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),

      // Display the selected screen with animated transition
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),

      // Enhanced Bottom Navigation Bar with floating style
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.blue.shade600,
            unselectedItemColor: Colors.grey.shade400,
            iconSize: 28,
            elevation: 0,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.chat_bubble_outline, 0),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_outlined, 1),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.help_outline, 2),
                label: 'Help',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build animated navigation icons
  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isSelected ? 12 : 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey.shade400,
        size: isSelected ? 28 : 26,
      ),
    );
  }
}