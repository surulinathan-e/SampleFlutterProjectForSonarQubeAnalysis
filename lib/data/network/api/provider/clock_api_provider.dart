import 'package:dio/dio.dart';
import 'package:tasko/data/network/api/constant/endpoints.dart';
import 'package:tasko/data/network/api/dio_client.dart';

class ClockApiProvider {
  final DioClient _dioClient = DioClient();
  Future<Response> userClockInOrOut(
      String userId,
      String shiftId,
      String organizationId,
      String attendanceRecordId,
      String clockOutReason) async {
    try {
      final Response response;
      if (attendanceRecordId.isEmpty) {
        response = await _dioClient.post(Endpoints.clockInOrOut, data: {
          'userId': userId,
          'organizationId': organizationId,
          'shiftId': shiftId,
          'clockOutReason': clockOutReason
        });
      } else {
        response = await _dioClient.post(Endpoints.clockInOrOut, data: {
          'userId': userId,
          'organizationId': organizationId,
          'shiftId': shiftId,
          'attendanceRecordId': attendanceRecordId,
          'clockOutReason': clockOutReason
        });
      }
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

  Future<Response> getUserPendingScheduledShifts(
      String organizationId, String userId) async {
    try {
      Response response = await _dioClient.get(
          '${Endpoints.getUserPendingScheduledShift}?organizationId=$organizationId&userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getShiftData(String organizationId) async {
    try {
      Response response = await _dioClient.get(
          '${Endpoints.getOrganizationsShifts}?organizationId=$organizationId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

    Future<Response> getTodayScheduledShift(String organizationId) async {
    try {
      Response response = await _dioClient.get(
          '${Endpoints.getTodayScheduledShift}?organizationId=$organizationId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
