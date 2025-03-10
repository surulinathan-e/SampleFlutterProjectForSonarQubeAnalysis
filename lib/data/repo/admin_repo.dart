import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/organization_user.dart';
import 'package:tasko/data/model/scheduled_shift.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/user_detail.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/admin_api_provider.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();

class AdminRepo {
  final AdminApiProvider _adminApiProvider = AdminApiProvider();

  static Future<List<User>> getUsersDetails() async {
    List<User> userList = [];

    await dbRef.child('Users').once().then((dataSnapshot) async {
      Map mapValueData = dataSnapshot.snapshot.value as Map;
      mapValueData.forEach((key, value) {
        userList.add(UserDetail.fromJson(value) as User);
      });
    });

    return userList;
  }

  Future<List<Organization>> getAllOrganization() async {
    List<Organization> organizations;
    try {
      final response = await _adminApiProvider.getAllOrganization();
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      organizations = result
          .map((organization) => Organization.fromMap(organization))
          .toList();
      return organizations;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Organization> addOrganization(
       parentOrganizationId,
      String name,
      String email,
      String address,
      bool geoLocationEnable,
      String latitude,
      String longitude,
      String geoRadius) async {
    Organization organization;
    try {
      final response = await _adminApiProvider.addOrganization(
          parentOrganizationId,
          name,
          email,
          address,
          geoLocationEnable,
          latitude,
          longitude,
          geoRadius);
      var res = response.data as Map<String, dynamic>;
      organization = Organization.fromMap(res['data']);
      return organization;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
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
      final response = await _adminApiProvider.updateOrganization(
          id,
          parentOrganizationId,
          name,
          email,
          address,
          geoLocationEnable,
          latitude,
          longitude,
          geoRadius,
          isParentOrganization);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteOrganization(String orgId) async {
    try {
      final response = await _adminApiProvider.deleteOrganization(orgId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<UserProfile>> getUsersByOrganization(
      String orgId, int page, int limit, String searchUser) async {
    List<UserProfile> users;
    try {
      final response = await _adminApiProvider.getUsersByOrganization(
          orgId, page, limit, searchUser);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      users = result.map((user) => UserProfile.fromMap(user)).toList();
      return users;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<UserProfile>> getUnassignedOrganizationUsers(String orgId) async {
    List<UserProfile> users;
    try {
      final response =
          await _adminApiProvider.getUnassignedOrganizationUsers(orgId);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      users = result.map((user) => UserProfile.fromMap(user)).toList();
      return users;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<UserProfile>> getUnassignedUsers(
      String orgId, String searchKey, int page, int limit) async {
    List<UserProfile> users;
    try {
      final response = await _adminApiProvider.getUnassignedUsers(
          orgId, searchKey, page, limit);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      users = result.map((user) => UserProfile.fromMap(user)).toList();
      return users;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<Shift>> getOrganizationShifts(
      String organizationId, int page, int limit) async {
    List<Shift> shifts;
    try {
      final response =
          await _adminApiProvider.getShiftData(organizationId, page, limit);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      shifts = result.map((shift) => Shift.fromMap(shift)).toList();
      return shifts;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
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
      bool saturday) async {
    try {
      final response = await _adminApiProvider.createShift(
          organizationId,
          shiftName,
          shiftStartDate,
          shiftEndDate,
          startTime,
          endTime,
          sunday,
          monday,
          tuesday,
          wednesday,
          thursday,
          friday,
          saturday);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
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
      final response = await _adminApiProvider.updateShift(
          shiftId,
          organizationId,
          shiftName,
          shiftStartDate,
          shiftEndDate,
          startTime,
          endTime,
          sunday,
          monday,
          tuesday,
          wednesday,
          thursday,
          friday,
          saturday);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteShift(String shiftId) async {
    try {
      final response = await _adminApiProvider.deleteShift(shiftId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> assignShiftUser(
      String organizationId, List<String> userId, String shiftId) async {
    try {
      final response = await _adminApiProvider.assignShiftUser(
          organizationId, userId, shiftId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<ScheduledShift>> getScheduledUserShifts(
      String organizationId, String userId) async {
    List<ScheduledShift> scheduledShifts;
    try {
      final response = await _adminApiProvider.getScheduledUserShifts(
          organizationId, userId);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      scheduledShifts = result
          .map((scheduledShift) => ScheduledShift.fromMap(scheduledShift))
          .toList();
      return scheduledShifts;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> shiftAcceptOrReject(
      String scheduledShiftId, String status) async {
    try {
      final response = await _adminApiProvider.updateScheduledShiftStatus(
          scheduledShiftId, status);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<OrganizationUser>> getUnassignedShiftUser(
      String organizationId, String shiftId, String searchKey) async {
    List<OrganizationUser> unAssignedUserList;
    try {
      final response = await _adminApiProvider.getUnassignedShiftUser(
          organizationId, shiftId, searchKey);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      unAssignedUserList =
          result.map((user) => OrganizationUser.fromMap(user)).toList();
      return unAssignedUserList;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteUser(
      String userId, String organizationId, bool isAdmin) async {
    try {
      final response =
          await _adminApiProvider.deleteUser(userId, organizationId, isAdmin);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> addOrganizationUser(
      String organizationId, List<Map<String, dynamic>> users) async {
    try {
      final response =
          await _adminApiProvider.addOrganizationUser(organizationId, users);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> removeOrganizationUser(
      String organizationId, String userId) async {
    try {
      final response = await _adminApiProvider.removeOrganizationUser(
          organizationId, userId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
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
      final response = await _adminApiProvider.updateUser(
          id,
          firstName,
          lastName,
          email,
          countryCode,
          countryIsoCode,
          phoneNumber,
          isActive,
          isAdmin);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  acceptAllPendingUserShifts(String userId, String organizationId) async {
    try {
      final response = await _adminApiProvider.acceptAllPendingUserShifts(
          userId, organizationId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
