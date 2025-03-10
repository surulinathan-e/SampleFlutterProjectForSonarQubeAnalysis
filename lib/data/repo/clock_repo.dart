import 'package:dio/dio.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/user_pending_scheduled_shift.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/clock_api_provider.dart';

class ClockRepo {
  final ClockApiProvider clockApiProvider = ClockApiProvider();

  Future<AttendanceHistroy> userClockIn(
      String userId,
      String shiftId,
      String organizationId,
      String attendanceRecordId,
      String clockOutReason) async {
    try {
      final response = await clockApiProvider.userClockInOrOut(
          userId, shiftId, organizationId, attendanceRecordId, clockOutReason);
      var res = response.data as Map<String, dynamic>;
      var result = AttendanceHistroy.fromMap(res['data']);
      return result;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> userClockOut(
      String userId,
      String shiftId,
      String organizationId,
      String attendanceRecordId,
      String clockOutReason) async {
    try {
      final response = await clockApiProvider.userClockInOrOut(
          userId, shiftId, organizationId, attendanceRecordId, clockOutReason);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<Shift>> getShiftData(String organizationId) async {
    List<Shift> shift;
    try {
      final response = await clockApiProvider.getShiftData(organizationId);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      shift = result.map((shift) => Shift.fromMap(shift)).toList();
      return shift;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<UserPendingScheduledShift>> getUserPendingScheduledShifts(
      String organizationId, String userId) async {
    List<UserPendingScheduledShift> pendingList;
    try {
      final response = await clockApiProvider.getUserPendingScheduledShifts(
          organizationId, userId);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      pendingList = result
          .map(
              (pendingShift) => UserPendingScheduledShift.fromMap(pendingShift))
          .toList();
      return pendingList;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Shift?> getTodayScheduledShift(String organizationId) async {
    Shift? shift;
    try {
      final response =
          await clockApiProvider.getTodayScheduledShift(organizationId);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'];
      if (result != null) {
        shift = Shift.fromMap(result);
      }
      return shift;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
