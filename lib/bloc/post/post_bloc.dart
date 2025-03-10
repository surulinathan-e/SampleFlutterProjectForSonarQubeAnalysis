import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:tasko/data/model/like_details.dart';
import 'package:tasko/data/model/post_comment.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/data/repo/post_repo.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepo postRepo = PostRepo();

  PostBloc() : super(PostInit()) {
    on<PostEvent>((event, emit) async {
      if (event is AddPost) {
        try {
          emit(AddPostLoading());
          await postRepo.addPost(event.content, event.userName, event.userId,
              event.organizationId, event.files);
          emit(AddPostSuccess());
        } catch (error) {
          emit(AddPostFailed(error.toString()));
        }
      } else if (event is GetPost) {
        if (event.page == 1) {
          emit(GetPostLoading());
        }
        try {
          List<Post> response = await postRepo.getPostDetails(
              event.orgId, event.page, event.limit);
          emit(GetPostSuccess(response));
        } catch (error) {
          emit(GetPostFailed(error.toString()));
        }
      } else if (event is LikeUnlikePost) {
        try {
          emit(LikeUnLikeLoading());
          Like response =
              await postRepo.likeUnlikePost(event.userId, event.postId);
          emit(LikeUnLikeSuccess(response));
        } catch (error) {
          emit(LikeUnLikeFailed(error.toString()));
        }
      } else if (event is AddComment) {
        try {
          emit(AddCommentLoading());
          PostComment response = await postRepo.addComment(
              event.content,
              event.userName,
              event.postId,
              event.userId,
              event.organizationId,
              event.files);
          emit(AddCommentSuccess(response));
        } catch (error) {
          emit(AddCommentFailed(error.toString()));
        }
      } else if (event is UpdateComment) {
        try {
          emit(UpdateCommentLoading());
          await postRepo.updateComment(event.commentId, event.userComment,
              event.postId, event.files, event.removedFilePotisions);
          emit(UpdateCommentSuccess());
        } catch (error) {
          emit(UpdateCommentFailed(error.toString()));
        }
      } else if (event is DeleteComment) {
        emit(DeleteCommentLoading());
        try {
          await postRepo.deleteComment(event.commentId);
          emit(DeleteCommentSuccess());
        } catch (error) {
          emit(DeleteCommentFailed(error.toString()));
        }
      }else if (event is DeletePost) {
        emit(DeletePostLoading());
        try {
          await postRepo.deletePost(event.postId);
          emit(DeletePostSuccess());
        } catch (error) {
          emit(DeletePostFailed(error.toString()));
        }
      } else if (event is UpdatePost) {
        try {
          emit(UpdatePostLoading());
          await postRepo.updatePost(event.postId, event.postContent,
              event.postFiles, event.removedPostMediaPotisions);
          emit(UpdatePostSuccess());
        } catch (error) {
          emit(UpdatePostFailed(error.toString()));
        }
      }
    });
  }
}
