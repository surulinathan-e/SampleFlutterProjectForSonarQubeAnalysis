import 'package:dio/dio.dart';
import 'package:tasko/data/network/api/constant/endpoints.dart';
import 'package:tasko/data/network/api/dio_client.dart';

class ProjectApiProvider {
  final DioClient _dioClient = DioClient();

  Future<Response> getAllProjects(String orgId, int projectPage,
      int projectLimit, String searchProject) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getAllProjects}?organizationId=$orgId&page=$projectPage&limit=$projectLimit&keyword=$searchProject');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> createProject(String orgId, String projectName,
      String projectDescription, List<String> projectMembers) async {
    try {
      var response = await _dioClient.post(Endpoints.createProject, data: {
        'projectName': projectName,
        'organizationId': orgId,
        'projectDescription': projectDescription,
        'projectMembers': projectMembers
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> updateProject(String projectId, String projectName,
      String projectDescription, List<String> projectMembers) async {
    try {
      var response = await _dioClient.put(Endpoints.updateProject, data: {
        'projectId': projectId,
        'projectName': projectName,
        'projectDescription': projectDescription,
        'projectMembers': projectMembers
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteProject(String projectId) async {
    try {
      final Response response = await _dioClient
          .delete('${Endpoints.deleteProject}?projectId=$projectId');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
