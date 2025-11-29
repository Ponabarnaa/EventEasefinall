// lib/screens/admin_events_screen.dart

import 'package:flutter/material.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  // State for the Dropdown Filter
  String _selectedFilter = 'Upcoming'; // Default view
  final List<String> _filterOptions = ['Upcoming', 'Ongoing', 'Completed'];

  // Dummy Data (Set to EMPTY to display the "No Events" message)
  // This ensures the page starts empty, as requested.
  final List<Map<String, String>> _allEvents = [];
  // Example of how data would look if present:
  // final List<Map<String, String>> _allEvents = [
  //   {'title': 'Annual Gala Dinner', 'status': 'Upcoming', 'date': 'Jan 15'},
  //   {'title': 'Department Workshop', 'status': 'Ongoing', 'date': 'Today'},
  //   {'title': 'Freshers Orientation', 'status': 'Completed', 'date': 'Aug 20'},
  // ];

  @override
  Widget build(BuildContext context) {
    // Filter events based on the dropdown selection
    final filteredEvents = _allEvents
        .where((event) => event['status'] == _selectedFilter)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Event Type Title
              Text(
                '$_selectedFilter Events',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              // --- Dropdown Filter ---
              DropdownButton<String>(
                value: _selectedFilter,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                underline: Container(), // Removes the default underline
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                items: _filterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(),

        // --- Empty State Logic ---
        Expanded(
          child: filteredEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No $_selectedFilter events available for posting.",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 100), // Push content slightly up
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                          color: _getStatusColor(
                            filteredEvents[index]['status']!,
                          ),
                          height: double.infinity,
                        ),
                        title: Text(
                          filteredEvents[index]['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Date: ${filteredEvents[index]['date']}",
                        ),
                        // Add an edit/delete icon for Admin
                        trailing: const Icon(Icons.edit, size: 16),
                        onTap: () {
                          // TODO: Implement navigation to Edit Event Screen
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
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
