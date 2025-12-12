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