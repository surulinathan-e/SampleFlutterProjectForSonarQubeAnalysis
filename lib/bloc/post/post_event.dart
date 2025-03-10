part of 'post_bloc.dart';

abstract class PostEvent {}

class AddPost extends PostEvent {
  String content;
  String userName;
  String userId;
  String organizationId;
  List<File> files;
  AddPost(this.content, this.userName, this.userId, this.organizationId,
      this.files);
}

class GetPost extends PostEvent {
  String orgId;
  int page;
  int limit;
  GetPost(this.orgId, this.page, this.limit);
}

class LikeUnlikePost extends PostEvent {
  String userId;
  String postId;
  LikeUnlikePost(this.userId, this.postId);
}

class AddComment extends PostEvent {
  String content;
  String userName;
  String postId;
  String userId;
  String organizationId;
  List<File> files;
  AddComment(this.content, this.userName, this.postId, this.userId,
      this.organizationId, this.files);
}

class UpdateComment extends PostEvent {
  String commentId;
  String userComment;
  String postId;
  List<File> files;
  List<int> removedFilePotisions;
  UpdateComment(this.commentId, this.userComment, this.postId, this.files,
      this.removedFilePotisions);
}

class GetComments extends PostEvent {
  String orgId;
  String postId;
  GetComments(this.orgId, this.postId);
}

class DeleteComment extends PostEvent {
  String commentId;
  DeleteComment(this.commentId);
}

class DeletePost extends PostEvent {
  String postId;
  DeletePost(this.postId);
}

class UpdatePost extends PostEvent {
  String postId;
  String postContent;
  List<File>? postFiles;
  List<int> removedPostMediaPotisions;
  UpdatePost(this.postId, this.postContent, this.postFiles,
      this.removedPostMediaPotisions);
}
