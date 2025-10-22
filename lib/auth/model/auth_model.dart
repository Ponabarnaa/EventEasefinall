import 'package:firebase_auth/firebase_auth.dart';

/// A model to represent the result of an authentication operation.
class AuthResult {
  final User? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});

  /// Returns true if the authentication was successful (user is not null).
  bool get isSuccess => user != null;
}
