
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csv/csv.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart'; // <--- Ensure this is imported

// class AdminEventParticipantsScreen extends StatelessWidget {
//   final String eventId;
//   final String eventName;

//   const AdminEventParticipantsScreen({
//     super.key,
//     required this.eventId,
//     required this.eventName,
//   });

//   // --- EXPORT FUNCTION ---
//   Future<void> _exportToExcel(BuildContext context) async {
//     try {
//       // 1. Show Loading Indicator
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Preparing data for export...')),
//       );

//       // 2. Fetch Data from Firestore
//       final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('registrations')
//           .where('eventId', isEqualTo: eventId)
//           .get();

//       if (querySnapshot.docs.isEmpty) {
//         if (context.mounted) {
//            ScaffoldMessenger.of(context).hideCurrentSnackBar();
//            ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No participants to export.')),
//           );
//         }
//         return;
//       }

//       // 3. Create CSV Data Structure
//       List<List<dynamic>> rows = [];
      
//       // Add Header Row
//       rows.add([
//         "Name",
//         "Roll No",
//         "Phone No",
//         "Email",
//         "Department",
//         "Year",
//         "College"
//       ]);

//       // Add User Data Rows
//       for (var doc in querySnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         rows.add([
//           data['name'] ?? '',
//           data['rollNo'] ?? '',
//           data['phoneNo'] ?? '',
//           data['email'] ?? '',
//           data['department'] ?? '',
//           data['yearOfStudy'] ?? '',
//           data['collegeName'] ?? ''
//         ]);
//       }

//       // 4. Convert to CSV String
//       String csvData = const ListToCsvConverter().convert(rows);

//       // 5. Get Directory & Write File
//       final directory = await getTemporaryDirectory();
//       // Sanitize filename to avoid errors with special characters
//       final safeEventName = eventName.replaceAll(RegExp(r'[^\w\s]+'), ''); 
//       final path = "${directory.path}/$safeEventName-Participants.csv";
      
//       final File file = File(path);
//       await file.writeAsString(csvData);

//       // 6. Share the File
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
        
//         final xFile = XFile(path);
//         await Share.shareXFiles(
//           [xFile],
//           text: 'Participant List for $eventName',
//         );
//       }
      
//     } catch (e) {
//       print("Export error: $e");
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error exporting file: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Participants'),
//         actions: [
//           // --- EXPORT BUTTON ---
//           IconButton(
//             icon: const Icon(Icons.share), // Use share icon as it's more accurate
//             tooltip: "Export / Share Excel",
//             onPressed: () => _exportToExcel(context),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(20.0),
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 10.0),
//             child: Text(
//               eventName,
//               style: const TextStyle(fontSize: 14, color: Colors.black54),
//             ),
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('registrations')
//             .where('eventId', isEqualTo: eventId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.person_off, size: 60, color: Colors.grey),
//                   const SizedBox(height: 10),
//                   Text(
//                     "No participants registered yet.",
//                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final participants = snapshot.data!.docs;

//           return ListView.separated(
//             padding: const EdgeInsets.all(12),
//             itemCount: participants.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 10),
//             itemBuilder: (context, index) {
//               final data = participants[index].data() as Map<String, dynamic>;
              
//               final name = data['name'] ?? 'No Name';
//               final rollNo = data['rollNo'] ?? 'N/A';
//               final dept = data['department'] ?? 'N/A';
//               final year = data['yearOfStudy'] ?? 'N/A';
//               final phone = data['phoneNo'] ?? 'N/A';
//               final email = data['email'] ?? 'No Email';

//               return Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               name,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               rollNo,
//                               style: TextStyle(
//                                 color: Colors.blue[800],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Divider(),
//                       const SizedBox(height: 5),
//                       _buildInfoRow(Icons.business, "$dept - $year Year"),
//                       const SizedBox(height: 5),
//                       _buildInfoRow(Icons.phone, phone),
//                       const SizedBox(height: 5),
//                       _buildInfoRow(Icons.email, email),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey[600]),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(color: Colors.grey[800], fontSize: 14),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AdminEventParticipantsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const AdminEventParticipantsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<AdminEventParticipantsScreen> createState() => _AdminEventParticipantsScreenState();
}

class _AdminEventParticipantsScreenState extends State<AdminEventParticipantsScreen> {
  bool _isExporting = false;

  // --- FUNCTION TO GENERATE EXCEL ---
  Future<void> _generateAndExportExcel() async {
    setState(() => _isExporting = true);

    try {
      // 1. Fetch Data from Firebase
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('eventId', isEqualTo: widget.eventId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No participants to export.")),
        );
        setState(() => _isExporting = false);
        return;
      }

      // 2. Create Excel File
      var excel = Excel.createExcel();
      // Remove default "Sheet1" and create a named sheet
      String sheetName = "Participants";
      Sheet sheet = excel[sheetName];
      excel.setDefaultSheet(sheetName);

      // 3. Add Headers (Match the format expected by Certificate Generator)
      // Col A: Serial No, Col B: Name, Col C: Dept, Col D: Email
      sheet.appendRow([
        TextCellValue("Serial No"), 
        TextCellValue("Participant Name"), 
        TextCellValue("Department"), 
        TextCellValue("Email"),
        TextCellValue("Phone")
      ]);

      // 4. Add Data Rows
      int serial = 1;
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        sheet.appendRow([
          IntCellValue(serial),
          TextCellValue(data['name']?.toString() ?? "Unknown"),
          TextCellValue(data['dept']?.toString() ?? "-"),
          TextCellValue(data['email']?.toString() ?? "-"),
          TextCellValue(data['phone']?.toString() ?? "-"),
        ]);
        serial++;
      }

      // 5. Save Excel File
      var fileBytes = excel.save();
      
      final directory = await getTemporaryDirectory();
      final fileName = "${widget.eventName.replaceAll(' ', '_')}_Participants.xlsx";
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(fileBytes!);

      // 6. Share/Open the File
      // This will open the share sheet so you can save it to "Files" or share via WhatsApp
      await Share.shareXFiles([XFile(file.path)], text: "Here is the participant list.");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        actions: [
          // --- EXPORT BUTTON ---
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: "Export to Excel",
                  onPressed: _generateAndExportExcel,
                ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('registrations')
            .where('eventId', isEqualTo: widget.eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No registered participants yet."),
                ],
              ),
            );
          }

          final participants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: participants.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = participants[index].data() as Map<String, dynamic>;
              
              // Safely access fields
              final name = data['name'] ?? 'Unknown';
              final rollNo = data['rollNo'] ?? 'N/A';
              final dept = data['dept'] ?? 'N/A';
              final year = data['year'] ?? '';
              final phone = data['phone'] ?? '';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(name[0].toUpperCase()),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              rollNo,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.business, "$dept - $year Year"),
                      _buildInfoRow(Icons.phone, phone),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }
}