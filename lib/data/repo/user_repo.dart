import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tasko/data/model/app_config.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/user_detail.dart' as local;
import 'package:tasko/data/model/user_detail.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/user_api_provider.dart';
import 'package:tasko/data/network/api/provider/view_record_api_provider.dart';
import 'package:tasko/utils/utils.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();

class UserRepo {
  final UserApiProvider _userApiProvider = UserApiProvider();
  final ViewRecordApiProvider _viewRecordApiProvider = ViewRecordApiProvider();

  Future<local.UserDetail> addUserDetails(
      String? userId, String? userName, String? email, String? age) async {
    local.UserDetail userDetail;
    try {
      var response =
          await _userApiProvider.addUserDetails(userId, userName, email, age);
      var res = response.data as Map<String, dynamic>;
      userDetail = local.UserDetail.fromMap(res['data']);
      return userDetail;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  updateUserDetails(
    String userId,
    String? userName,
    bool? pushNotificationEnabled,
    bool? emailNotificationEnabled,
  ) async {
    try {
      var response = await _userApiProvider.updateUserDetails(
          userId, userName, pushNotificationEnabled, emailNotificationEnabled);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  static Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final credentials = EmailAuthProvider.credential(
          email: FirebaseAuth.instance.currentUser!.email!,
          password: currentPassword);

      UserCredential? result = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credentials);

      await result.user!.updatePassword(newPassword);

      return true;
    } on Exception catch (_, e) {
      Logger.printLog(e.toString());
      return false;
    }
  }

  Future<dynamic> deleteUser(String password) async {
    try {
      AuthCredential credentials = EmailAuthProvider.credential(
          email: FirebaseAuth.instance.currentUser!.email!, password: password);

      UserCredential? result = await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credentials);

      await _userApiProvider.deleteUser(FirebaseAuth.instance.currentUser!.uid,
          UserDetailsDataStore.getSelectedOrganizationId!, false);
      await result?.user!.delete();
      return true;
    } on Exception catch (_, e) {
      Logger.printLog(e.toString());
      return false;
    }
  }

  Future<AppConfig> getAppConfig() async {
    AppConfig appConfig;
    try {
      var response = await _userApiProvider.getAppConfig();
      var res = response.data as Map<String, dynamic>;
      appConfig = AppConfig.fromMap(res['data']);
      return appConfig;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<local.UserDetail>> getAllUsers(
      String searchUser, int limit, int page) async {
    List<local.UserDetail> users;
    try {
      var response =
          await _userApiProvider.getAllUsers(searchUser, limit, page);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      users = result.map((user) => local.UserDetail.fromMap(user)).toList();
      return users;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<local.UserDetail> getUserDetails() async {
    dynamic userDetailsData;

    await dbRef
        .child('Users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((dataSnapshot) async {
      if (dataSnapshot.snapshot.value != null) {
        userDetailsData = dataSnapshot.snapshot.value;
      } else {
        Logger.printLog('User data not found');
      }
    });

    return local.UserDetail.fromJson(userDetailsData);
  }

  Future<List<AttendanceHistroy>> getMyAttendanceHistory(
      String userId, String organizationId, int page, int limit) async {
    List<AttendanceHistroy> attendanceHistory = [];

    try {
      final response = await _viewRecordApiProvider.getMyAttendanceRecord(
          userId, organizationId, page, limit);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      attendanceHistory = result
          .map((attendance) => AttendanceHistroy.fromMap(attendance))
          .toList();
      return attendanceHistory;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  static Future<bool> updateProfile(
      {@required String? firstName,
      @required String? lastName,
      @required String? email,
      @required String? countryISOCode,
      @required String? countryCode,
      @required String? phoneNumber,
      @required bool? status,
      @required bool? isAdmin,
      @required String? uid,
      @required organizations,
      @required bool? isActive,
      @required bool? isDeleted}) async {
    bool? authFlag;
    authFlag = true;
    Map<String, dynamic> user = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'countryISOCode': countryISOCode,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'status': status,
      'isAdmin': isAdmin,
    };
    await dbRef
        .child('Users')
        .child(FirebaseAuth.instance.currentUser!.uid.toString())
        .update(user);
    return authFlag;
  }

  Future<UserProfile> getUserDetail(String userId) async {
    UserProfile userData;
    try {
      final response = await _userApiProvider.getUserDetail(userId);
      var res = response.data as Map<String, dynamic>;
      userData = UserProfile.fromMap(res['data']);
      return userData;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<UserDetail> updateUserDetail(
      String userId,
      String firstName,
      String lastName,
      String email,
      String countryCode,
      String countryISOCode,
      String phoneNumber,
      File? profilePic) async {
    UserDetail user;
    try {
      final response = await _userApiProvider.updateUserDetail(
          userId,
          firstName,
          lastName,
          email,
          countryCode,
          countryISOCode,
          phoneNumber,
          profilePic);
      var res = json.decode(response.body);
      var result = res['data'];
      user = UserDetail.fromMap(result);
      return user;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<AttendanceHistroy> getUserClockInId(String userId) async {
    AttendanceHistroy record;
    try {
      final response = await _userApiProvider.getUserClockInId(userId);
      var res = response.data as Map<String, dynamic>;
      record = AttendanceHistroy.fromMap(res['data']);
      return record;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
