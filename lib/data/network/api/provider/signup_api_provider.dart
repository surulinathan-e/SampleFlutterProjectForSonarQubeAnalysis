import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constant/endpoints.dart';
import '../dio_client.dart';

class SignupApiProvider {
  final DioClient _dioClient = DioClient();

  Future<dynamic> signupUser(String userEmail, String userPassword,
      String firstName, String lastName) async {
    try {
      var userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: userEmail, password: userPassword);
      await FirebaseAuth.instance.currentUser!
          .updateDisplayName('$firstName $lastName');
      return userCredential;
    } on FirebaseAuthException catch (_) {
      rethrow;
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
      final Response response =
          await _dioClient.post(Endpoints.createUser, data: {
        'id': userId,
        'firstName': firstName,
        'lastName': lastName,
        "countryCode": countryCode,
        "countryIsoCode": countryIsoCode,
        'email': email,
        'phoneNumber': phoneNumber,
        'selectedOrganization':
            selectedOrganization != null && selectedOrganization.isNotEmpty
                ? selectedOrganization
                : null
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> emailVerify(String userId) async {
    try {
      final Response response =
          await _dioClient.get('${Endpoints.resendEmail}?userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
