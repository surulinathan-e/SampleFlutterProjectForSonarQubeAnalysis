import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthExceptions implements Exception {
  late String message;

  FirebaseAuthExceptions.fromFirebaseAuthError(
      FirebaseAuthException firebaseAuthError) {
    switch (firebaseAuthError.code) {
      case 'invalid-email':
        message = 'Invalid email';
        break;
      case 'user-disabled':
        message = 'User disabled';
        break;
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided for that user.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'account-exists-with-different-credential':
        message = 'Account exists with different credential';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password';
        break;
      case 'operation-not-allowed':
        message = 'Operation not allowed';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'ERROR_MISSING_GOOGLE_AUTH_TOKEN':
        message = 'ERROR_MISSING_GOOGLE_AUTH_TOKEN';
        break;
      case 'network-request-failed':
        message = 'No Internet';
        break;
      default:
        message = firebaseAuthError.message ?? 'FirebaseAuthException default';
    }
  }

  @override
  String toString() => message;
}
