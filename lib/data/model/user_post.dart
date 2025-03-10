import 'dart:convert';

import 'package:tasko/data/model/like_details.dart';
import 'package:tasko/data/model/post_comment.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/utils/utils.dart';

class Post {
  String? postId;
  String? content;
  String? userName;
  String? userId;
  String? organizationId;
  List<PostComment>? comments;
  String? createdAt;
  List<Like>? likes;
  int? likesCount;
  int? commentsCount;
  List<dynamic>? mediaUrl;
  String? profileUrl;

  Post(
      this.postId,
      this.content,
      this.userName,
      this.userId,
      this.organizationId,
      this.comments,
      this.createdAt,
      this.likes,
      this.likesCount,
      this.commentsCount,
      this.mediaUrl,
      this.profileUrl);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': postId,
      'content': content,
      'userName': userName,
      'userId': userId,
      'organizationId': organizationId,
      'comments': comments,
      'createdAt': createdAt,
      'likes': likes,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'mediaUrl': mediaUrl,
      'profileUrl': profileUrl
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    List<PostComment> postComment = map['comments'] == null
        ? []
        : map['comments']
            .map<PostComment>((comment) => PostComment.fromMap(comment))
            .toList();
    List<Like> postLike =
        map['likes'].map<Like>((like) => Like.fromMap(like)).toList();
    return Post(
      map['id'] == null ? null : map['id'] as String,
      map['content'] == null ? null : map['content'] as String,
      map['userName'] == null ? null : map['userName'] as String,
      map['userId'] == null ? null : map['userId'] as String,
      map['organizationId'] == null ? null : map['organizationId'] as String,
      map['comments'] == null ? null : postComment,
      map['createdAt'] == null ? null : map['createdAt'] as String,
      map['likes'] == null ? null : postLike,
      map['likesCount'] == null ? null : map['likesCount'] as int,
      map['commentsCount'] == null ? null : map['commentsCount'] as int,
      map['mediaUrl'] == null
          ? []
          : json
              .decode(map['mediaUrl']
                  .toString()
                  .replaceAll("'", '"')
                  .replaceAll('JPEG', 'jpg')
                  .replaceAll('WEBP', 'webp'))
              .map((image) => image)
              .toList(),
      map['profileUrl'] == null
          ? null
          : getProfileImagePath(
              map['userId'],
              map['profileUrl']
                  .toString()
                  .replaceAll("'", '"')
                  .replaceAll('JPEG', 'jpg')
                  .replaceAll('WEBP', 'webp')),
    );
  }

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);

  static String getImagePath(postId, imageName) {
    return ImageUrlBuilder.getImage(
        'files/organizations/${UserDetailsDataStore.getSelectedOrganizationId}/posts/$postId/$imageName');
  }

  static String getProfileImagePath(userId, imageName) {
    return ImageUrlBuilder.getImage('files/users/$userId/$imageName');
  }
}
