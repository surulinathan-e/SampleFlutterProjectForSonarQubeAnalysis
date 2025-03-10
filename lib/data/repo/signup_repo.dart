import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../network/api/dio_exception.dart';
import '../network/api/firebase_auth_exeption.dart';
import '../network/api/provider/signup_api_provider.dart';

class SignupRepo {
  final SignupApiProvider _signupApiProvider = SignupApiProvider();

  Future<dynamic> signupUser(
      String email, String password, String firstName, String lastName) async {
    try {
      var response = await _signupApiProvider.signupUser(
          email, password, firstName, lastName);
      return response;
    } on FirebaseAuthException catch (error) {
      final errorMessage =
          FirebaseAuthExceptions.fromFirebaseAuthError(error).toString();
      throw errorMessage;
    }
  }

  Future<dynamic> createUserDB(
      String userId,
      String firstName,
      String lastName,
      String email,
      String countryCode,
      String countryIsoCode,
      String phoneNumber,
      String? selectedOrganization) async {
    try {
      var response = await _signupApiProvider.createUserDB(
          userId,
          firstName,
          lastName,
          email,
          countryCode,
          countryIsoCode,
          phoneNumber,
          selectedOrganization);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<dynamic> emailVerify(String userId) async {
    try {
      var response = await _signupApiProvider.emailVerify(userId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
