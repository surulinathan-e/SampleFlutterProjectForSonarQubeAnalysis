import 'dart:convert';

import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/utils/utils.dart';

class PostComment {
  String? commentId;
  String? content;
  String? userName;
  String? postId;
  String? userId;
  String? createdAt;
  List<dynamic>? images;
  String? profileUrl;

  PostComment(this.commentId, this.content, this.userName, this.postId,
      this.userId, this.createdAt, this.images, this.profileUrl);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'commentId': commentId,
      'content': content,
      'userName': userName,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt,
      'postCommentImages': images,
      'profileUrl': profileUrl
    };
  }

  factory PostComment.fromMap(Map<String, dynamic> map) {
    return PostComment(
      map['commentId'] == null ? null : map['commentId'] as String,
      map['content'] == null ? '' : map['content'] as String,
      map['userName'] == null ? null : map['userName'] as String,
      map['postId'] == null ? null : map['postId'] as String,
      map['userId'] == null ? null : map['userId'] as String,
      map['createdAt'] == null ? null : map['createdAt'] as String,
      map['postCommentImages'] == null
          ? []
          : json
              .decode(map['postCommentImages']
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

  factory PostComment.fromJson(String source) =>
      PostComment.fromMap(json.decode(source) as Map<String, dynamic>);

  static String getCommentImagePath(postId, commentId, imageName) {
    return ImageUrlBuilder.getImage(
        'files/organizations/${UserDetailsDataStore.getSelectedOrganizationId}/posts/$postId/postcomments/$commentId/$imageName');
  }

  static String getProfileImagePath(userId, imageName) {
    return ImageUrlBuilder.getImage('files/users/$userId/$imageName');
  }
}
