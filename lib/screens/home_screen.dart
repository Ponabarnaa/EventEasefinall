// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/event.dart'; 
// import 'registeration_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String _selectedFilter = "Upcoming";

//   void _navigateToRegistration(EventDetails event) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RegistrationScreen(event: event)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("User Dashboard")),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Filter Dropdown
//           Padding(
//             padding: const EdgeInsets.only(left: 10.0, top: 10.0),
//             child: DropdownButton<String>(
//               value: _selectedFilter,
//               items: const [
//                 DropdownMenuItem(value: "Upcoming", child: Text("Upcoming")),
//                 DropdownMenuItem(value: "Ongoing", child: Text("Ongoing")),
//                 DropdownMenuItem(value: "Completed", child: Text("Completed")),
//               ],
//               onChanged: (val) {
//                 if (val != null) setState(() => _selectedFilter = val);
//               },
//             ),
//           ),
          
//           // Event List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('events')
//                   .where('status', isEqualTo: _selectedFilter)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text("No events found."));
//                 }

//                 final events = snapshot.data!.docs.map((doc) {
//                   return EventDetails.fromFirestore(
//                       doc.data() as Map<String, dynamic>, doc.id);
//                 }).toList();

//                 return ListView.builder(
//                   itemCount: events.length,
//                   itemBuilder: (context, index) {
//                     final event = events[index];
//                     return Card(
//                       margin: const EdgeInsets.all(10),
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // --- POSTER IMAGE SECTION ---
//                           if (event.posterUrl.isNotEmpty)
//                             ClipRRect(
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(12),
//                                 topRight: Radius.circular(12),
//                               ),
//                               child: Image.network(
//                                 event.posterUrl,
//                                 height: 180, // Adjust height as needed
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     height: 180,
//                                     color: Colors.grey[300],
//                                     child: const Center(
//                                         child: Icon(Icons.broken_image,
//                                             size: 50, color: Colors.grey)),
//                                   );
//                                 },
//                                 loadingBuilder: (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Container(
//                                     height: 180,
//                                     color: Colors.grey[200],
//                                     child: const Center(
//                                         child: CircularProgressIndicator()),
//                                   );
//                                 },
//                               ),
//                             ),
//                           // ----------------------------

//                           Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   event.title,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.calendar_today, size: 16),
//                                     const SizedBox(width: 5),
//                                     Text(event.date),
//                                     const SizedBox(width: 15),
//                                     const Icon(Icons.location_on, size: 16),
//                                     const SizedBox(width: 5),
//                                     Expanded(
//                                       child: Text(
//                                         event.location,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: () => _navigateToRegistration(event),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.black87,
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8.0),
//                                       ),
//                                     ),
//                                     child: const Text("View full details"),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart'; 
import 'registeration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = "Upcoming";

  void _navigateToRegistration(EventDetails event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        // --- ADDED BACK BUTTON ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This will navigate back to the previous screen (e.g., Login)
            Navigator.of(context).pop(); 
          },
        ),
        // -------------------------
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(value: "Upcoming", child: Text("Upcoming")),
                DropdownMenuItem(value: "Ongoing", child: Text("Ongoing")),
                DropdownMenuItem(value: "Completed", child: Text("Completed")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFilter = val);
              },
            ),
          ),
          
          // Event List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('status', isEqualTo: _selectedFilter)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No events found."));
                }

                final events = snapshot.data!.docs.map((doc) {
                  return EventDetails.fromFirestore(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- POSTER IMAGE (Kept from previous steps) ---
                          if (event.posterUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.network(
                                event.posterUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey)),
                                  );
                                },
                              ),
                            ),
                          // ----------------------------------------------

                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 5),
                                    Text(event.date),
                                    const SizedBox(width: 15),
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        event.location,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _navigateToRegistration(event),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text("View full details"),
                                  ),
                                ),
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