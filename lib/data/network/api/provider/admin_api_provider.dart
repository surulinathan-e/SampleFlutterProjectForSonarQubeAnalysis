import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/data/network/api/constant/endpoints.dart';
import 'package:tasko/data/network/api/dio_client.dart';
import 'package:http/http.dart' as http;

class AdminApiProvider {
  final DioClient _dioClient = DioClient();
  String formatDateTime(DateTime dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").format(dateTime.toUtc());
  }

  Future<Response> getAllOrganization() async {
    try {
      final Response response = await _dioClient
          .get('${Endpoints.getOrganization}/get_organizations');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> addOrganization(
       parentOrganizationId,
      String name,
      String email,
      String address,
      bool geoLocationEnable,
      String latitude,
      String longitude,
      String geoRadius) async {
    try {
      final Response response =
          await _dioClient.post(Endpoints.createOrganization, data: {
        'parentOrganizationId': parentOrganizationId,
        'organizationName': name,
        'email': email,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'radius': geoRadius,
        'geoLocationEnable': geoLocationEnable
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> updateOrganization(
      String id,
      parentOrganizationId,
      String name,
      String email,
      String address,
      bool geoLocationEnable,
      String latitude,
      String longitude,
      String geoRadius,
      bool isParentOrganization) async {
    try {
      final Response response =
          await _dioClient.put(Endpoints.updateOrganization, data: {
        'id': id,
        'parentOrganizationId': parentOrganizationId,
        'name': name,
        'email': email,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'radius': geoRadius,
        'geoLocationEnable': geoLocationEnable,
        'IsParentOrganization': isParentOrganization
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteOrganization(String orgId) async {
    try {
      final Response response = await _dioClient
          .delete('${Endpoints.deleteOrganization}?organizationId=$orgId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUsersByOrganization(
      String orgId, int page, int limit, String searchUSer) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getUserListByOrganizationId}?organizationId=$orgId&page=$page&limit=$limit&keyword=$searchUSer');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUnassignedOrganizationUsers(String orgId) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getUnassignedOrganizationUsers}?organizationId=$orgId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUnassignedUsers(
      String orgId, String searchKey, int page, int limit) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getUnassignedUsers}?organizationId=$orgId&keyword=$searchKey&page=$page&limit=$limit');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getShiftData(
      String organizationId, int page, int limit) async {
    try {
      Response response = await _dioClient.get(
          '${Endpoints.getOrganizationsShifts}?organizationId=$organizationId&page=$page&limit=$limit');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> createShift(
    String organizationId,
    String shiftName,
    String shiftStartDate,
    String shiftEndDate,
    DateTime startTime,
    DateTime endTime,
    bool sunday,
    bool monday,
    bool tuesday,
    bool wednesday,
    bool thursday,
    bool friday,
    bool saturday,
  ) async {
    try {
      final Response response =
          await _dioClient.post(Endpoints.createNewShift, data: {
        'shiftStartTiming': formatDateTime(startTime),
        'shiftEndTiming': formatDateTime(endTime),
        'shiftName': shiftName,
        'organizationId': organizationId,
        'shiftStartDate': shiftStartDate,
        'shiftEndDate': shiftEndDate,
        'sunday': sunday,
        'monday': monday,
        'tuesday': tuesday,
        'wednesday': wednesday,
        'thursday': thursday,
        'friday': friday,
        'saturday': saturday
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> updateShift(
      String shiftId,
      String organizationId,
      String shiftName,
      String shiftStartDate,
      String shiftEndDate,
      DateTime startTime,
      DateTime endTime,
      bool sunday,
      bool monday,
      bool tuesday,
      bool wednesday,
      bool thursday,
      bool friday,
      bool saturday) async {
    try {
      final Response response =
          await _dioClient.put(Endpoints.updateExistingShift, data: {
        'id': shiftId,
        'organizationId': organizationId,
        'shiftName': shiftName,
        'shiftStartDate': shiftStartDate,
        'shiftEndDate': shiftEndDate,
        'shiftStartTiming': formatDateTime(startTime),
        'shiftEndTiming': formatDateTime(endTime),
        'sunday': sunday,
        'monday': monday,
        'tuesday': tuesday,
        'wednesday': wednesday,
        'thursday': thursday,
        'friday': friday,
        'saturday': saturday
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteShift(String shiftId) async {
    try {
      final Response response =
          await _dioClient.delete('${Endpoints.deleteShift}?shiftId=$shiftId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> assignShiftUser(
      String organizationId, List<String> userId, String shiftId) async {
    try {
      final Response response = await _dioClient.post(Endpoints.assignShiftUser,
          data: {
            'organizationId': organizationId,
            'userId': userId,
            'shiftId': shiftId
          });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getScheduledUserShifts(
      String organizationId, String userId) async {
    try {
      Response response = await _dioClient.get(
          '${Endpoints.getUserScheduledShifts}?organizationId=$organizationId&userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> updateScheduledShiftStatus(
      String scheduledShiftId, String status) async {
    try {
      final Response response =
          await _dioClient.put(Endpoints.userShiftScheduledStatusUpdate, data: {
        'userShiftScheduledStatusId': scheduledShiftId,
        'status': status,
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUnassignedShiftUser(
      String organizationId, String shiftId, String searchKey) async {
    try {
      Response response = await _dioClient.get(
          '${Endpoints.getUnassignedShiftUsersByOrganization}?organizationId=$organizationId&shiftId=$shiftId&keyword=$searchKey');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteUser(
      String userId, String organizationId, bool isAdmin) async {
    try {
      final Response response = await _dioClient.delete(
          '${Endpoints.deleteDbUser}?userId=$userId&organizationId=$organizationId&isAdmin=$isAdmin');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> addOrganizationUser(
      String organizationId, List<Map<String, dynamic>> users) async {
    try {
      final Response response = await _dioClient.post(
          Endpoints.addOrganizationUser,
          data: {'organizationId': organizationId, 'users': users});
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> removeOrganizationUser(
      String organizationId, String userId) async {
    try {
      final Response response = await _dioClient.delete(
          '${Endpoints.removeOrganizationUser}?userId=$userId&organizationId=$organizationId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  updateUser(
      String id,
      String firstName,
      String lastName,
      String email,
      String countryCode,
      String countryIsoCode,
      String phoneNumber,
      bool isActive,
      bool isAdmin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.updateDbUser}');

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });

      request.fields['Id'] = id;
      request.fields['FirstName'] = firstName;
      request.fields['LastName'] = lastName;
      request.fields['PhoneNumber'] = phoneNumber;
      request.fields['CountryCode'] = countryCode;
      request.fields['countryIsoCode'] = countryIsoCode;
      request.fields['IsAdmin'] = isAdmin.toString();

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

  acceptAllPendingUserShifts(String userId, String organizationId) async {
    try {
      final Response response = await _dioClient.put(
          '${Endpoints.acceptAllPendingUserShifts}?userId=$userId&organizationId=$organizationId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
