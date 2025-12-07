import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart'; // Import your EventDetails model
import 'success_screen.dart'; // Import the SuccessScreen

class RegistrationScreen extends StatefulWidget {
  final EventDetails event;

  const RegistrationScreen({super.key, required this.event});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Existing Controllers
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _emailController = TextEditingController();

  // New Controllers
  final _collegeController = TextEditingController(); // New
  final _departmentController = TextEditingController(); // New
  final _yearController = TextEditingController(); // New

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _phoneNoController.dispose();
    _emailController.dispose();
    _collegeController.dispose(); // Dispose new controllers
    _departmentController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // Function to simulate saving data to Firestore
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Prepare data for Firestore
        final registrationData = {
          // Assuming EventDetails has an 'id' property. UNCOMMENT and use this line
          // if you fix your EventDetails model.
          // 'eventId': widget.event.id,
          'eventName': widget.event.name,
          'name': _nameController.text.trim(),
          'rollNo': _rollNoController.text.trim(),
          'phoneNo': _phoneNoController.text.trim(),
          'email': _emailController.text.trim(),

          // --- NEW FIELDS ADDED HERE ---
          'collegeName': _collegeController.text.trim(),
          'department': _departmentController.text.trim(),
          'yearOfStudy': _yearController.text.trim(),

          // -----------------------------
          'registrationDate': Timestamp.now(),
        };

        // 2. Save data to a 'registrations' collection in Firestore
        await FirebaseFirestore.instance
            .collection('registrations')
            .add(registrationData);

        // 3. Navigate to the Success Screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(eventName: widget.event.name),
            ),
          );
        }
      } catch (e) {
        // Handle registration error
        print("Registration error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Event registration form (${widget.event.name})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // --- EXISTING FIELDS ---
              _buildInputField("Name:", _nameController, Icons.person),
              _buildInputField("Rollno:", _rollNoController, Icons.badge),
              _buildInputField(
                "Phoneno:",
                _phoneNoController,
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildInputField(
                "Email:",
                _emailController,
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              // --- NEW FIELDS ADDED HERE ---
              _buildInputField(
                "College Name:",
                _collegeController,
                Icons.school,
              ),
              _buildInputField(
                "Department:",
                _departmentController,
                Icons.business,
              ),
              _buildInputField(
                "Year of Study:",
                _yearController,
                Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),

              // -----------------------------
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _registerUser,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.star),
                      label: Text(_isLoading ? "Registering..." : "Register"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7d3c98), // Purple
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate back to the previous screen (HomeScreen)
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF9b59b6,
                        ), // Lighter purple
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
