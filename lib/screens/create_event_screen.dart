// lib/screens/create_event_screen.dart

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // Import for date/time formatting

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

  // New State Variables for Date, Time, and Year
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedYear; // 1st, 2nd, 3rd, 4th

  File? _pickedImageFile; // Mobile/Desktop
  Uint8List? _pickedImageBytes; // Web
  bool _isLoading = false;

  // --- Date Picker Function ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- Time Picker Function ---
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

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

    // Additional validation for date/time/year
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedYear == null) {
      _showMessage("Please select Date, Time, and Year.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = await uploadToCloudinary();

      if (imageUrl == null) {
        _showMessage("Image upload failed!");
        return;
      }

      // Combine Date and Time into a single formatted string for storage
      final DateFormat dateFormatter = DateFormat('EEE, MMM d, yyyy');
      final String formattedDate = dateFormatter.format(_selectedDate!);
      final String formattedTime = _selectedTime!.format(context);
      final String dateTimeString = '$formattedDate at $formattedTime';

      await _firestore.collection("events").add({
        "name": _nameController.text.trim(),
        "venue": _venueController.text.trim(),
        "dateTime": dateTimeString, // Use the combined date/time string
        "department": _deptController.text.trim(),
        "year": _selectedYear, // Include the selected year
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Name
              _buildField("Event Name", _nameController),
              // Venue
              _buildField("Venue", _venueController),

              // Date Picker
              _buildDateTimePicker(
                label: 'Date',
                icon: Icons.calendar_today,
                valueText: _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('dd MMM yyyy').format(_selectedDate!),
                onTap: _pickDate,
              ),

              // Time Picker
              _buildDateTimePicker(
                label: 'Time',
                icon: Icons.access_time,
                valueText: _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context),
                onTap: _pickTime,
              ),

              // Department
              _buildField("Department", _deptController),

              const SizedBox(height: 8),

              // Year Dropdown (NEW)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Target Year',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                value: _selectedYear,
                hint: const Text('Select Year of Study (e.g., 1st, 2nd)'),
                items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text(year)),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedYear = newValue;
                  });
                },
                validator: (value) => value == null ? "Required" : null,
              ),

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

              const SizedBox(height: 30),

              // ----------- BUTTONS ROW (UPDATED STYLING) -----------
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Go back
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Post Event Button (MODIFIED FOR STAR ICON AND ROUNDED STYLE)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitEvent,
                            icon: const Icon(
                              // Added Icon
                              Icons.star,
                              color: Colors
                                  .white, // Ensure icon color contrasts with button color
                            ),
                            label: const Text(
                              // Updated to use label for text
                              "Post", // Text changed to "Post"
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              // Customize color if needed, otherwise it uses the theme's primary color
                              // backgroundColor: const Color(0xFF5C6BC0), // Example: Indigo color
                              foregroundColor:
                                  Colors.white, // Text and icon color
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  50,
                                ), // Increased radius for pill shape
                              ),
                              elevation: 5, // Added elevation for shadow
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Helper for TextFormFields ----------
  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  // ---------- Helper for Date/Time Pickers ----------
  Widget _buildDateTimePicker({
    required String label,
    required IconData icon,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
          ),
          child: Text(valueText, style: const TextStyle(fontSize: 16)),
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
}
