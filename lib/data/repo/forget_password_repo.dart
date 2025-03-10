import 'package:firebase_auth/firebase_auth.dart';

import '../network/api/firebase_auth_exeption.dart';
import '../network/api/provider/forget_password_provider.dart';

class ForgetPasswordRepo {
  final ForgetPasswordProvider _apiProvider = ForgetPasswordProvider();
  Future<dynamic> getForgetPassword(String userEmail) async {
    try {
      var response = await _apiProvider.forgetPassword(userEmail);
      return response;
    } on FirebaseAuthException catch (error) {
      final errorMessage =
          FirebaseAuthExceptions.fromFirebaseAuthError(error).toString();
      throw errorMessage;
    }
  }
}
