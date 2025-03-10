import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tasko/data/model/like_details.dart';
import 'package:tasko/data/model/post_comment.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/data/network/api/dio_exception.dart';
import 'package:tasko/data/network/api/provider/post_api_provider.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();

class PostRepo {
  final PostApiProvider postApiProvider = PostApiProvider();

  Future<List<Post>> getPostDetails(
      String organizationId, int page, int limit) async {
    List<Post> posts = [];
    try {
      final response =
          await postApiProvider.getPostDetails(organizationId, page, limit);
      var res = response.data as Map<String, dynamic>;
      var result = res['data'] as List;
      posts = result.map((post) => Post.fromMap(post)).toList();
      return posts;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  addPost(String userPost, String userName, String userId,
      String organizationId, List<File> files) async {
    try {
      final response = await postApiProvider.addPost(
          userPost, userName, userId, organizationId, files);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Like> likeUnlikePost(String userId, String postId) async {
    Like like;
    try {
      final response = await postApiProvider.likeUnlikePost(userId, postId);
      var res = response.data as Map<String, dynamic>;
      if (res['data'] == null || res['data'] is List) {
        return like = Like(null, postId, userId, true, null);
      }
      like = Like.fromMap(res['data']);
      return like;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<PostComment> addComment(String userComment, String userName,
      String postId, String userId, String orgId, List<File> files) async {
    PostComment postComment;
    try {
      final response = await postApiProvider.addComment(
          userComment, userName, postId, userId, orgId, files);
      var res = json.decode(response.body);
      var result = res['data'];
      postComment = PostComment.fromMap(result);
      return postComment;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deleteComment(String commentId) async {
    try {
      final response = await postApiProvider.deleteComment(commentId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  updateComment(String commentId, String userComment, String postId,
      List<File> files, List<int> removedFilePotisions) async {
    try {
      final response = await postApiProvider.updateComment(
          commentId, userComment, postId, files, removedFilePotisions);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  Future<Response> deletePost(String postId) async {
    try {
      final response = await postApiProvider.deletePost(postId);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }

  updatePost(String postId, String postContent, List<File>? postFiles,
      List<int> removedPostMediaPotisions) async {
    try {
      var response = await postApiProvider.updatePost(
          postId, postContent, postFiles, removedPostMediaPotisions);
      return response;
    } on DioException catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      throw errorMessage;
    }
  }
}
