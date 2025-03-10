import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/data/network/api/constant/endpoints.dart';
import 'package:tasko/data/network/api/dio_client.dart';

class PostApiProvider {
  final DioClient _dioClient = DioClient();

  Future<Response> getPostDetails(
      String organizationId, int page, int limit) async {
    try {
      final Response response = await _dioClient.get(
          '${Endpoints.getAllOrganizationFeed}?organizationId=$organizationId&page=$page&limit=$limit');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  addPost(String userPost, String userName, String userId,
      String organizationId, List<File> files) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.createPost}');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });

      request.fields['Content'] = userPost;
      request.fields['UserName'] = userName;
      request.fields['UserId'] = userId;
      request.fields['OrganizationId'] = organizationId;
      if (files.isNotEmpty) {
        for (var file in files) {
          request.files.add(http.MultipartFile(
              'Files',
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

  Future<Response> likeUnlikePost(String userId, String postId) async {
    try {
      final Response response =
          await _dioClient.post(Endpoints.likeOrUnlikeFeedPost, data: {
        'userId': userId,
        'postId': postId,
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  addComment(String userComment, String userName, String postId, String userId,
      String organizationId, List<File> files) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');
      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.createPostComment}');
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['Content'] = userComment;
      request.fields['UserName'] = userName;
      request.fields['UserId'] = userId;
      request.fields['OrganizationId'] = organizationId;
      request.fields['PostId'] = postId;
      if (files.isNotEmpty) {
        for (var file in files) {
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

  Future<Response> deleteComment(String commentId) async {
    try {
      final Response response = await _dioClient
          .delete('${Endpoints.deleteComment}?commentId=$commentId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  updateComment(String commentId, String userComment, String postId,
      List<File> files, List<int> removedFilePotisions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');
      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.updateComment}');
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });
      request.fields['CommentId'] = commentId;
      request.fields['PostId'] = postId;
      request.fields['Content'] = userComment;
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

  Future<Response> deletePost(String postId) async {
    try {
      final Response response =
          await _dioClient.delete('${Endpoints.deletePost}?postId=$postId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  updatePost(String postId, String postContent, List<File>? postFiles,
      List<int> removedPostMediaPotisions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');

      var url = Uri.parse('${Endpoints.baseUrl}${Endpoints.updatePost}');

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      });

      request.fields['PostId'] = postId;
      request.fields['Content'] = postContent;
      if (postFiles != null) {
        for (var file in postFiles) {
          request.files.add(http.MultipartFile(
              'Files',
              File(file.path).readAsBytes().asStream(),
              File(file.path).lengthSync(),
              filename: file.path.split('/').last));
        }
      }

      if (removedPostMediaPotisions.isNotEmpty) {
        for (var removedMediaPotision in removedPostMediaPotisions) {
          var index = removedPostMediaPotisions.indexOf(removedMediaPotision);
          request.fields['RemovedMediaIndex[$index]'] =
              removedMediaPotision.toString();
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
}
