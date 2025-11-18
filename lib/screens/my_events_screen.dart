// lib/screens/my_events_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_details_form_screen.dart';

/// Screen to show user's submitted events and their status
/// ALSO includes Form 1 to request new events
class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedEventType;
  String? _selectedCollegeReach;
  bool _isSubmitting = false;

  final List<String> _eventTypes = [
    'Technical',
    'Cultural',
    'Sports',
    'Academic',
    'Other',
  ];
  final List<String> _collegeReachOptions = [
    'Department',
    'College-wide',
    'Inter-college',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitEventRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await FirebaseFirestore.instance.collection('pendingEvents').add({
        'name': _nameController.text.trim(),
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'location': _locationController.text.trim(),
        'department': _departmentController.text.trim(),
        'eventType': _selectedEventType,
        'collegeReach': _selectedCollegeReach,
        'description': _descriptionController.text.trim(),
        'status': 'pending',
        'requestedBy': currentUser.uid,
        'requestedByEmail': currentUser.email,
        'requestedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'form2Submitted': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        _locationController.clear();
        _departmentController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedEventType = null;
          _selectedCollegeReach = null;
        });
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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your events'));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Request Status Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Request Status',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pendingEvents')
                        .where('requestedBy', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'You have not submitted any event requests yet.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      final events = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final eventData =
                              events[index].data() as Map<String, dynamic>;
                          final eventId = events[index].id;
                          final status = eventData['status'] ?? 'pending';
                          final eventName =
                              eventData['name'] ?? 'Unnamed Event';
                          final rejectionReason = eventData['rejectionReason'];
                          final form2Submitted =
                              eventData['form2Submitted'] ?? false;

                          return _EventCard(
                            eventId: eventId,
                            eventName: eventName,
                            status: status,
                            eventData: eventData,
                            rejectionReason: rejectionReason,
                            form2Submitted: form2Submitted,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8),

            // Request a New Event Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request a New Event',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Event Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Event Name',
                            prefixIcon: Icon(Icons.event),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter event name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Event Type
                        DropdownButtonFormField<String>(
                          value: _selectedEventType,
                          decoration: const InputDecoration(
                            labelText: 'Event Type',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: _eventTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEventType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select event type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // College Reach
                        DropdownButtonFormField<String>(
                          value: _selectedCollegeReach,
                          decoration: const InputDecoration(
                            labelText: 'College Reach',
                            prefixIcon: Icon(Icons.public),
                            border: OutlineInputBorder(),
                          ),
                          items: _collegeReachOptions.map((reach) {
                            return DropdownMenuItem(
                              value: reach,
                              child: Text(reach),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCollegeReach = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select college reach';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Department
                        TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            prefixIcon: Icon(Icons.school),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter department';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          onTap: _selectDate,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Time
                        TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                          onTap: _selectTime,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select time';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : _submitEventRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                    'Submit Event Request',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String eventId;
  final String eventName;
  final String status;
  final Map<String, dynamic> eventData;
  final String? rejectionReason;
  final bool form2Submitted;

  const _EventCard({
    required this.eventId,
    required this.eventName,
    required this.status,
    required this.eventData,
    this.rejectionReason,
    required this.form2Submitted,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'form2_submitted':
        return Colors.blue;
      case 'published':
        return Colors.purple;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'form2_submitted':
        return Icons.upload_file;
      case 'published':
        return Icons.public;
      case 'declined':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'APPROVED - Complete Details';
      case 'form2_submitted':
        return 'UNDER REVIEW';
      case 'published':
        return 'PUBLISHED';
      case 'declined':
        return 'DECLINED';
      case 'pending':
      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Name and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(), size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Event Details
            _buildDetailRow(
              Icons.calendar_today,
              eventData['date'] ?? 'No date',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.location_on,
              eventData['location'] ?? 'No location',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.category,
              eventData['eventType'] ?? 'No type',
            ),

            // Decline Reason (if declined)
            if (status.toLowerCase() == 'declined' &&
                rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reason for Decline:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rejectionReason!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ],
                ),
              ),
            ],

            // Action Button (if approved and form2 not submitted)
            if (status.toLowerCase() == 'approved' && !form2Submitted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsFormScreen(
                          eventId: eventId,
                          eventName: eventName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Complete Event Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            // Form 2 submitted indicator
            if (form2Submitted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Additional details submitted',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
}
