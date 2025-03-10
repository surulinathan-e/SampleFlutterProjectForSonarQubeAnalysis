part of 'post_bloc.dart';

abstract class PostState {}

class PostInit extends PostState {
  PostInit();
}

class AddPostLoading extends PostState {}

class AddPostSuccess extends PostState {}

class AddPostFailed extends PostState {
  String errorMessage;
  AddPostFailed(this.errorMessage);
}

class GetPostLoading extends PostState {}

class GetPostSuccess extends PostState {
  List<Post> posts;
  GetPostSuccess(this.posts);
}

class GetPostFailed extends PostState {
  String errorMessage;
  GetPostFailed(this.errorMessage);
}

class LikeUnLikeLoading extends PostState {}

class LikeUnLikeSuccess extends PostState {
  Like postLike;
  LikeUnLikeSuccess(this.postLike);
}

class LikeUnLikeFailed extends PostState {
  String errorMessage;
  LikeUnLikeFailed(this.errorMessage);
}

class AddCommentLoading extends PostState {}

class AddCommentSuccess extends PostState {
  PostComment comment;
  AddCommentSuccess(this.comment);
}

class AddCommentFailed extends PostState {
  String errorMessage;
  AddCommentFailed(this.errorMessage);
}

class GetCommentsLoading extends PostState {}

class GetCommentsSuccess extends PostState {
  List<PostComment> comments;
  GetCommentsSuccess(this.comments);
}

class GetCommentsFailed extends PostState {}

class DeleteCommentLoading extends PostState {
  DeleteCommentLoading();
}

class DeleteCommentSuccess extends PostState {
  DeleteCommentSuccess();
}

class DeleteCommentFailed extends PostState {
  String errorMessage;
  DeleteCommentFailed(this.errorMessage);
}

class UpdateCommentLoading extends PostState {}

class UpdateCommentSuccess extends PostState {
  UpdateCommentSuccess();
}

class UpdateCommentFailed extends PostState {
  String errorMessage;
  UpdateCommentFailed(this.errorMessage);
}

class DeletePostLoading extends PostState {}
 
class DeletePostSuccess extends PostState {}
 
class DeletePostFailed extends PostState {
  String errorMessage;
  DeletePostFailed(this.errorMessage);
}
 
class UpdatePostLoading extends PostState {
  UpdatePostLoading();
}
 
class UpdatePostSuccess extends PostState {
  UpdatePostSuccess();
}
 
class UpdatePostFailed extends PostState {
  String errorMessage;
  UpdatePostFailed(this.errorMessage);
}
