import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = "Upcoming";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton(
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
                          Image.network(
                            event.posterUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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
                                Text("Venue: ${event.venue}"),
                                Text("Time: ${event.time}"),
                                Text("Department: ${event.department}"),
                              ],
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
