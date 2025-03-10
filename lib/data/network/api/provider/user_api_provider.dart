import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/endpoints.dart';
import '../dio_client.dart';

class UserApiProvider {
  final DioClient _dioClient = DioClient();

  Future<Response> addUserDetails(
    String? userId,
    String? userName,
    String? email,
    String? age,
  ) async {
    try {
      final Response response =
          await _dioClient.post(Endpoints.addUserDetails, data: {
        'Id': userId,
        'UserName': userName,
        'Email': email,
        'Age': age,
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUserDetails() async {
    try {
      final Response response = await _dioClient.get(Endpoints.getUserDetails);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  updateUserDetails(
    String userId,
    String? userName,
    bool? pushNotificationEnabled,
    bool? emailNotificationEnabled,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse(Endpoints.baseUrl + Endpoints.updateUserDetails);

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['Id'] = userId;
      if (userName != null) {
        request.fields['UserName'] = userName;
      }

      if (pushNotificationEnabled != null) {
        request.fields['PushNotification'] = pushNotificationEnabled.toString();
      }
      if (emailNotificationEnabled != null) {
        request.fields['EmailNotification'] =
            emailNotificationEnabled.toString();
      }

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> deleteUser(
      String userId, String organizationId, bool isAdmin) async {
    try {
      final Response response = await _dioClient.delete(
          '${Endpoints.deleteUser}?userId=$userId&organizationId=$organizationId&isAdmin=$isAdmin');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getAppConfig() async {
    try {
      final Response response = await _dioClient.get(Endpoints.getAppConfig);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getAllUsers(String searchUser, int limit, int page) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getAllUsers}?limit=$limit&page=$page&keyword=$searchUser');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  updateUserDetail(
      String userId,
      String? firstName,
      String? lastName,
      String? email,
      String? countryCode,
      String? countryISOCode,
      String? phoneNumber,
      File? profilePic) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.updateDbUser}');

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });

      request.fields['Id'] = userId;
      if (firstName != null) {
        request.fields['FirstName'] = firstName;
      }
      if (lastName != null) {
        request.fields['LastName'] = lastName;
      }
      if (phoneNumber != null) {
        request.fields['PhoneNumber'] = phoneNumber;
      }
      if (countryCode != null) {
        request.fields['CountryCode'] = countryCode;
      }
      if (countryISOCode != null) {
        request.fields['countryIsoCode'] = countryISOCode;
      }
      if (profilePic != null) {
        request.files.add(
          http.MultipartFile(
            'File',
            File(profilePic.path).readAsBytes().asStream(),
            File(profilePic.path).lengthSync(),
            filename: profilePic.path.split('/').last,
          ),
        );
      }
      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUserDetail(String userId) async {
    try {
      final Response response =
          await _dioClient.get('${Endpoints.getUserById}?userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUserClockInId(String userId) async {
    try {
      Response response = await _dioClient
          .get('${Endpoints.getUserAttendanceRecordId}?userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
