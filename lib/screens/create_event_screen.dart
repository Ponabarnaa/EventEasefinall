// lib/screens/create_event_screen.dart

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

  File? _pickedImageFile; // Mobile/Desktop
  Uint8List? _pickedImageBytes; // Web
  bool _isLoading = false;

  // ---------------- PICK IMAGE ----------------
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (kIsWeb) {
      // Web: use bytes
      final bytes = await image.readAsBytes();
      setState(() => _pickedImageBytes = bytes);
    } else {
      // Mobile/Desktop: use File
      setState(() => _pickedImageFile = File(image.path));
    }
  }

  // ---------------- CLOUDINARY UPLOAD ----------------
  Future<String?> uploadToCloudinary() async {
    const cloudName = "dtbjwyq2p";
    const uploadPreset = "event_poster";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    var request = http.MultipartRequest("POST", url);

    request.fields["upload_preset"] = uploadPreset;

    if (kIsWeb) {
      // ------- WEB UPLOAD (BYTE ARRAY) -------
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          _pickedImageBytes!,
          filename: "poster.png",
        ),
      );
    } else {
      // ------- MOBILE UPLOAD (FILE PATH) -------
      request.files.add(
        await http.MultipartFile.fromPath("file", _pickedImageFile!.path),
      );
    }

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(result.body);
      return data["secure_url"];
    } else {
      print("Cloudinary Error: ${result.body}");
      return null;
    }
  }

  // ---------------- SUBMIT EVENT ----------------
  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage("Please fill all fields");
      return;
    }

    if (_pickedImageFile == null && _pickedImageBytes == null) {
      _showMessage("Please select event poster");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = await uploadToCloudinary();

      if (imageUrl == null) {
        _showMessage("Image upload failed!");
        return;
      }

      await _firestore.collection("events").add({
        "name": _nameController.text.trim(),
        "venue": _venueController.text.trim(),
        "time": _timeController.text.trim(),
        "department": _deptController.text.trim(),
        "posterUrl": imageUrl,
        "status": "Upcoming",
        "createdAt": Timestamp.now(),
      });

      _showMessage("Event posted successfully");
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("Event Name", _nameController),
              _buildField("Venue", _venueController),
              _buildField("Time", _timeController),
              _buildField("Department", _deptController),
              const SizedBox(height: 20),

              // ----------- IMAGE PICKER BOX -----------
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildImagePreview(),
                ),
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitEvent,
                      child: const Text("Post Event"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- IMAGE PREVIEW UI ----------
  Widget _buildImagePreview() {
    if (kIsWeb && _pickedImageBytes != null) {
      return Image.memory(_pickedImageBytes!, fit: BoxFit.cover);
    }

    if (!kIsWeb && _pickedImageFile != null) {
      return Image.file(_pickedImageFile!, fit: BoxFit.cover);
    }

    return const Center(child: Text("Tap to select poster"));
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }
}
