import 'package:dio/dio.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/organization_api_provider.dart';

class OrganizationRepo {
  final OrganizationApiProvider _organizationApiProvider =
      OrganizationApiProvider();

  Future<List<Organization>?> getOrganizationList(String userId) async {
    List<Organization> organizationDetailsData = [];
    try {
      final response =
          await _organizationApiProvider.getOrganizationList(userId);
      var res = response.data as Map<String, dynamic>;
      if (response.data == null || res['data'] == null) {
        return organizationDetailsData;
      } else {
        var result = res['data'] as List;
        organizationDetailsData =
            result.map((organization) => Organization.fromMap(organization)).toList();
        return organizationDetailsData;
      }
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
