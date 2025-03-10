import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/user_detail.dart' as local;
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/view_record_api_provider.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();

class ViewRecordsRepo {
  final ViewRecordApiProvider _apiProvider = ViewRecordApiProvider();

  static Future<local.UserDetail> getUserDetails() async {
    dynamic userDetailsData;
    var fireBaseUser = FirebaseAuth.instance.currentUser;
    await dbRef
        .child('Users')
        .child(fireBaseUser!.uid)
        .once()
        .then((dataSnapshot) async {
      if (dataSnapshot.snapshot.value != null) {
        userDetailsData = dataSnapshot.snapshot.value;
      } else {
        Map<String, dynamic> user = {
          'firstName': fireBaseUser.uid,
          'lastName': fireBaseUser.uid,
          'email': fireBaseUser.uid,
          'uid': fireBaseUser.uid,
          'isActive': true,
          'isDeleted': false,
          'phoneNumber': fireBaseUser.uid,
          'status': false
        };
        await dbRef
            .child('Users')
            .child(fireBaseUser.uid.toString())
            .set(user)
            .then((value) {
          getUserDetails();
          return;
        });
      }
    });

    return local.UserDetail.fromJson(userDetailsData);
  }

  Future<List<AttendanceHistroy>> getOrganizationUsersAttendanceRecord(
      String organizationId, int page, int limit) async {
    List<AttendanceHistroy> attendanceHistory = [];

    try {
      final response =
          await _apiProvider.getOrganizationUsersAttendanceRecord(organizationId,  page,  limit);
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
}
