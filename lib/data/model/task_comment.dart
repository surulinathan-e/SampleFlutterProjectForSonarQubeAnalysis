import 'dart:convert';

import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/utils/utils.dart';

class TaskComment {
  String? commentId;
  String? content;
  String? userName;
  String? taskId;
  String? userId;
  String? createdAt;
  List<dynamic>? taskCommentImages;

  TaskComment(this.commentId, this.content, this.userName, this.taskId,
      this.userId, this.createdAt, this.taskCommentImages);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskCommentId': commentId,
      'content': content,
      'userName': userName,
      'taskId': taskId,
      'userId': userId,
      'createdAt': createdAt,
      'taskCommentImages': taskCommentImages,
    };
  }

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      map['taskCommentId'] == null ? null : map['taskCommentId'] as String,
      map['content'] == null ? '' : map['content'] as String,
      map['userName'] == null ? null : map['userName'] as String,
      map['taskId'] == null ? null : map['taskId'] as String,
      map['userId'] == null ? null : map['userId'] as String,
      map['createdAt'] == null ? null : map['createdAt'] as String,
      map['taskCommentImages'] == null
          ? []
          : json
              .decode(map['taskCommentImages']
                  .toString()
                  .replaceAll("'", '"')
                  .replaceAll('JPEG', 'jpg')
                  .replaceAll('WEBP', 'webp'))
              .map((image) => image)
              .toList(),
    );
  }

  factory TaskComment.fromJson(String source) =>
      TaskComment.fromMap(json.decode(source) as Map<String, dynamic>);

  static String getCommentImagePath(taskId, commentId, imageName) {
    return ImageUrlBuilder.getImage(
        'files/organizations/${UserDetailsDataStore.getSelectedOrganizationId}/tasks/$taskId/taskcomments/$commentId/$imageName');
  }
}
