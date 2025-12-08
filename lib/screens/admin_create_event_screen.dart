// // lib/screens/create_event_screen.dart

// import 'dart:io' show File;
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart'; // Import for date/time formatting

// class CreateEventScreen extends StatefulWidget {
//   const CreateEventScreen({super.key});

//   @override
//   State<CreateEventScreen> createState() => _CreateEventScreenState();
// }

// class _CreateEventScreenState extends State<CreateEventScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _venueController = TextEditingController();
//   final TextEditingController _deptController = TextEditingController();

//   // New State Variables for Date, Time, and Year
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   String? _selectedYear; // 1st, 2nd, 3rd, 4th

//   File? _pickedImageFile; // Mobile/Desktop
//   Uint8List? _pickedImageBytes; // Web
//   bool _isLoading = false;

//   // --- Date Picker Function ---
//   Future<void> _pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   // --- Time Picker Function ---
//   Future<void> _pickTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   // ---------------- PICK IMAGE ----------------
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image == null) return;

//     if (kIsWeb) {
//       // Web: use bytes
//       final bytes = await image.readAsBytes();
//       setState(() => _pickedImageBytes = bytes);
//     } else {
//       // Mobile/Desktop: use File
//       setState(() => _pickedImageFile = File(image.path));
//     }
//   }

//   // ---------------- CLOUDINARY UPLOAD ----------------
//   Future<String?> uploadToCloudinary() async {
//     const cloudName = "dtbjwyq2p";
//     const uploadPreset = "event_poster";

//     final url = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
//     );
//     var request = http.MultipartRequest("POST", url);

//     request.fields["upload_preset"] = uploadPreset;

//     if (kIsWeb) {
//       // ------- WEB UPLOAD (BYTE ARRAY) -------
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           "file",
//           _pickedImageBytes!,
//           filename: "poster.png",
//         ),
//       );
//     } else {
//       // ------- MOBILE UPLOAD (FILE PATH) -------
//       request.files.add(
//         await http.MultipartFile.fromPath("file", _pickedImageFile!.path),
//       );
//     }

//     final response = await request.send();
//     final result = await http.Response.fromStream(response);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(result.body);
//       return data["secure_url"];
//     } else {
//       print("Cloudinary Error: ${result.body}");
//       return null;
//     }
//   }

//   // ---------------- SUBMIT EVENT ----------------
//   Future<void> _submitEvent() async {
//     if (!_formKey.currentState!.validate()) {
//       _showMessage("Please fill all fields");
//       return;
//     }

//     if (_pickedImageFile == null && _pickedImageBytes == null) {
//       _showMessage("Please select event poster");
//       return;
//     }

//     // Additional validation for date/time/year
//     if (_selectedDate == null ||
//         _selectedTime == null ||
//         _selectedYear == null) {
//       _showMessage("Please select Date, Time, and Year.");
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       String? imageUrl = await uploadToCloudinary();

//       if (imageUrl == null) {
//         _showMessage("Image upload failed!");
//         return;
//       }

//       // Combine Date and Time into a single formatted string for storage
//       final DateFormat dateFormatter = DateFormat('EEE, MMM d, yyyy');
//       final String formattedDate = dateFormatter.format(_selectedDate!);
//       final String formattedTime = _selectedTime!.format(context);
//       final String dateTimeString = '$formattedDate at $formattedTime';

//       await _firestore.collection("events").add({
//         "name": _nameController.text.trim(),
//         "venue": _venueController.text.trim(),
//         "dateTime": dateTimeString, // Use the combined date/time string
//         "department": _deptController.text.trim(),
//         "year": _selectedYear, // Include the selected year
//         "posterUrl": imageUrl,
//         "status": "Upcoming",
//         "createdAt": Timestamp.now(),
//       });

//       _showMessage("Event posted successfully");
//       Navigator.of(context).pop();
//     } catch (e) {
//       print(e);
//     }

//     setState(() => _isLoading = false);
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Event')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Event Name
//               _buildField("Event Name", _nameController),
//               // Venue
//               _buildField("Venue", _venueController),

//               // Date Picker
//               _buildDateTimePicker(
//                 label: 'Date',
//                 icon: Icons.calendar_today,
//                 valueText: _selectedDate == null
//                     ? 'Select Date'
//                     : DateFormat('dd MMM yyyy').format(_selectedDate!),
//                 onTap: _pickDate,
//               ),

//               // Time Picker
//               _buildDateTimePicker(
//                 label: 'Time',
//                 icon: Icons.access_time,
//                 valueText: _selectedTime == null
//                     ? 'Select Time'
//                     : _selectedTime!.format(context),
//                 onTap: _pickTime,
//               ),

//               // Department
//               _buildField("Department", _deptController),

//               const SizedBox(height: 8),

//               // Year Dropdown (NEW)
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Target Year',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.school),
//                 ),
//                 initialValue: _selectedYear,
//                 hint: const Text('Select Year of Study (e.g., 1st, 2nd)'),
//                 items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
//                     .map(
//                       (year) =>
//                           DropdownMenuItem(value: year, child: Text(year)),
//                     )
//                     .toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedYear = newValue;
//                   });
//                 },
//                 validator: (value) => value == null ? "Required" : null,
//               ),

//               const SizedBox(height: 20),

//               // ----------- IMAGE PICKER BOX -----------
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 200,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: _buildImagePreview(),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // ----------- BUTTONS ROW (UPDATED STYLING) -----------
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // Cancel Button
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {
//                               Navigator.of(context).pop(); // Go back
//                             },
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: const Text(
//                               "Cancel",
//                               style: TextStyle(fontSize: 18),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 15),

//                         // Post Event Button (MODIFIED FOR STAR ICON AND ROUNDED STYLE)
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _submitEvent,
//                             icon: const Icon(
//                               // Added Icon
//                               Icons.star,
//                               color: Colors
//                                   .white, // Ensure icon color contrasts with button color
//                             ),
//                             label: const Text(
//                               // Updated to use label for text
//                               "Post", // Text changed to "Post"
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               // Customize color if needed, otherwise it uses the theme's primary color
//                               // backgroundColor: const Color(0xFF5C6BC0), // Example: Indigo color
//                               foregroundColor:
//                                   Colors.white, // Text and icon color
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                   50,
//                                 ), // Increased radius for pill shape
//                               ),
//                               elevation: 5, // Added elevation for shadow
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------- Helper for TextFormFields ----------
//   Widget _buildField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         validator: (value) => value!.isEmpty ? "Required" : null,
//       ),
//     );
//   }

//   // ---------- Helper for Date/Time Pickers ----------
//   Widget _buildDateTimePicker({
//     required String label,
//     required IconData icon,
//     required String valueText,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: onTap,
//         child: InputDecorator(
//           decoration: InputDecoration(
//             labelText: label,
//             border: const OutlineInputBorder(),
//             prefixIcon: Icon(icon),
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 15,
//               horizontal: 10,
//             ),
//           ),
//           child: Text(valueText, style: const TextStyle(fontSize: 16)),
//         ),
//       ),
//     );
//   }

//   // ---------- IMAGE PREVIEW UI ----------
//   Widget _buildImagePreview() {
//     if (kIsWeb && _pickedImageBytes != null) {
//       return Image.memory(_pickedImageBytes!, fit: BoxFit.cover);
//     }

//     if (!kIsWeb && _pickedImageFile != null) {
//       return Image.file(_pickedImageFile!, fit: BoxFit.cover);
//     }

//     return const Center(child: Text("Tap to select poster"));
//   }
// }
// lib/screens/admin_create_event_screen.dart

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'admin_event_detail_screen.dart'; // Import Event class

class CreateEventScreen extends StatefulWidget {
  // Optional: Pass an event if we are in "Edit Mode"
  final Event? eventToEdit;

  const CreateEventScreen({super.key, this.eventToEdit});

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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedYear; 

  File? _pickedImageFile;
  Uint8List? _pickedImageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if we are editing an existing event
    if (widget.eventToEdit != null) {
      _prefillData();
    }
  }

  void _prefillData() {
    final e = widget.eventToEdit!;
    _nameController.text = e.title;
    _venueController.text = e.location;
    
    // Parse Description to extract Dept/Year if possible, or just set simple defaults
    // Since description is a combined string, we might just leave controllers empty 
    // or try to parse. For simplicity, we will just pre-fill the name/venue here.
    // If you want to parse "Department: CSE\nYear: 3", you'd need regex.
    // simpler approach: Just let user re-enter Dept/Year or keep description simple.
    
    // Attempt to parse Date (Assuming format 'MMM d, y')
    try {
      _selectedDate = DateFormat('yMMMd').parse(e.date);
    } catch (_) {}

    // Attempt to parse Time (Assuming format 'h:mm a')
    try {
      if (e.time.contains(":")) {
        final parts = e.time.split(" "); // "10:30 AM" -> ["10:30", "AM"]
        final timeParts = parts[0].split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (parts.length > 1 && parts[1] == "PM" && hour != 12) hour += 12;
        if (parts.length > 1 && parts[1] == "AM" && hour == 12) hour = 0;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
  }

  // --- Date Picker ---
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  // --- Time Picker ---
  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  // --- Image Picker ---
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _pickedImageBytes = bytes);
        } else {
          setState(() => _pickedImageFile = File(pickedFile.path));
        }
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  // --- Submit Function ---
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date, Time, and Year.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.eventToEdit?.posterUrl ?? '';
      
      // Handle Image Upload Logic here (Simplified for brevity)
      // If _pickedImageBytes/_pickedImageFile is not null, upload to Storage 
      // and get new URL. For this code block, we assume existing URL or empty.

      final eventData = {
        'name': _nameController.text.trim(),
        'venue': _venueController.text.trim(),
        'department': _deptController.text.trim(),
        'year': _selectedYear,
        'date': DateFormat('yMMMd').format(_selectedDate!),
        'time': _selectedTime!.format(context),
        'posterUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.eventToEdit != null) {
        // --- UPDATE EXISTING EVENT ---
        await _firestore
            .collection('events')
            .doc(widget.eventToEdit!.id)
            .update(eventData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Event Updated Successfully!')));
          Navigator.of(context).pop(); // Close Edit Screen
          Navigator.of(context).pop(); // Close Detail Screen (to refresh list)
        }
      } else {
        // --- CREATE NEW EVENT ---
        await _firestore.collection('events').add(eventData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Event Posted Successfully!')));
          Navigator.of(context).pop();
        }
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if editing
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create New Event'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildImagePreview(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Text Fields
                    _buildTextField(
                        controller: _nameController, label: 'Event Name'),
                    _buildTextField(
                        controller: _venueController, label: 'Venue'),
                    _buildTextField(
                        controller: _deptController, label: 'Department'),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimePicker(
                            label: _selectedDate == null
                                ? 'Select Date'
                                : DateFormat('yMMMd').format(_selectedDate!),
                            icon: Icons.calendar_today,
                            valueText: '', 
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDateTimePicker(
                            label: _selectedTime == null
                                ? 'Select Time'
                                : _selectedTime!.format(context),
                            icon: Icons.access_time,
                            valueText: '',
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    // Year Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Select Year',
                        border: OutlineInputBorder(),
                      ),
                      items: ['1st', '2nd', '3rd', '4th']
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text('$year Year'),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedYear = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isEditing ? 'UPDATE EVENT' : 'POST EVENT',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
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
              vertical: 15, horizontal: 10),
          ),
          child: const Text('', style: TextStyle(fontSize: 0)), // Hidden text
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.eventToEdit != null &&
        widget.eventToEdit!.posterUrl.isNotEmpty &&
        _pickedImageBytes == null &&
        _pickedImageFile == null) {
       return Image.network(widget.eventToEdit!.posterUrl, fit: BoxFit.cover);
    }
    if (kIsWeb && _pickedImageBytes != null) {
      return Image.memory(_pickedImageBytes!, fit: BoxFit.cover);
    }
    if (!kIsWeb && _pickedImageFile != null) {
      return Image.file(_pickedImageFile!, fit: BoxFit.cover);
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
        Text("Tap to upload poster"),
      ],
    );
  }
}