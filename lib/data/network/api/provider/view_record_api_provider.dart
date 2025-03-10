import 'package:dio/dio.dart';

import '../constant/endpoints.dart';
import '../dio_client.dart';

class ViewRecordApiProvider {
  final DioClient _dioClient = DioClient();

  Future<Response> getOrganizationUsersAttendanceRecord(
      String organizationId, int page, int limit) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getOrganizationAttendanceRecord}?organizationId=$organizationId&page=$page&limit=$limit');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getMyAttendanceRecord(
      String userId, String organizationId, int page, int limit) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getUserAttendanceRecord}?userId=$userId&organizationId=$organizationId&page=$page&limit=$limit');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
