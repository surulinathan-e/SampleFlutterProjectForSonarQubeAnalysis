import 'dart:convert';

class Like {
  String? id;
  String? postId;
  String? userId;
  bool? isDeleted;
  String? createdAt;

  Like(this.id, this.postId, this.userId, this.isDeleted, this.createdAt);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'likeId': id,
      'postId': postId,
      'userId': userId,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
        map['likeId'] == null ? null : map['likeId'] as String,
        map['postId'] == null ? null : map['postId'] as String,
        map['userId'] == null ? null : map['userId'] as String,
        map['isDeleted'] == null ? null : map['isDeleted'] as bool,
        map['createdAt'] == null ? null : map['createdAt'] as String);
  }

  factory Like.fromJson(String source) =>
      Like.fromMap(json.decode(source) as Map<String, dynamic>);
}
