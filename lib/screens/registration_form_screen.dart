// lib/screens/registration_form_screen.dart
import 'package:flutter/material.dart';
// ✅ FIX 1: Import the correct model class
import '../models/event.dart';

class RegistrationFormScreen extends StatefulWidget {
  // ✅ FIX 2: Corrected type from 'Event' to 'EventDetails'
  final EventDetails event;

  // 🛑 FIX: Corrected constructor name to match class name
  const RegistrationFormScreen({super.key, required this.event});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

// 🛑 FIX: Corrected State class name to match the corrected Widget class name
class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would save this data to Firestore or a backend API.
      // For now, we'll just show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Uses event.name, which is correct on the EventDetails model
          content: Text('Successfully registered for ${widget.event.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to event detail
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Uses event.name, which is correct on the EventDetails model
        title: Text('Register for ${widget.event.name}'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registration Details',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Event: ${widget.event.name}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email Address
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // MCA Roll Number
              TextFormField(
                controller: _rollNumberController,
                decoration: const InputDecoration(
                  labelText: 'MCA Roll Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your MCA Roll Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitRegistration,
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Confirm Registration',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      elevation: 4,
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