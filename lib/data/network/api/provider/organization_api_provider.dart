import 'package:dio/dio.dart';
import 'package:tasko/data/network/api/constant/endpoints.dart';
import 'package:tasko/data/network/api/dio_client.dart';

class OrganizationApiProvider {
  final DioClient _dioClient = DioClient();
  Future<Response> getOrganizationList(String userId) async {
    try {
      final Response response;
      response = await _dioClient
          .get('${Endpoints.getAssignedOrganizations}?userId=$userId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
