import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/search_suggestion.dart';
import 'package:tasko/data/model/subtask.dart';
import 'package:tasko/data/model/task_comment.dart';
import 'package:tasko/data/model/task_details.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/task_api_provider.dart';

class TaskRepo {
  final TaskApiProvider _taskApiProvider = TaskApiProvider();

  createTask(
      String taskName,
      String taskDescription,
      String taskEndTime,
      String projectId,
      String taskOwnerId,
      List<SubTasks> subTasks,
      bool proofOfCompletion,
      List<File>? documents,
      String orgId,
      String selectedPriority,
      List<String> repeatSchedule) async {
    try {
      var response = await _taskApiProvider.createTask(
          taskName,
          taskDescription,
          taskEndTime,
          projectId,
          taskOwnerId,
          subTasks,
          proofOfCompletion,
          documents,
          orgId,
          selectedPriority,
          repeatSchedule);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  updateTask(
      String taskId,
      String taskName,
      String taskDescription,
      String taskEndTime,
      String projectId,
      String taskOwnerId,
      List<SubTasks> subTasks,
      List<File>? pocFiles,
      List<int> removedMediaPotisions,
      bool isCompleted,
      bool proofOfCompletion,
      List<File>? documents,
      List<int> removedDocumentPositions,
      List<int> removedSubtaskMediaPositions,
      List<int> removedSubtaskDocumentPositions,
      String orgId,
      String selectedPriority,
      List<String> repeatSchedule) async {
    try {
      var response = await _taskApiProvider.updateTask(
          taskId,
          taskName,
          taskDescription,
          taskEndTime,
          projectId,
          taskOwnerId,
          subTasks,
          pocFiles,
          removedMediaPotisions,
          isCompleted,
          proofOfCompletion,
          documents,
          removedDocumentPositions,
          removedSubtaskMediaPositions,
          removedSubtaskDocumentPositions,
          orgId,
          selectedPriority,
          repeatSchedule);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteTask(String taskId) async {
    try {
      final response = await _taskApiProvider.deleteTask(taskId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<TaskDetails> getTaskById(String taskId) async {
    TaskDetails task;
    try {
      var response = await _taskApiProvider.getTaskById(taskId);
      var res = response.data as Map<String, dynamic>;
      task = TaskDetails.fromMap(res['data']);
      return task;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<ProjectDetails>> getAllTasksByProject(
      String organizationId,
      int page,
      int limit,
      String searchKeyword,
      String filterType,
      String priorityKey) async {
    List<ProjectDetails> projects;
    try {
      var response = await _taskApiProvider.getTaskFilters(
          organizationId, page, limit, searchKeyword, filterType, priorityKey);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      projects = result.map((task) => ProjectDetails.fromMap(task)).toList();
      return projects;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<TaskDetails>> getTasksByProjectAndUser(String userId,
      String projectId, int page, int limit, String searchTask) async {
    List<TaskDetails> tasks;
    try {
      var response = await _taskApiProvider.getTasksByProjectAndUser(
          userId, projectId, page, limit, searchTask);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      tasks = result.map((task) => TaskDetails.fromMap(task)).toList();
      return tasks;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<TaskDetails>> getTasksByProject(
      String projectId, int page, int limit, String searchTask) async {
    List<TaskDetails> tasks;
    try {
      var response = await _taskApiProvider.getTasksByProject(
          projectId, page, limit, searchTask);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      tasks = result.map((task) => TaskDetails.fromMap(task)).toList();
      return tasks;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<TaskComment> addTaskComment(String taskComment, String taskId,
      String organizationId, List<File> filesUrls) async {
    TaskComment postComment;
    try {
      final response = await _taskApiProvider.addTaskComment(
          taskComment, taskId, organizationId, filesUrls);
      var res = json.decode(response.body);
      var result = res['data'];
      postComment = TaskComment.fromMap(result);
      return postComment;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteTaskComment(String taskCommentId) async {
    try {
      final response = await _taskApiProvider.deleteTaskComment(taskCommentId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  updateTaskComment(String taskCommentId, String taskComment, String postId,
      List<File> files, List<int> removedFilePotisions) async {
    try {
      final response = await _taskApiProvider.updateTaskComment(
          taskCommentId, taskComment, postId, files, removedFilePotisions);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<TaskDetails>> getUnassignedTask(
      String orgId, int page, int limit, String searchTask) async {
    List<TaskDetails> tasks;
    try {
      var response = await _taskApiProvider.getUnassignedTask(
          orgId, page, limit, searchTask);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      tasks = result.map((task) => TaskDetails.fromMap(task)).toList();
      return tasks;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> assignTaskToProject(
      String projectId, List<String> selectedTasks) async {
    try {
      final response =
          await _taskApiProvider.assignTaskToProject(projectId, selectedTasks);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<SearchSuggestion>> getSearchSuggestion(String organizationId,
      String searchKeyword, String searchType, String priorityKey) async {
    List<SearchSuggestion> tasks = [];
    try {
      var response = await _taskApiProvider.getSearchSuggestion(
          organizationId, searchKeyword, searchType, priorityKey);
      var result = response.data as List;
      tasks = result.map((task) => SearchSuggestion.fromMap(task)).toList();
      return tasks;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<List<TaskDetails>> getTaskFilters(
      String organizationId,
      int page,
      int limit,
      String searchKeyword,
      String filterType,
      String priorityKey) async {
    List<TaskDetails> tasks = [];
    try {
      var response = await _taskApiProvider.getTaskFilters(
          organizationId, page, limit, searchKeyword, filterType, priorityKey);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      tasks = result.map((task) => TaskDetails.fromMap(task)).toList();
      return tasks;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
