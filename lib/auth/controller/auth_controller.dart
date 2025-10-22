import 'package:firebase_auth/firebase_auth.dart';
import '../model/auth_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs up a new user with email and password.
  Future<AuthResult> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return AuthResult(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message
      return AuthResult(errorMessage: _getErrorMessage(e));
    } catch (e) {
      return AuthResult(errorMessage: 'An unknown error occurred.');
    }
  }

  /// Logs in an existing user with email and password.
  Future<AuthResult> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message
      return AuthResult(errorMessage: _getErrorMessage(e));
    } catch (e) {
      return AuthResult(errorMessage: 'An unknown error occurred.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// A helper method to convert Firebase error codes into user-friendly messages.
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
