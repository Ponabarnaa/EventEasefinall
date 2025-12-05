// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login&register.dart'; // <--- RESTORED: Import the Login Screen
// import 'screens/home_screen.dart'; // Comment this out again or delete it

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const EventEaseApp());
}

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a primary color for a clean, academic look
    const Color primaryColor = Colors.indigo;

    return MaterialApp(
      title: 'EventEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ... (Theme configuration remains the same) ...
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // ... (Rest of theme data) ...
      ),
      // CHANGE BACK HERE: Point to the LoginRegisterScreen
      home: const LoginRegisterScreen(),
    );
  }
}
