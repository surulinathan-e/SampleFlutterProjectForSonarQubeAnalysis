import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constant/endpoints.dart';
import '../dio_client.dart';

class LoginApiProvider {
  final DioClient _dioClient = DioClient();

  Future<dynamic> loginUser(String userEmail, String userPassword) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      return userCredential;
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Future<Response> getAccessToken(
      String userId, String fcmToken, String platform) async {
    try {
      final Response response = await _dioClient.post(Endpoints.getToken,
          data: {'userId': userId, 'fcmToken': fcmToken, 'platform': platform});
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getRefreshToken(String userId, String refreshToken) async {
    try {
      final Response response = await _dioClient.post(Endpoints.getRefreshToken,
          data: {'userId': userId, 'refreshToken': refreshToken});
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> validateOTP(String userId, String otp) async {
    try {
      final Response response = await _dioClient
          .get('${Endpoints.validateOTP}?userId=$userId&otp=$otp');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> resendOTP(String userId) async {
    try {
      final Response response =
          await _dioClient.get('${Endpoints.resendOTP}?userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
