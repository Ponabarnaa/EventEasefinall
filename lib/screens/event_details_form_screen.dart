// lib/screens/event_details_form_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Form 2: Additional Event Details (shown after admin approval)
/// User can upload: Registration Link, Date, Poster, Promo Video
class EventDetailsFormScreen extends StatefulWidget {
  final String eventId; // The approved event's document ID
  final String eventName;

  const EventDetailsFormScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<EventDetailsFormScreen> createState() => _EventDetailsFormScreenState();
}

class _EventDetailsFormScreenState extends State<EventDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _registrationLinkController =
      TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _promoVideoLinkController =
      TextEditingController();

  File? _posterImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _registrationLinkController.dispose();
    _eventDateController.dispose();
    _promoVideoLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickPosterImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _posterImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _eventDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_posterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a poster image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // In a real app, you would upload the poster image to Firebase Storage
      // and get a download URL. For now, we'll use a placeholder.
      String posterUrl = 'placeholder_poster_url';

      // Update the event document with Form 2 data
      await FirebaseFirestore.instance
          .collection('pendingEvents')
          .doc(widget.eventId)
          .update({
            'registrationLink': _registrationLinkController.text.trim(),
            'finalEventDate': _eventDateController.text.trim(),
            'posterUrl': posterUrl,
            'promoVideoLink': _promoVideoLinkController.text.trim(),
            'form2Submitted': true,
            'form2SubmittedAt': FieldValue.serverTimestamp(),
            'status':
                'form2_submitted', // Now waiting for admin to verify and publish
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event details submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Event Details'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Congratulations Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Congratulations! 🎉',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your event "${widget.eventName}" has been approved!',
                            style: TextStyle(color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Additional Event Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide the following details to finalize your event.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Registration Link
              TextFormField(
                controller: _registrationLinkController,
                decoration: const InputDecoration(
                  labelText: 'Registration Link',
                  hintText: 'https://forms.google.com/...',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the registration link';
                  }
                  if (!value.startsWith('http')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Event Date
              TextFormField(
                controller: _eventDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  hintText: 'Select event date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the event date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Poster Upload
              const Text(
                'Event Poster *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickPosterImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: _posterImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload poster',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_posterImage!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Promo Video Link (Optional)
              TextFormField(
                controller: _promoVideoLinkController,
                decoration: const InputDecoration(
                  labelText: 'Promo Video Link (Optional)',
                  hintText: 'https://youtube.com/...',
                  prefixIcon: Icon(Icons.video_library),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.startsWith('http')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
