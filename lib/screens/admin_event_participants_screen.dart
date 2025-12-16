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

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            Text(
              widget.eventName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          // --- EXPORT BUTTON ---
          _isExporting
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.file_download_rounded),
                    tooltip: "Export to Excel",
                    onPressed: _generateAndExportExcel,
                  ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading participants...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No Participants Yet",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Registrations will appear here",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final participants = snapshot.data!.docs;

          return Column(
            children: [
              // Stats Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Registrations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${participants.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Participants List
              Expanded(
                child: ListView.builder(
                  itemCount: participants.length,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = participants[index].data() as Map<String, dynamic>;
                    
                    // Safely access fields
                    final name = data['name'] ?? 'Unknown';
                    final rollNo = data['rollNo'] ?? 'N/A';
                    final dept = data['dept'] ?? 'N/A';
                    final year = data['year'] ?? '';
                    final phone = data['phone'] ?? '';
                    final email = data['email'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Enhanced Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getAvatarColor(index),
                                        _getAvatarColor(index).withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getAvatarColor(index).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[900],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          rollNo,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.school_rounded,
                                    "$dept - $year Year",
                                    Colors.purple,
                                  ),
                                  if (phone.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.phone_rounded,
                                      phone,
                                      Colors.green,
                                    ),
                                  ],
                                  if (email.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.email_rounded,
                                      email,
                                      Colors.orange,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    if (text.isEmpty || text == ' - ') return const SizedBox.shrink();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}