import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/token_access.dart';
import '../network/api/dio_exception.dart';
import '../network/api/firebase_auth_exeption.dart';
import '../network/api/provider/login_api_provider.dart';

class LoginRepo {
  final LoginApiProvider _loginApiProvider = LoginApiProvider();

  Future<dynamic> loginUser(String email, String password) async {
    try {
      var response = await _loginApiProvider.loginUser(email, password);
      return response;
    } on FirebaseAuthException catch (error) {
      final errorMessage =
          FirebaseAuthExceptions.fromFirebaseAuthError(error).toString();
      throw errorMessage;
    }
  }

  Future<TokenAccess> getAccessToken(
      String userId, String fcmToken, String platform) async {
    TokenAccess userToken;
    try {
      final response =
          await _loginApiProvider.getAccessToken(userId, fcmToken, platform);
      var res = response.data as Map<String, dynamic>;
      userToken = TokenAccess.fromMap(res);
      return userToken;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<TokenAccess> getRefreshToken(
      String userId, String refreshToken) async {
    TokenAccess userToken;
    try {
      final response =
          await _loginApiProvider.getRefreshToken(userId, refreshToken);
      var res = response.data as Map<String, dynamic>;
      userToken = TokenAccess.fromMap(res);
      return userToken;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> validateOTP(String userId, String otp) async {
    try {
      final response = await _loginApiProvider.validateOTP(userId, otp);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> resendOTP(String userId) async {
    try {
      var response = await _loginApiProvider.resendOTP(userId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
