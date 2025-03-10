import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordProvider {
  Future<dynamic> forgetPassword(String userEmail) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
      return 'Password reset email sent';
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }
}
