// lib/screens/event_request_screen.dart
import 'package:flutter/material.dart';

class EventRequestScreen extends StatefulWidget {
  const EventRequestScreen({super.key});

  @override
  State<EventRequestScreen> createState() => _EventRequestScreenState();
}

class _EventRequestScreenState extends State<EventRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Field Controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _hodController = TextEditingController();

  // Dropdown States
  String? _eventType;
  String? _targetYear;

  // Radio Button State
  String _collegeType = 'Intra College'; // Default

  // Dynamic Lists for Coordinators
  List<String> _eventCoordinators = [''];
  List<String> _staffCoordinators = [''];

  // Dropdown options
  final List<String> _eventTypes = [
    'Technical',
    'Non-Technical',
    'Workshop',
    'Event',
  ];
  final List<String> _targetYears = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _departmentController.dispose();
    _venueController.dispose();
    _hodController.dispose();
    super.dispose();
  }

  void _addCoordinator(List<String> list) {
    setState(() {
      list.add('');
    });
  }

  void _removeCoordinator(List<String> list, int index) {
    setState(() {
      if (list.length > 1) {
        list.removeAt(index);
      }
    });
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Basic validation for coordinators
      if (_eventCoordinators.any((c) => c.isEmpty) ||
          _staffCoordinators.any((c) => c.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all coordinator fields.')),
        );
        return;
      }

      // --- Submission Logic Placeholder ---
      // In a real app, you would send this data to Firebase Firestore
      print('--- Event Request Submitted ---');
      print('Event Name: ${_eventNameController.text}');
      print(
        'Date: ${_dateController.text}, Time: ${_startTimeController.text} - ${_endTimeController.text}',
      );
      print(
        'Type: $_eventType, Target Year: $_targetYear, College Type: $_collegeType',
      );
      print('Event Coordinators: $_eventCoordinators');
      print('Staff Coordinators: $_staffCoordinators');
      print('HOD: ${_hodController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event Request Submitted Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _eventCoordinators = [''];
        _staffCoordinators = [''];
        _collegeType = 'Intra College';
      });
    }
  }

  // Widget to generate dynamic coordinator fields
  Widget _buildCoordinatorFields({
    required List<String> list,
    required String label,
    required bool isStaff,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...list.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: list[index],
                    decoration: InputDecoration(
                      labelText: '${label.split(' ')[0]} ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      list[index] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                if (list.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeCoordinator(list, index),
                  ),
              ],
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _addCoordinator(list),
            icon: const Icon(Icons.add),
            label: Text('Add Another ${label.split(' ')[0]}'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Event Name ---
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the event name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Date & Time ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (DD/MM/YY)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2028),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year % 100}';
                        });
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Date is required.' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _startTimeController.text = pickedTime.format(
                            context,
                          );
                        });
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Time is required.' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'End Time is required.' : null,
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _endTimeController.text = pickedTime.format(context);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Type (Dropdown) ---
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: const InputDecoration(
                labelText: 'Event Type (Technical, Workshop, etc.)',
                border: OutlineInputBorder(),
              ),
              items: _eventTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _eventType = value);
              },
              validator: (value) =>
                  value == null ? 'Please select event type.' : null,
            ),
            const SizedBox(height: 16),

            // --- Dept, Venue, Year ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Dept is required.' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Venue',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Venue is required.' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: _targetYears
                        .map(
                          (year) =>
                              DropdownMenuItem(value: year, child: Text(year)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _targetYear = value);
                    },
                    validator: (value) =>
                        value == null ? 'Year is required.' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Intra/Inter College (Radio Button) ---
            const Text(
              'Event Reach:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Intra College'),
                    value: 'Intra College',
                    groupValue: _collegeType,
                    onChanged: (value) => setState(() => _collegeType = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Inter College'),
                    value: 'Inter College',
                    groupValue: _collegeType,
                    onChanged: (value) => setState(() => _collegeType = value!),
                  ),
                ),
              ],
            ),

            // --- Event Coordinator (Multi-Member) ---
            _buildCoordinatorFields(
              list: _eventCoordinators,
              label: 'Event Coordinator(s)',
              isStaff: false,
            ),

            // --- Staff Coordinator (Multi-Member) ---
            _buildCoordinatorFields(
              list: _staffCoordinators,
              label: 'Staff Coordinator(s)',
              isStaff: true,
            ),

            // --- HOD Name ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: TextFormField(
                controller: _hodController,
                decoration: const InputDecoration(
                  labelText: 'HOD Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'HOD Name is required.' : null,
              ),
            ),

            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
