// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle, ByteData;
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';

// class CertificateGeneratorScreen extends StatefulWidget {
//   final String eventName;
//   const CertificateGeneratorScreen({super.key, required this.eventName});

//   @override
//   State<CertificateGeneratorScreen> createState() => _CertificateGeneratorScreenState();
// }

// class _CertificateGeneratorScreenState extends State<CertificateGeneratorScreen> {
//   bool _generating = false;
//   String _statusMessage = "";

//   Future<void> pickExcelAndGenerate() async {
//     try {
//       // 1. Pick Excel File
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['xlsx'],
//         withData: true, 
//       );

//       if (result == null) return; // User cancelled

//       setState(() {
//         _generating = true;
//         _statusMessage = "Processing...";
//       });

//       // 2. Load Template Image
//       pw.MemoryImage? templateImage;
//       try {
//         final ByteData templateBytes = await rootBundle.load('assets/cert_template.jpg');
//         templateImage = pw.MemoryImage(templateBytes.buffer.asUint8List());
//       } catch (e) {
//         debugPrint("Template missing: $e");
//       }

//       // 3. Decode Excel from BYTES (Not Path)
//       if (result.files.single.bytes == null) {
//           throw Exception("Could not read file data. Please try again.");
//       }
//       var bytes = result.files.single.bytes!; 
//       var excel = Excel.decodeBytes(bytes);

//       // 4. Output Folder
//       final outputDir = await getApplicationDocumentsDirectory();
//       final folderName = widget.eventName.replaceAll(RegExp(r'[^\w\s]+'), '');
//       final savePath = "${outputDir.path}/Certificates/$folderName";
//       await Directory(savePath).create(recursive: true);

//       int count = 0;

//       // 5. Generate PDFs
//       for (var table in excel.tables.keys) {
//         var rows = excel.tables[table]!.rows;
//         // Start from i=1 (Skip Header)
//         for (int i = 1; i < rows.length; i++) {
//           final row = rows[i];
//           if (row.length < 2 || row[1] == null) continue; // Need Col 2 (Name)

//           String participantName = row[1]!.value.toString();
          
//           final pdf = pw.Document();
//           pdf.addPage(
//             pw.Page(
//               pageFormat: PdfPageFormat.a4.landscape,
//               margin: pw.EdgeInsets.zero,
//               build: (pw.Context context) {
//                 return pw.Stack(
//                   children: [
//                     if (templateImage != null)
//                       pw.Positioned.fill(child: pw.Image(templateImage, fit: pw.BoxFit.cover)),
                    
//                     // Center the Name
//                     pw.Center(
//                       child: pw.Padding(
//                         padding: const pw.EdgeInsets.only(bottom: 20),
//                         child: pw.Text(
//                           participantName.toUpperCase(),
//                           style: pw.TextStyle(
//                             fontSize: 30, 
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColors.black
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );

//           final cleanName = participantName.replaceAll(RegExp(r'[^\w\s]+'), '');
//           final file = File("$savePath/$cleanName.pdf");
//           await file.writeAsBytes(await pdf.save());
//           count++;
//         }
//       }

//       setState(() => _generating = false);
//       if(mounted) _showSuccess(savePath, count);

//     } catch (e) {
//       setState(() => _generating = false);
//       if(mounted) _showError(e.toString());
//     }
//   }

//   void _showSuccess(String path, int count) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Text(
//                 "Success!",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.green.withOpacity(0.2)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.insert_drive_file, color: Colors.green, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         "Generated $count certificates",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   const Divider(),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Saved at:",
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       path,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontFamily: 'monospace',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text(
//               "OK",
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showError(String error) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.error, color: Colors.red, size: 32),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Text(
//                 "Error",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Could not generate certificates.",
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red.withOpacity(0.2)),
//               ),
//               child: Text(
//                 error,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontFamily: 'monospace',
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text(
//               "Close",
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           "Certificate Generator",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//           ),
//         ),
//         backgroundColor: theme.primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               theme.primaryColor.withOpacity(0.05),
//               Colors.white,
//             ],
//             stops: const [0.0, 0.3],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               // Event Header Card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24.0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       theme.primaryColor,
//                       theme.primaryColor.withOpacity(0.8),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: theme.primaryColor.withOpacity(0.3),
//                       blurRadius: 15,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Icon(
//                         Icons.workspace_premium,
//                         color: Colors.white,
//                         size: 48,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Generating Certificates For',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       widget.eventName,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Process Steps Info Card
//               Container(
//                 padding: const EdgeInsets.all(20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, color: theme.primaryColor, size: 24),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'How It Works',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     _buildStepItem(
//                       number: '1',
//                       title: 'Upload Excel File',
//                       description: 'Select your .xlsx file with participant data',
//                       color: Colors.blue,
//                     ),
//                     _buildStepItem(
//                       number: '2',
//                       title: 'Automatic Processing',
//                       description: 'System reads names from Column B',
//                       color: Colors.orange,
//                     ),
//                     _buildStepItem(
//                       number: '3',
//                       title: 'Generate PDFs',
//                       description: 'Individual certificates created for each participant',
//                       color: Colors.green,
//                       isLast: true,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Excel Format Requirements Card
//               Container(
//                 padding: const EdgeInsets.all(20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16.0),
//                   border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.table_chart, color: Colors.amber[800], size: 24),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Excel Format Required',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.amber[900],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     _buildRequirementItem('Column A: Serial Number (1, 2, 3...)'),
//                     _buildRequirementItem('Column B: Participant Name'),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
//                           const SizedBox(width: 8),
//                           const Expanded(
//                             child: Text(
//                               'First row will be treated as header and skipped',
//                               style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // Main Action Card
//               _generating ? _buildLoadingCard() : _buildUploadCard(theme),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStepItem({
//     required String number,
//     required String title,
//     required String description,
//     required Color color,
//     bool isLast = false,
//   }) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequirementItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(Icons.check_circle, color: Colors.amber[700], size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUploadCard(ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: pickExcelAndGenerate,
//           borderRadius: BorderRadius.circular(20.0),
//           child: Container(
//             padding: const EdgeInsets.all(40.0),
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         theme.colorScheme.secondary.withOpacity(0.1),
//                         theme.colorScheme.secondary.withOpacity(0.05),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Icon(
//                     Icons.cloud_upload_outlined,
//                     size: 64,
//                     color: theme.colorScheme.secondary,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Upload Excel File',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Click to select your .xlsx file',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.secondary,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.file_upload, color: Colors.white, size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Start Generation',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingCard() {
//     return Container(
//       padding: const EdgeInsets.all(40.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//               ),
//               const SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 5,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Generating Certificates...',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _statusMessage,
//             style: TextStyle(
//               fontSize: 15,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.hourglass_top, size: 18, color: Colors.blue[700]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Please wait, this may take a moment',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CertificateGeneratorScreen extends StatefulWidget {
  final String eventName;
  const CertificateGeneratorScreen({super.key, required this.eventName});

  @override
  State<CertificateGeneratorScreen> createState() => _CertificateGeneratorScreenState();
}

class _CertificateGeneratorScreenState extends State<CertificateGeneratorScreen> {
  bool _generating = false;
  String _statusMessage = "";

  Future<void> pickExcelAndGenerate() async {
    try {
      // 1. Pick Excel File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        // 👇👇👇 THIS IS THE KEY FIX YOU ARE MISSING 👇👇👇
        withData: true, 
        // 👆👆👆 WITHOUT THIS, IT WILL FAIL ON ANDROID 👆👆👆
      );

      if (result == null) return; // User cancelled

      setState(() {
        _generating = true;
        _statusMessage = "Processing...";
      });

      // 2. Load Template Image
      pw.MemoryImage? templateImage;
      try {
        final ByteData templateBytes = await rootBundle.load('assets/cert_template.jpg');
        templateImage = pw.MemoryImage(templateBytes.buffer.asUint8List());
      } catch (e) {
        debugPrint("Template missing: $e");
      }

      // 3. Decode Excel from BYTES (Not Path)
      // This is the key fix for the "fail" error
      if (result.files.single.bytes == null) {
          throw Exception("Could not read file data. Please try again.");
      }
      var bytes = result.files.single.bytes!; 
      var excel = Excel.decodeBytes(bytes);

      // 4. Output Folder
      final outputDir = await getApplicationDocumentsDirectory();
      final folderName = widget.eventName.replaceAll(RegExp(r'[^\w\s]+'), '');
      final savePath = "${outputDir.path}/Certificates/$folderName";
      await Directory(savePath).create(recursive: true);

      int count = 0;

      // 5. Generate PDFs
      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;
        // Start from i=1 (Skip Header)
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length < 2 || row[1] == null) continue; // Need Col 2 (Name)

          String participantName = row[1]!.value.toString();
          
          final pdf = pw.Document();
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4.landscape,
              margin: pw.EdgeInsets.zero,
              build: (pw.Context context) {
                return pw.Stack(
                  children: [
                    if (templateImage != null)
                      pw.Positioned.fill(child: pw.Image(templateImage, fit: pw.BoxFit.cover)),
                    
                    // Center the Name
                    pw.Center(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 20), // Adjust this to move text up/down
                        child: pw.Text(
                          participantName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 30, 
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );

          final cleanName = participantName.replaceAll(RegExp(r'[^\w\s]+'), '');
          final file = File("$savePath/$cleanName.pdf");
          await file.writeAsBytes(await pdf.save());
          count++;
        }
      }

      setState(() => _generating = false);
      if(mounted) _showSuccess(savePath, count);

    } catch (e) {
      setState(() => _generating = false);
      if(mounted) _showError(e.toString());
    }
  }

  void _showSuccess(String path, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: Text("Generated $count certificates.\n\nSaved at:\n$path"),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  void _showError(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text("Could not generate certificates.\n\n$error"),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Certificates")),
      body: Center(
        child: _generating
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  const CircularProgressIndicator(), 
                  const SizedBox(height: 20), 
                  Text(_statusMessage)
                ]
              )
            : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                icon: const Icon(Icons.upload_file, size: 30),
                label: const Text("Upload Excel & Generate\n(Col A: Serial, Col B: Name)", textAlign: TextAlign.center),
                onPressed: pickExcelAndGenerate,
              ),
      ),
    );
  }
}