// lib/screens/create_event_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

  File? _pickedImage;
  bool _isLoading = false;

  // --- Image Picking Function ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // --- Submission Function (Upload Image and Data to Firebase) ---
  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate() || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a poster.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Upload Image to Firebase Storage
      final ref = _storage
          .ref()
          .child('event_posters')
          .child('${DateTime.now().toIso8601String()}.jpg');

      await ref.putFile(_pickedImage!);
      final imageUrl = await ref.getDownloadURL();

      // 2. Save Event Details (including image URL) to Firestore
      await _firestore.collection('events').add({
        'name': _nameController.text.trim(),
        'venue': _venueController.text.trim(),
        'time': _timeController.text.trim(),
        'department': _deptController.text.trim(),
        'posterUrl': imageUrl,
        'status': 'Upcoming', // Default status for new events
        'createdAt': Timestamp.now(),
      });

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event posted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error posting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during posting.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: Event Details
              const Center(
                child: Text(
                  'Event Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // --- Form Fields ---
              _buildInputField('Event Name:', _nameController),
              _buildInputField('Venue:', _venueController),
              _buildInputField('Time:', _timeController),
              _buildInputField('Department:', _deptController),

              const SizedBox(height: 20),

              // --- Image Picker Area ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 50, color: Colors.grey), //
                            Text('Tap to select event poster'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),

              // --- Action Buttons ---
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Post Button
                    _buildActionButton(
                      'Post',
                      Icons.star,
                      Theme.of(context).primaryColor,
                      _submitEvent,
                    ),

                    // Cancel Button
                    _buildActionButton(
                      'Cancel',
                      Icons.star,
                      Colors.grey,
                      () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar (Matching Admin Home)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Stays on Home/Create for this page
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        iconSize: 30,
        onTap: (index) {
          // You might implement different actions here, e.g., popping to a specific screen
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Help',
          ), //
        ],
      ),
    );
  }

  // Helper Widget for consistent input field styling
  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label, // Displays labels: Event Name, Venue, etc.
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required.';
          }
          return null;
        },
      ),
    );
  }

  // Helper Widget for consistent button styling
  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
      ),
    );
  }
}
