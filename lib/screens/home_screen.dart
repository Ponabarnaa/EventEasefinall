import 'package:flutter/material.dart'; // <--- Added the required import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart'; // Assuming your EventDetails model is here
import 'registeration_screen.dart'; // Import the registration screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = "Upcoming";

  // CORRECTED: Only one definition of the navigation function is kept
  void _navigateToRegistration(EventDetails event) {
    // Navigate to the registration screen, passing the event details
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
            ), // Padding for the dropdown
            child: DropdownButton(
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(value: "Upcoming", child: Text("Upcoming")),
                DropdownMenuItem(value: "Ongoing", child: Text("Ongoing")),
                DropdownMenuItem(value: "Completed", child: Text("Completed")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("events")
                  .where("status", isEqualTo: _selectedFilter)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(child: Text("No $_selectedFilter events."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    EventDetails event = EventDetails.fromFirestore(
                      docs[index],
                    );

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Event Image Banner
                          Image.network(
                            event.posterUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),

                          // 2. Event Details (Name, Venue, Time, Dept)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Venue: ${event.venue}"),
                                Text("Time: ${event.time}"),
                                Text("Department: ${event.department}"),

                                // Placeholder for Event Description/More Details (Frame 1)
                                const SizedBox(height: 8),
                                const Text("Event Description placeholder..."),
                              ],
                            ),
                          ),

                          // 3. View Full Details Button
                          Container(
                            width: double.infinity, // Full width
                            // Padding only below the details
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: ElevatedButton(
                              onPressed: () => _navigateToRegistration(event),
                              style: ElevatedButton.styleFrom(
                                // Styling to match the dark button in Frame 1
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: const Text(
                                "View full details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
