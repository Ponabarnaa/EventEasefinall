import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'home_screen.dart';
import 'admin_layout_screen.dart'; // <-- NEW: Import for Admin Home Screen

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  // State variables
  bool _isLogin = true; // Toggle between Login and Register
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // NEW: State variable for role selection
  String _selectedRole = 'User'; // Default role

  // Text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Only for register

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // --- Main submission function (UPDATED for Role-Based Navigation) ---
  void _trySubmitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); // Close keyboard

    if (!isValid) {
      return; // Validation failed
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;

      if (_isLogin) {
        // --- LOGIN MODE ---
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // --- REGISTER MODE ---
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // --- Store username (e.g., in Firebase profile) ---
        await userCredential.user?.updateDisplayName(
          _usernameController.text.trim(),
        );
        // NOTE: For a real app, you would also save the _selectedRole to Firestore/Database
        // with the user ID at this point.
      }

      // --- NEW ROLE-BASED NAVIGATION LOGIC ---
      if (mounted) {
        Widget nextScreen;

        // This is where you decide the destination based on the selected role.
        // NOTE: In a production app, you would verify the role from a database
        // after login, not just rely on the user's selected role on the login screen.
        if (_selectedRole == 'Admin') {
          nextScreen = const AdminLayoutScreen();
        } else {
          nextScreen = const HomeScreen();
        }

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => nextScreen));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please check your credentials.';
      if (e.message != null) {
        message = e.message!;
      }

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      // If an error occurs, stop loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      // Stop loading on other errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- BUILD METHOD (UPDATED with Role Dropdown) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Wrap the body content in a Container to apply the background image
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mca_logo.jpg'), // Your image asset path
            fit: BoxFit.cover,
            // Apply a dark filter to ensure all text is readable
            colorFilter: ColorFilter.mode(
              Colors.black54, // 54% opacity black overlay
              BlendMode.darken,
            ),
          ),
        ),
        // 2. The existing content goes here
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Lottie Animation ---
                Lottie.asset(
                  'assets/Login animation.json',
                  height: 100, // Adjust height as needed
                  width: 100,
                ),
                const SizedBox(height: 16),

                // --- App Title (Updated color to white) ---
                Text(
                  _isLogin ? 'Welcome Back to EventEase' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White color for visibility
                  ),
                ),
                const SizedBox(height: 8),

                // --- Subtitle (Updated color to white70) ---
                Text(
                  _isLogin ? 'Log in to continue' : 'Sign up to get started',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ), // Light color for visibility
                ),
                const SizedBox(height: 32),

                // --- Form (Wrapped in a Card for better contrast/design) ---
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Role Dropdown (NEW) ---
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Select Role',
                              prefixIcon: Icon(Icons.security),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'User',
                                child: Text('User'),
                              ),
                              DropdownMenuItem(
                                value: 'Admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a role.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // --- Username Field (Register only) ---
                          if (!_isLogin)
                            TextFormField(
                              key: const ValueKey('username'),
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Username must be at least 4 characters long.';
                                }
                                return null;
                              },
                            ),

                          if (!_isLogin) const SizedBox(height: 16),

                          // --- Email Field ---
                          TextFormField(
                            key: const ValueKey('email'),
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  !value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // --- Password Field ---
                          TextFormField(
                            key: const ValueKey('password'),
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 7) {
                                return 'Password must be at least 7 characters long.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // --- Loading Indicator ---
                          if (_isLoading) const CircularProgressIndicator(),

                          // --- Submit Button ---
                          if (!_isLoading)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _trySubmitForm,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  // Set a nice primary color
                                ),
                                child: Text(
                                  _isLogin ? 'Login' : 'Register',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // --- Toggle Button ---
                          if (!_isLoading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin; // Toggle mode
                                  _formKey.currentState
                                      ?.reset(); // Clear form fields
                                  _selectedRole =
                                      'User'; // Reset role on toggle
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create new account'
                                    : 'I already have an account',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
