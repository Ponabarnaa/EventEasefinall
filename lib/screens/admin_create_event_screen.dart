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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          isEditing ? 'Edit Event' : 'Create New Event',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
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
                    isEditing ? 'Updating Event...' : 'Creating Event...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Text(
                        'Event Poster',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Image Picker Card
                      GestureDetector(
                        onTap: _pickImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildImagePreview(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tap to upload event poster',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Event Details Section
                      Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Event Name Card
                      _buildTextField(
                        controller: _nameController,
                        label: 'Event Name',
                        icon: Icons.event,
                        hint: 'Enter event name',
                      ),

                      // Venue Card
                      _buildTextField(
                        controller: _venueController,
                        label: 'Venue',
                        icon: Icons.location_on,
                        hint: 'Enter venue location',
                      ),

                      // Department Card
                      _buildTextField(
                        controller: _deptController,
                        label: 'Department',
                        icon: Icons.business,
                        hint: 'Enter department name',
                      ),

                      const SizedBox(height: 24),

                      // Schedule Section
                      Text(
                        'Event Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date & Time Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimePicker(
                              label: 'Date',
                              displayText: _selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM d, y').format(_selectedDate!),
                              icon: Icons.calendar_today,
                              onTap: _pickDate,
                              isSelected: _selectedDate != null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateTimePicker(
                              label: 'Time',
                              displayText: _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                              icon: Icons.access_time,
                              onTap: _pickTime,
                              isSelected: _selectedTime != null,
                            ),
                          ),
                        ],
                      ),

                      // Year Dropdown Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Academic Year',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(
                              Icons.school,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          items: ['1st', '2nd', '3rd', '4th']
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      '$year Year',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedYear = val),
                          validator: (val) => val == null ? 'Please select year' : null,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEditing ? Icons.check_circle : Icons.publish,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isEditing ? 'UPDATE EVENT' : 'POST EVENT',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) => value!.isEmpty ? "$label is required" : null,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String displayText,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.eventToEdit != null &&
        widget.eventToEdit!.posterUrl.isNotEmpty &&
        _pickedImageBytes == null &&
        _pickedImageFile == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.eventToEdit!.posterUrl,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (kIsWeb && _pickedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      );
    }
    if (!kIsWeb && _pickedImageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_pickedImageFile!, fit: BoxFit.cover),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Upload Event Poster",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Tap to browse files",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}