import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tasko/data/model/subtask.dart';
import 'package:tasko/data/network/api/constant/endpoints.dart';
import 'package:tasko/data/network/api/dio_client.dart';

class TaskApiProvider {
  final DioClient _dioClient = DioClient();

  createTask(
      String taskName,
      String taskDescription,
      String taskEndTime,
      String? projectId,
      String? taskOwnerId,
      List<SubTasks> subTasks,
      bool proofOfCompletion,
      List<File>? documents,
      String orgId,
      String selectedPriority,
      List<String> repeatSchedule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.createTask}');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['TaskName'] = taskName;
      request.fields['TaskDescription'] = taskDescription;
      request.fields['TaskEndTime'] = taskEndTime;

      if (taskOwnerId != null && taskOwnerId.isNotEmpty) {
        request.fields['TaskOwnerId'] = taskOwnerId;
      }

      if (projectId != null && projectId.isNotEmpty) {
        request.fields['projectId'] = projectId;
      }

      request.fields['OrganizationId'] = orgId;

      request.fields['PriorityLevel'] = selectedPriority;
      request.fields['ProofOfCompletion'] = proofOfCompletion.toString();
      request.fields['RepeatSchedule'] = repeatSchedule.toString();
      if (documents != null) {
        for (var file in documents) {
          request.files.add(http.MultipartFile(
              'Documents',
              File(file.path).readAsBytes().asStream(),
              File(file.path).lengthSync(),
              filename: file.path.split('/').last));
        }
      }
      if (subTasks.isNotEmpty) {
        for (var subtask in subTasks) {
          var index = subTasks.indexOf(subtask);
          request.fields['subTasks[$index].SubTaskId'] =
              subtask.subTaskId ?? '';
          request.fields['subTasks[$index].SubTaskName'] =
              subtask.subTaskName ?? '';
          request.fields['subTasks[$index].SubTaskDescription'] =
              subtask.subTaskDescription ?? '';
          request.fields['subTasks[$index].SubTaskPriorityLevel'] =
              subtask.subTaskPriorityLevel ?? '';
          request.fields['subTasks[$index].SubTaskCreatorId'] =
              subtask.subTaskCreator!.userId ?? '';
          if (subtask.subTaskOwner != null) {
            request.fields['subTasks[$index].SubTaskOwnerId'] =
                subtask.subTaskOwner!.userId ?? '';
          }
          request.fields['subTasks[$index].SubTaskProofOfCompletion'] =
              subtask.subTaskProofOfCompletion.toString();

          for (var file in subtask.subTaskDocuments!) {
            if (file is File) {
              request.files.add(http.MultipartFile(
                  'subTasks[$index].SubTaskDocuments',
                  File(file.path).readAsBytes().asStream(),
                  File(file.path).lengthSync(),
                  filename: file.path.split('/').last));
            }
          }
        }
      }

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      rethrow;
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
      List<int> removedDocumentPotisions,
      List<int> removedSubtaskMediaPositions,
      List<int> removedSubtaskDocumentPositions,
      String orgId,
      String selectedPriority,
      List<String> repeatSchedule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.updateTask}');

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['taskId'] = taskId;
      request.fields['taskName'] = taskName;
      request.fields['taskDescription'] = taskDescription;
      request.fields['taskEndTime'] = taskEndTime;
      request.fields['projectId'] = projectId;
      request.fields['OrganizationId'] = orgId;
      request.fields['PriorityLevel'] = selectedPriority;
      request.fields['taskOwnerId'] = taskOwnerId;
      request.fields['isCompleted'] = isCompleted.toString();
      request.fields['ProofOfCompletion'] = proofOfCompletion.toString();
      request.fields['RepeatSchedule'] = repeatSchedule.toString();
      if (proofOfCompletion != false && pocFiles != null) {
        for (var file in pocFiles) {
          request.files.add(http.MultipartFile(
              'ProofOfCompletionImages',
              File(file.path).readAsBytes().asStream(),
              File(file.path).lengthSync(),
              filename: file.path.split('/').last));
        }
      }
      if (removedMediaPotisions.isNotEmpty) {
        for (var removedMediaPotision in removedMediaPotisions) {
          var index = removedMediaPotisions.indexOf(removedMediaPotision);
          request.fields['RemovedMediaIndex[$index]'] =
              removedMediaPotision.toString();
        }
      }
      if (documents != null) {
        for (var file in documents) {
          request.files.add(http.MultipartFile(
              'Documents',
              File(file.path).readAsBytes().asStream(),
              File(file.path).lengthSync(),
              filename: file.path.split('/').last));
        }
      }
      if (removedDocumentPotisions.isNotEmpty) {
        for (var removedDocumentPosition in removedDocumentPotisions) {
          var index = removedDocumentPotisions.indexOf(removedDocumentPosition);
          request.fields['RemovedDocumentIndex[$index]'] =
              removedDocumentPosition.toString();
        }
      }
      if (subTasks.isNotEmpty) {
        for (var subtask in subTasks) {
          var index = subTasks.indexOf(subtask);
          request.fields['subTasks[$index].SubTaskId'] =
              subtask.subTaskId ?? '';
          request.fields['subTasks[$index].SubTaskName'] =
              subtask.subTaskName ?? '';
          request.fields['subTasks[$index].SubTaskDescription'] =
              subtask.subTaskDescription ?? '';
          request.fields['subTasks[$index].SubTaskPriorityLevel'] =
              subtask.subTaskPriorityLevel ?? '';
          request.fields['subTasks[$index].SubTaskCreatorId'] =
              subtask.subTaskCreator!.userId ?? '';
          if (subtask.subTaskOwner != null) {
            request.fields['subTasks[$index].SubTaskOwnerId'] =
                subtask.subTaskOwner!.userId ?? '';
          }
          request.fields['subTasks[$index].IsCompleted'] =
              subtask.isCompleted.toString();
          request.fields['subTasks[$index].SubTaskProofOfCompletion'] =
              subtask.subTaskProofOfCompletion.toString();
          if (subtask.subTaskProofOfCompletion != false &&
              subtask.subTaskProofOfCompletionImage != null) {
            for (var file in subtask.subTaskProofOfCompletionImage!) {
              if (file is File) {
                request.files.add(http.MultipartFile(
                    'subTasks[$index].SubTaskProofOfCompletionImage',
                    File(file.path).readAsBytes().asStream(),
                    File(file.path).lengthSync(),
                    filename: file.path.split('/').last));
              }
            }
          }

          for (var file in subtask.subTaskDocuments!) {
            if (file is File) {
              request.files.add(http.MultipartFile(
                  'subTasks[$index].SubTaskDocuments',
                  File(file.path).readAsBytes().asStream(),
                  File(file.path).lengthSync(),
                  filename: file.path.split('/').last));
            }
          }

          if (removedSubtaskMediaPositions.isNotEmpty) {
            for (var removedSubtaskMediaPosition
                in removedSubtaskMediaPositions) {
              var removedIndex = removedSubtaskMediaPositions
                  .indexOf(removedSubtaskMediaPosition);
              request.fields[
                      'subTasks[$index].SubTaskRemovedMediaIndex[$removedIndex]'] =
                  removedSubtaskMediaPosition.toString();
            }
          }
          if (removedSubtaskDocumentPositions.isNotEmpty) {
            for (var removedSubtaskDocumentPosition
                in removedSubtaskDocumentPositions) {
              var removedIndex = removedSubtaskDocumentPositions
                  .indexOf(removedSubtaskDocumentPosition);
              request.fields[
                      'subTasks[$index].SubTaskRemovedDocumentIndex[$removedIndex]'] =
                  removedSubtaskDocumentPosition.toString();
            }
          }
        }
      }

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteTask(String taskId) async {
    try {
      final Response response =
          await _dioClient.delete('${Endpoints.deleteTask}?taskId=$taskId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTaskById(String taskId) async {
    try {
      final Response response =
          await _dioClient.get('${Endpoints.getTaskById}?taskId=$taskId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getAllTasksByProject(
      String orgId, int taskPage, int taskLimit, String searchTask) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getAllTasksByProject}?organizationId=$orgId&page=$taskPage&limit=$taskLimit&keyword=$searchTask');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTasksByProjectAndUser(String userId, String projectId,
      int taskPage, int taskLimit, String searchTask) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getTasksByProjectAndUser}?userId=$userId&projectId=$projectId&page=$taskPage&limit=$taskLimit&keyword=$searchTask');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTasksByProject(
      String projectId, int taskPage, int taskLimit, String searchTask) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getTasksByProject}?projectId=$projectId&page=$taskPage&limit=$taskLimit&keyword=$searchTask');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  addTaskComment(String taskComment, String taskId, String organizationId,
      List<File> filesUrls) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');
      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.createTaskComment}');
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['Content'] = taskComment;
      request.fields['TaskId'] = taskId;
      request.fields['OrganizationId'] = organizationId;
      if (filesUrls.isNotEmpty) {
        for (var file in filesUrls) {
          request.files.add(http.MultipartFile(
              'FileUrls',
              File(file.path).readAsBytes().asStream(),
              File(file.path).lengthSync(),
              filename: file.path.split('/').last));
        }
      }
      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteTaskComment(String taskCommentId) async {
    try {
      final Response response = await _dioClient.delete(
          '${Endpoints.deleteTaskComment}?taskCommentId=$taskCommentId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  updateTaskComment(String taskCommentId, String taskComment, String postId,
      List<File> files, List<int> removedFilePotisions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');
      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.updateTaskComment}');
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['TaskCommentId'] = taskCommentId;
      request.fields['TaskId'] = postId;
      request.fields['Content'] = taskComment;
      if (files.isNotEmpty) {
        for (var file in files) {
          request.files.add(http.MultipartFile(
              'Files',
              File(file.path).readAsBytes().asStream(),
              File(file.path).lengthSync(),
              filename: file.path.split('/').last));
        }
      }
      if (removedFilePotisions.isNotEmpty) {
        for (var removedFilePotision in removedFilePotisions) {
          var index = removedFilePotisions.indexOf(removedFilePotision);
          request.fields['RemovedMediaIndex[$index]'] =
              removedFilePotision.toString();
        }
      }
      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUnassignedTask(
      String orgId, int taskPage, int taskLimit, String searchTask) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getUnassignedTask}?organizationId=$orgId&page=$taskPage&limit=$taskLimit&keyword=$searchTask');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> assignTaskToProject(
      String projectId, List<String> selectedTasks) async {
    try {
      final Response response =
          await _dioClient.put(Endpoints.assignTaskToProject, data: {
        'projectId': projectId,
        'taskIds': selectedTasks,
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getSearchSuggestion(String organizationId,
      String searchKeyword, String searchType, String priorityKey) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getSearchSuggestion}?organizationId=$organizationId&keyword=$searchKeyword&searchType=$searchType&priorityKey=$priorityKey');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getTaskFilters(String organizationId, int page, int limit,
      String searchKeyword, String filterType, String priorityKey) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getTaskFilters}?organizationId=$organizationId&page=$page&limit=$limit&keyword=$searchKeyword&filterType=$filterType&priorityKey=$priorityKey');
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
