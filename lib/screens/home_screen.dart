// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import your other screens
import '../models/event.dart'; // This now imports the file you just fixed
import 'registration_form_screen.dart';
import 'login&register.dart';

// --- Main User Screen (Manages Tabs) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _currentFilter = 'All';

  static const List<Widget> _userPages = <Widget>[
    UserEventListPage(),
    UserEventRequestScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  AppBar _buildAppBar() {
    if (_selectedIndex == 0) {
      // AppBar for "Home" (Event List)
      return AppBar(
        title: const Text('Event Hub'),
        backgroundColor: Colors.red.shade900,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _currentFilter = result;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Filter set to: $_currentFilter')),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'All', child: Text('All')),
              const PopupMenuItem<String>(
                value: 'Upcoming',
                child: Text('Upcoming'),
              ),
              const PopupMenuItem<String>(
                value: 'Ongoing',
                child: Text('Ongoing'),
              ),
              const PopupMenuItem<String>(
                value: 'Completed',
                child: Text('Completed'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    _currentFilter,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Icon(Icons.filter_list, color: Colors.white),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      );
    } else {
      // AppBar for "Messages" (Event Request)
      return AppBar(
        title: const Text('My Event Requests'),
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(child: _userPages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Messages',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red.shade900,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- PAGE 1: The "Event List" Screen (Shows APPROVED events) ---
class UserEventListPage extends StatelessWidget {
  const UserEventListPage({super.key});

  String _getImageForType(String eventType) {
    if (eventType == 'Technical') {
      return "https://oaidalleapiprodscus.blob.core.windows.net/private/org-r34q5G5eU5zI42g12XN87L38/user-Q8m044m21wQ45p3YwP1x1yTq/img-7D9U9N4k6R9xV1wW8P3m3V46.png?st=2024-05-30T10%3A50%3A58Z&se=2024-05-30T12%3A50%3A58Z&sp=r&sv=2023-11-03&sr=b&rn=aes-256&ct=application%2Foctet-stream&rscd=attachment%3B%20filename%3Dflutter_workshop_image.png&sig=e9Y9H7D7L7X7Z7W7V7U7T7S7R7Q7P7O7N7M7K7J7I7H7G7F7E7D7C7B7A%3D";
    } else {
      return "https://oaidalleapiprodscus.blob.core.windows.net/private/org-r34q5G5eU5zI42g12XN87L38/user-Q8m044m21wQ45p3YwP1x1yTq/img-C9Q7H52bQ5XyK9zJv4P6N404.png?st=2024-05-30T10%3A50%3A58Z&se=2024-05-30T12%3A50%3A58Z&sp=r&sv=2023-11-03&sr=b&rn=aes-256&ct=application%2Foctet-stream&rscd=attachment%3B%2Tfilename%3Dethical_hacking_workshop_image.png&sig=4rNn9V3k%2FhXFhE4z7F%2Fj0z%2Fn4w%2BdK9oQ7N1g8R7R6M%3D";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pendingEvents')
          .where('status', isEqualTo: 'approved')
          .orderBy('requestedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No approved events found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Check back later!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final eventDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: eventDocs.length,
          itemBuilder: (context, index) {
            final doc = eventDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            // --- THIS IS LINE 214 ---
            // This now works because your model is updated
            final event = EventDetails(
              name: data['name'] ?? 'No Name',
              date: data['date'] ?? 'No Date',
              location: data['location'] ?? 'No Location',
              type: data['eventType'] ?? 'General',
              description: data['description'] ?? 'No Description',
              imageUrl: _getImageForType(data['eventType'] ?? ''),
              coordinatorName: data['studentCoordinator'],
              coordinatorPhone: data['coordinatorPhone'],
              time: data['time'],
            );

            return UserEventCard(event: event);
          },
        );
      },
    );
  }
}

// --- Card for the User Event List (Shows approved events) ---
class UserEventCard extends StatelessWidget {
  final EventDetails event;
  const UserEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationFormScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              event.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.location,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(event.date, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- THIS IS LINE 301 ---
                  // This now works because your model is updated
                  if (event.time != null && event.time!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Add padding
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.time!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                  // --- THIS IS LINE 311 ---
                  // This now works because your model is updated
                  if (event.coordinatorName != null &&
                      event.coordinatorName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0), // Add padding
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.coordinatorName!,
                            style: const TextStyle(fontSize: 15),
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

// --- PAGE 2: The "Event Request" Screen (Form + Status) ---
class UserEventRequestScreen extends StatefulWidget {
  const UserEventRequestScreen({super.key});

  @override
  State<UserEventRequestScreen> createState() => _UserEventRequestScreenState();
}

class _UserEventRequestScreenState extends State<UserEventRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _deptController = TextEditingController();
  final _studentCoordController = TextEditingController();
  final _staffCoordController = TextEditingController();
  final _hodController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hodPhoneController = TextEditingController();

  String? _selectedEventType;
  String? _selectedCollegeReach;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _deptController.dispose();
    _studentCoordController.dispose();
    _staffCoordController.dispose();
    _hodController.dispose();
    _phoneController.dispose();
    _hodPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedEventType == null || _selectedCollegeReach == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all dropdown fields.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not logged in.');
        }

        final eventData = {
          'name': _nameController.text,
          'location': _locationController.text,
          'date': _dateController.text,
          'time': _timeController.text,
          'description': _descriptionController.text,
          'eventType': _selectedEventType,
          'department': _deptController.text,
          'studentCoordinator': _studentCoordController.text,
          'staffCoordinator': _staffCoordController.text,
          'hodName': _hodController.text,
          'coordinatorPhone': _phoneController.text,
          'hodPhone': _hodPhoneController.text,
          'collegeReach': _selectedCollegeReach,
          'status': 'pending',
          'requestedByUid': user.uid,
          'requestedByEmail': user.email,
          'requestedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('pendingEvents')
            .add(eventData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request submitted for approval!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _formKey.currentState!.reset();
        _nameController.clear();
        _locationController.clear();
        _dateController.clear();
        _timeController.clear();
        _descriptionController.clear();
        _deptController.clear();
        _studentCoordController.clear();
        _staffCoordController.clear();
        _hodController.clear();
        _phoneController.clear();
        _hodPhoneController.clear();
        setState(() {
          _selectedEventType = null;
          _selectedCollegeReach = null;
        });
      } catch (e) {
        if (mounted) {
          // --- THIS IS THE TYPO I FIXED ---
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit request: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMyRequestsList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in to see your requests.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pendingEvents')
          .where('requestedByUid', isEqualTo: currentUser.uid)
          .orderBy('requestedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('You have not submitted any event requests yet.'),
            ),
          );
        }

        final requestDocs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requestDocs.length,
          itemBuilder: (context, index) {
            final doc = requestDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final reason = data['rejectionReason'];

            return _buildStatusCard(data['name'], status, reason);
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      },
    );
  }

  Widget _buildStatusCard(String eventName, String status, String? reason) {
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Approved';
        break;
      case 'declined':
        icon = Icons.cancel;
        color = Colors.red;
        statusText = 'Declined';
        break;
      default:
        icon = Icons.hourglass_top;
        color = Colors.orange;
        statusText = 'Pending';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          eventName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: status == 'declined'
            ? Text(
                'Reason: ${reason ?? "No reason provided."}',
                style: TextStyle(color: Colors.red[700]),
              )
            : null,
        trailing: Chip(
          label: Text(statusText),
          backgroundColor: color.withOpacity(0.1),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'My Request Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMyRequestsList(),

            const Divider(height: 40, thickness: 1),

            const Text(
              'Request a New Event',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextFormField(
                    controller: _nameController,
                    label: 'Event Name',
                    icon: Icons.event,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedEventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    hint: const Text('Select Event Type'),
                    items: ['Technical', 'Non-Technical']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventType = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select an event type' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCollegeReach,
                    decoration: const InputDecoration(
                      labelText: 'College Reach',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
                    ),
                    hint: const Text('Select College Reach'),
                    items: ['Intra-College', 'Inter-College']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCollegeReach = value;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Please select the college reach'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _deptController,
                    label: 'Department',
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _dateController,
                    label: 'Date',
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _timeController,
                    label: 'Time',
                    icon: Icons.access_time,
                    readOnly: true,
                    onTap: _selectTime,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _descriptionController,
                    label: 'Event Description',
                    icon: Icons.description,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _studentCoordController,
                    label: 'Student Coordinator Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _phoneController,
                    label: 'Student Coordinator Phone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _staffCoordController,
                    label: 'Staff Coordinator Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _hodController,
                    label: 'HOD Name',
                    icon: Icons.person_pin,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _hodPhoneController,
                    label: 'HOD Phone Number',
                    icon: Icons.phone_callback,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('Request', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $label';
        }

        if (keyboardType == TextInputType.phone &&
            (value.length < 10 || value.length > 13)) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }
}
