import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login&register.dart'; // Import the login/register screen
import 'firebase_options.dart'; // Import the generated Firebase options

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase Core
  // Replace 'YourAppName' with the actual name or title for your app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle initialization error (e.g., if options are missing)
    print('Error initializing Firebase: $e');
  }

  // 3. Start the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventEase App',
      // Define a custom theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
            255,
            6,
            126,
            179,
          ), // A nice primary blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Set default text button style for better visibility on dark backgrounds
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // White text for the toggle button
          ),
        ),
      ),
      // Start with the Login/Register screen
      home: const LoginRegisterScreen(),

      // Optional: Define a route for the home screen (less common with pushReplacement)
      // routes: {
      //   '/home': (context) => const HomeScreen(),
      // },
    );
  }
}
