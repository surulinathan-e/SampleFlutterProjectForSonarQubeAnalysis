import 'package:dio/dio.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/project_api_provider.dart';

class ProjectRepo {
  final ProjectApiProvider _projectApiProvider = ProjectApiProvider();

  Future<List<ProjectDetails>> getAllProjects(
      String orgId, int page, int limit, String searchProject) async {
    List<ProjectDetails> projects;
    try {
      var response = await _projectApiProvider.getAllProjects(
          orgId, page, limit, searchProject);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      projects =
          result.map((project) => ProjectDetails.fromMap(project)).toList();
      return projects;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> createProject(String orgId, String projectName,
      String projectDescription, List<String> projectMembers) async {
    try {
      var response = await _projectApiProvider.createProject(
          orgId, projectName, projectDescription, projectMembers);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> updateProject(String projectId, String projectName,
      String projectDescription, List<String> projectMembers) async {
    try {
      var response = await _projectApiProvider.updateProject(
          projectId, projectName, projectDescription, projectMembers);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteProject(String projectId) async {
    try {
      final response = await _projectApiProvider.deleteProject(projectId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
