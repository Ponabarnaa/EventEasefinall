import 'package:flutter/material.dart';
import '../models/event.dart';

class RegistrationScreen extends StatelessWidget {
  final EventDetails event;
  
  const RegistrationScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        // FIX: Display the actual event name in the title bar
        title: Text('Register for ${event.name}'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Slightly larger padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.app_registration, size: 48, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                // 🛑 FIX: Changed 'event.title' to the correct 'event.name'
                'Registering for: ${event.name}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Location: ${event.location} | Date: ${event.date}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Placeholder for the full registration form (which should be here)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Form Fields Go Here',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      // Replace this placeholder Text with your actual TextFormField widgets
                      const Text(
                        'A TextFormField for Name, Email, and Roll Number would be inserted here, using a Form widget.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () {
                  // In a real app, this would trigger form validation and submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Simulated registration submission for ${event.name} in progress...'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  // Navigator.pop(context); // Optional: go back after submission
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Simulate Registration'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}