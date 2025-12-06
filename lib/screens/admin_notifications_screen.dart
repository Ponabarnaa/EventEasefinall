// lib/screens/admin_notifications_screen.dart

import 'package:flutter/material.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            leading: Icon(Icons.event),
            title: Text('New Event Posted!'),
            subtitle: Text('An event was successfully posted by you.'),
            trailing: Text('10 min ago'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('System Update Complete'),
            subtitle: Text('The dashboard has been updated to v2.0.'),
            trailing: Text('1 hour ago'),
          ),
          Divider(),
          // Add more notifications here
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text('End of notifications'),
            ),
          ),
        ],
      ),
    );
  }
}
