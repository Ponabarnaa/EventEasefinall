import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../model/auth_model.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  // Controller instance
  final AuthController _controller = AuthController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Local UI state
  bool _isLoginMode = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Toggles between Login and Sign Up modes
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null; // Clear error on mode switch
      _formKey.currentState?.reset();
    });
  }

  /// Handles the form submission
  Future<void> _submit() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator and clear old errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get email and password from controllers
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Call the appropriate controller method
    AuthResult result;
    if (_isLoginMode) {
      result = await _controller.login(email, password);
    } else {
      result = await _controller.signUp(email, password);
    }

    // Update UI based on the result
    setState(() {
      _isLoading = false;
      if (!result.isSuccess) {
        // Show error message if authentication failed
        _errorMessage = result.errorMessage;
      }
      // If success, the AuthGate in main.dart will automatically
      // navigate to the HomePage. No navigation logic needed here.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We don't use an AppBar here for a more minimal, modern login look
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Professional Logo/Icon
                Icon(
                  Icons.event_available,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _isLoginMode ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isLoginMode
                      ? 'Log in to manage your events'
                      : 'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error Message Display
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Submit Button or Loading Indicator
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                      ),
                const SizedBox(height: 16),

                // Toggle Mode Button
                TextButton(
                  onPressed: _isLoading ? null : _toggleMode,
                  child: Text(
                    _isLoginMode
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Login',
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
