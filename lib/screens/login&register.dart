import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'home_screen.dart'; // <-- ADDED THIS IMPORT

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

  // --- vvv THIS ENTIRE FUNCTION IS UPDATED vvv ---
  // Main submission function
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
        // You would also save this to a 'users' collection in Firestore
      }

      // --- *** NEW NAVIGATION LOGIC *** ---
      // If login/register is successful, navigate to the HomeScreen
      if (mounted) {
        // Check if the widget is still in the widget tree
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
    // We remove setState(false) from 'finally' because if navigation is
    // successful, this widget will be disposed, and calling setState
    // would cause an error.
  }
  // --- ^^^ THIS ENTIRE FUNCTION IS UPDATED ^^^ ---

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Lottie Animation ---
              Lottie.asset(
                'assets/Login animation.json',
                height: 250, // Adjust height as needed
                width: 250,
              ),
              const SizedBox(height: 16),

              // --- App Title ---
              Text(
                _isLogin ? 'Welcome Back to EventEase' : 'Create Account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Log in to continue' : 'Sign up to get started',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // --- Form ---
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Username Field (Register only) ---
                    if (!_isLogin)
                      TextFormField(
                        key: const ValueKey('username'),
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
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
                        // You can add a suffix icon to show/hide password
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
                          child: Text(_isLogin ? 'Login' : 'Register'),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // --- Toggle Button ---
                    if (!_isLoading)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin; // Toggle mode
                            _formKey.currentState?.reset(); // Clear form fields
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
            ],
          ),
        ),
      ),
    );
  }
}
