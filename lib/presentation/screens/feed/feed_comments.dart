import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/like_details.dart';
import 'package:tasko/data/model/post_comment.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class FeedComments extends StatefulWidget {
  final Post postData;
  const FeedComments({super.key, required this.postData});

  @override
  State<FeedComments> createState() => _FeedCommentsState();
}

class _FeedCommentsState extends State<FeedComments> {
  Post? postDetails;
  int? likesCount;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final FocusNode commentFocusNode = FocusNode();
  TextEditingController? commentController;
  String? userComment = '';
  PostBloc? postBloc;
  String? firstName, lastName, orgId, commentId;
  List<PostComment> comments = [];
  DateTime? postedDateTime;
  int? commentsCount;
  PostComment? commentDetail;
  bool isCommented = false, isCommentEditEnabled = false;
  final ImagePicker imagePicker = ImagePicker();
  List<File>? selectedImage = [];
  List<dynamic>? commentedFiles = [];
  List<int> removedFilePositions = [];
  List<String>? mediaUrl = [];
  String? orgName;
  Like? userLike;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  List<PostComment>? commentDatas;
  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
    postDetails = widget.postData;
    List filterLikesCount = widget.postData.likes!
        .where((element) => element.id != null && element.isDeleted == false)
        .toList();
    commentDatas =
        postDetails!.comments!.map((commentData) => commentData).toList();
    likesCount = filterLikesCount.length;
    postBloc = BlocProvider.of<PostBloc>(context);
    firstName = UserDetailsDataStore.getUserFirstName;
    lastName = UserDetailsDataStore.getUserLastName;
    orgId = UserDetailsDataStore.getSelectedOrganizationId;
    postedDateTime = DateTime.parse(postDetails!.createdAt!);
    commentsCount = widget.postData.comments!.length;
    orgName = UserDetailsDataStore.getSelectedOrganizationName;
  }

  Future getImage() async {
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        selectedImage!.add(File(pickedImage.path));
      }
    });
  }

  Future getFile() async {
    final pickedFile = await imagePicker.pickMultiImage();
    setState(() {
      if (pickedFile.isNotEmpty) {
        selectedImage!.addAll(pickedFile.map((image) => File(image.path)));
      }
    });
  }

  clearUpdateDetail() {
    commentId = '';
    commentedFiles = [];
    selectedImage = [];
    isCommentEditEnabled = false;
    commentController!.clear();
    commentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(isCommented);
          return Future.value();
        },
        child: Scaffold(
            backgroundColor: bgColor,
            body: BlocListener(
                bloc: postBloc,
                listener: (context, state) {
                  if (state is AddCommentSuccess) {
                    commentDatas!.insert(0, state.comment);
                    commentFocusNode.unfocus();
                    userComment = '';
                    commentController!.clear();
                    selectedImage = [];
                    Navigator.pop(context);
                    commentsCount = commentDatas!.length;
                  } else if (state is AddCommentFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  } else if (state is LikeUnLikeSuccess) {
                    if (state.postLike.isDeleted!) {
                      postDetails!.likes!.remove(userLike);
                    } else {
                      if (userLike!.id == null) {
                        postDetails!.likes!.remove(userLike);
                      }
                      postDetails!.likes!.add(state.postLike);
                    }
                  } else if (state is UpdateCommentSuccess) {
                    isCommented = true;
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).commentUpdateSuccess,
                        AlertType.success);
                    Navigator.of(context).pop(isCommented);
                  } else if (state is UpdateCommentFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  } else if (state is DeleteCommentSuccess) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).commentDeleteSuccess,
                        AlertType.success);
                  } else if (state is DeleteCommentFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  }
                },
                child: BlocBuilder(
                    bloc: postBloc,
                    builder: (context, state) {
                      if (state is AddCommentSuccess) {
                        return _buildPost(state);
                      } else if (state is LikeUnLikeSuccess) {
                        return _buildPost(state);
                      } else if (state is DeleteCommentSuccess) {
                        return _buildPost(state);
                      }
                      return _buildPost(state);
                    }))));
  }

  Widget _buildPost(state) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(children: [
                        Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      darkBackArrow(() {
                                        Navigator.of(context).pop(isCommented);
                                      }),
                                      SizedBox(width: 10.w),
                                      Container(
                                          padding: const EdgeInsets.all(2.0),
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              gradient:
                                                  dartGreenToLightGreenVector),
                                          child: postDetails!.profileUrl != null
                                              ? UserAvatar(
                                                  radius: 20.r,
                                                  profileURL:
                                                      postDetails!.profileUrl,
                                                )
                                              : userAvatarNoStatus()),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    postDetails!.userName ??
                                                        "Username",
                                                    style: TextStyle(
                                                        color: black,
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                RichText(
                                                    text: TextSpan(
                                                        text: '',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: black),
                                                        children: [
                                                      TextSpan(
                                                        text: ConvertionUtil
                                                            .timeAgo(
                                                                postedDateTime
                                                                    .toString()),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                primaryColor),
                                                      )
                                                    ]))
                                              ]))
                                    ])
                              ]),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(postDetails!.content ?? ''),
                                const SizedBox(height: 10),
                                if (postDetails!.mediaUrl!.isNotEmpty)
                                  SizedBox(
                                      height: 200,
                                      child: _buildCarousel(
                                          postDetails!.mediaUrl!, false, null)),
                                Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              InkWell(
                                                  onTap: () {
                                                    if (state
                                                        is! LikeUnLikeLoading) {
                                                      postBloc!
                                                          .add(LikeUnlikePost(
                                                        userId,
                                                        postDetails!.postId!,
                                                      ));

                                                      userLike = postDetails!
                                                          .likes!
                                                          .firstWhere(
                                                        (element) =>
                                                            element.userId ==
                                                            userId,
                                                        orElse: () {
                                                          return Like(
                                                              null,
                                                              postDetails!
                                                                  .postId,
                                                              userId,
                                                              false,
                                                              null);
                                                        },
                                                      );
                                                      if (userLike!.id !=
                                                          null) {
                                                        postDetails!.likes!
                                                            .remove(userLike);
                                                        likesCount =
                                                            likesCount! - 1;
                                                      } else {
                                                        postDetails!.likes!
                                                            .add(userLike!);
                                                        likesCount =
                                                            likesCount! + 1;
                                                      }
                                                    }
                                                  },
                                                  child: Row(children: [
                                                    postDetails!.likes!.any(
                                                            (item) =>
                                                                item.userId ==
                                                                    userId &&
                                                                item.isDeleted ==
                                                                    false)
                                                        ? const Icon(
                                                            Icons
                                                                .favorite_rounded,
                                                            size: 20,
                                                            color: redIconColor)
                                                        : const Icon(
                                                            Icons
                                                                .favorite_border_outlined,
                                                            size: 20,
                                                            color: black)
                                                  ]))
                                            ]),
                                            SizedBox(width: 10.w),
                                            Row(children: [
                                              InkWell(
                                                  child: Row(children: [
                                                    SizedBox(
                                                        width: 20.w,
                                                        height: 20.h,
                                                        child: Image.asset(
                                                            'assets/icons/comment.png'))
                                                  ]),
                                                  onTap: () {
                                                    commentFocusNode
                                                        .requestFocus();
                                                  })
                                            ])
                                          ]),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            likesCount == 0
                                                ? const SizedBox()
                                                : Row(children: [
                                                    Text(
                                                        likesCount! < 0
                                                            ? ''
                                                            : likesCount! > 1
                                                                ? postDetails!.likes!.any((item) =>
                                                                        item.userId ==
                                                                            userId &&
                                                                        item.isDeleted ==
                                                                            false)
                                                                    ? likesCount! >
                                                                            2
                                                                        ? '${translation(context).likedByYouAnd} ${likesCount! - 1} ${translation(context).others}'
                                                                        : '${translation(context).likedByYouAnd} ${likesCount! - 1} ${translation(context).other}'
                                                                    : '${translation(context).likedBy} $likesCount'
                                                                : likesCount == 1 &&
                                                                        postDetails!.likes!.any((item) =>
                                                                            item.userId ==
                                                                                userId &&
                                                                            item.isDeleted ==
                                                                                false)
                                                                    ? translation(
                                                                            context)
                                                                        .likedByYou
                                                                    : '${translation(context).likedBy} $likesCount',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            fontSize: 12.sp))
                                                  ]),
                                            SizedBox(width: 5.w, height: 5.h),
                                            commentsCount! >= 1
                                                ? Row(children: [
                                                    Container(
                                                        height: 25.h,
                                                        width: 25.w,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        90.0)),
                                                        child: UserDetailsDataStore
                                                                    .getUserProfilePic !=
                                                                null
                                                            ? UserAvatar(
                                                                radius: 20.r,
                                                                profileURL:
                                                                    UserDetailsDataStore
                                                                        .getUserProfilePic,
                                                              )
                                                            : userAvatarNoStatus()),
                                                    SizedBox(width: 5.w),
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 16.w,
                                                                top: 2.h,
                                                                right: 16.w,
                                                                bottom: 2.h),
                                                        decoration: BoxDecoration(
                                                            color: const Color(
                                                                0xffF5F5F5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        65.0)),
                                                        child: InkWell(
                                                            onTap: () {},
                                                            child: Text(
                                                                commentsCount! >
                                                                        1
                                                                    ? '$commentsCount ${translation(context).responses}'
                                                                    : '$commentsCount ${translation(context).response}',
                                                                style: TextStyle(
                                                                    fontSize: 12
                                                                        .sp))))
                                                  ])
                                                : const SizedBox()
                                          ])
                                    ])),
                                const Divider(),
                                SizedBox(height: 10.h)
                              ])
                        ]),
                        commentDatas!.isNotEmpty
                            ? Column(
                                children: commentDatas!
                                    .map((commentData) => _buildUserComments(
                                        commentData,
                                        context,
                                        commentDatas!.indexOf(commentData)))
                                    .toList())
                            : const SizedBox()
                      ])))),
          SizedBox(height: 10.h),
          Column(children: [
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  if (isCommentEditEnabled &&
                      commentedFiles!.isNotEmpty &&
                      commentedFiles != null)
                    Column(children: [
                      StaggeredGrid.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          children: commentedFiles!.map((item) {
                            int index = commentedFiles!.indexOf(item);
                            bool isDeleted =
                                removedFilePositions.contains(index);
                            return StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: _buildChildWithRemoveIcon(
                                    Image.network(
                                        PostComment.getCommentImagePath(
                                            postDetails!.postId,
                                            commentId,
                                            commentedFiles![index]),
                                        fit: BoxFit.cover),
                                    index,
                                    isDeleted,
                                    item));
                          }).toList())
                    ]),
                  selectedImage != null && selectedImage!.isNotEmpty
                      ? Column(children: [
                          StaggeredGrid.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                              children: selectedImage!.map((item) {
                                int index = commentedFiles != null
                                    ? (commentedFiles!.length) +
                                        selectedImage!.indexOf(item)
                                    : selectedImage!.indexOf(item);
                                bool isDeleted =
                                    removedFilePositions.contains(index);
                                return StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: _buildChildWithRemoveIcon(
                                        Image.file(item, fit: BoxFit.cover),
                                        index,
                                        isDeleted,
                                        item));
                              }).toList())
                        ])
                      : const SizedBox(),
                  Row(children: [
                    InkWell(
                        onTap: () {
                          getImage();
                        },
                        child: const Icon(Icons.camera_alt_rounded)),
                    SizedBox(width: 10.w),
                    InkWell(
                        onTap: () {
                          getFile();
                        },
                        child: const Icon(Icons.image_outlined)),
                    SizedBox(width: 10.w),
                    Flexible(
                        child: TextFormField(
                            focusNode: commentFocusNode,
                            controller: commentController,
                            onTapOutside: (event) {
                              commentFocusNode.unfocus();
                            },
                            enabled: true,
                            maxLines: 1,
                            textInputAction: TextInputAction.newline,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              hintText: translation(context).writeComment,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                      color: grayBorderColor, width: 2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide:
                                      const BorderSide(color: darkBorderColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(color: black)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                userComment = value;
                              });
                            })),
                    SizedBox(width: 10.w),
                    InkWell(
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (!isCommentEditEnabled &&
                                  commentController!.text.isNotEmpty ||
                              selectedImage!.isNotEmpty &&
                                  commentDetail == null) {
                            progress(context);
                            postBloc!.add(AddComment(
                                userComment!.trim(),
                                '$firstName $lastName',
                                postDetails!.postId!,
                                userId,
                                orgId!,
                                selectedImage!));
                          } else if (isCommentEditEnabled &&
                              (commentController!.text.trim().isNotEmpty ||
                                  (selectedImage!.isNotEmpty &&
                                      selectedImage != null)) &&
                              (commentDetail!.content !=
                                      commentController!.text ||
                                  removedFilePositions.isNotEmpty)) {
                            progress(context);
                            postBloc!.add(UpdateComment(
                                commentId!,
                                commentController!.text.trim(),
                                postDetails!.postId!,
                                selectedImage!,
                                removedFilePositions));
                          } else {
                            showAlertSnackBar(
                                context,
                                translation(context).nothingToComment,
                                AlertType.info);
                          }
                        },
                        child: const Icon(Icons.send_outlined))
                  ])
                ]))
          ]),
          isCommentEditEnabled
              ? Container(
                  color: bgColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isCommentEditEnabled) {
                                isCommentEditEnabled = false;
                              }
                              commentController!.clear();
                              commentFocusNode.unfocus();
                              removedFilePositions = [];
                              selectedImage = [];
                            });
                          },
                          child: Text(translation(context).cancel,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: primaryColor.withValues(alpha: .5),
                                  fontWeight: FontWeight.bold)),
                        ),
                        InkWell(
                            onTap: () {
                              if (isCommentEditEnabled &&
                                  (commentController!.text.isNotEmpty ||
                                      (selectedImage!.isNotEmpty &&
                                          selectedImage != null)) &&
                                  (commentDetail!.content !=
                                          commentController!.text ||
                                      removedFilePositions.isNotEmpty)) {
                                progress(context);
                                postBloc!.add(UpdateComment(
                                    commentId!,
                                    commentController!.text.trim(),
                                    postDetails!.postId!,
                                    selectedImage!,
                                    removedFilePositions));
                              } else {
                                showAlertSnackBar(
                                    context,
                                    translation(context).nothingToComment,
                                    AlertType.info);
                              }
                            },
                            child: Text(translation(context).save,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: greyTextColor,
                                    fontWeight: FontWeight.bold)))
                      ]))
              : const SizedBox()
        ]));
  }

  Widget _buildChildWithRemoveIcon(
      Widget child, int index, bool isDeleted, item) {
    return Stack(children: [
      child,
      if (!isDeleted)
        Align(
            alignment: Alignment.topRight,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        showAlertWithAction(
                            context: context,
                            title: translation(context).deleteFile,
                            content: translation(context).deleteThisFile,
                            onPress: () {
                              if (item is File) {
                                setState(() {
                                  selectedImage!.remove(item);
                                });
                              } else if (!isDeleted) {
                                setState(() {
                                  removedFilePositions.add(index);
                                });
                              }
                            });
                      },
                      child: CircleAvatar(
                          backgroundColor: redIconColor,
                          radius: 12.r,
                          child: Icon(Icons.delete, size: 16.h, color: white)))
                ])),
      if (isDeleted)
        Align(
            alignment: Alignment.center,
            child: Container(
                padding: const EdgeInsets.all(8),
                color: white.withValues(alpha: 0.5),
                child: Text(translation(context).deleted,
                    style: const TextStyle(
                        color: redIconColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))))
    ]);
  }

  Widget _buildUserComments(PostComment commentData, context, index) {
    DateTime commentedTime = DateTime.parse(commentData.createdAt!);
    return Padding(
        padding: EdgeInsets.only(left: 16.w, bottom: 16.w),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Container(
                    padding: const EdgeInsets.all(2.0),
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        gradient: dartGreenToLightGreenVector),
                    child: commentData.profileUrl != null
                        ? UserAvatar(
                            radius: 20.r,
                            profileURL: commentData.profileUrl,
                          )
                        : userAvatarNoStatus())
              ]),
              Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: lightGreyColor),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(commentData.userName ?? "Username",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600)),
                                        RichText(
                                            text: TextSpan(
                                                text: '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black87),
                                                children: [
                                              TextSpan(
                                                text: ConvertionUtil.timeAgo(
                                                    commentedTime.toString()),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: primaryColor),
                                              )
                                            ]))
                                      ]),
                                  if (commentData.userId ==
                                      UserDetailsDataStore
                                          .getCurrentFirebaseUserID)
                                    PopupMenuButton(
                                      color: white,
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                            value: 'Edit',
                                            child: Text(
                                              translation(context).edit,
                                              style: const TextStyle(
                                                  fontSize: 13.0),
                                            ),
                                            onTap: () async {
                                              setState(() {
                                                isCommentEditEnabled = true;
                                                commentFocusNode.requestFocus();
                                                commentController!.text =
                                                    commentData.content ?? '';
                                                commentDetail = commentData;
                                                commentId =
                                                    commentData.commentId;
                                                commentedFiles =
                                                    commentData.images!;
                                              });
                                            },
                                          ),
                                          PopupMenuItem(
                                            value: 'Delete',
                                            child: Text(
                                              translation(context).delete,
                                              style: const TextStyle(
                                                  fontSize: 13.0),
                                            ),
                                            onTap: () {
                                              showAlertWithAction(
                                                  context: context,
                                                  title: translation(context)
                                                      .delete,
                                                  content: translation(context)
                                                      .wantToDelete,
                                                  onPress: () {
                                                    postBloc!.add(DeleteComment(
                                                        commentData
                                                            .commentId!));
                                                  });
                                            },
                                          ),
                                        ];
                                      },
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                ])),
                        Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (commentData.content != null)
                                    Text(commentData.content ?? ''),
                                  if (commentData.images != null &&
                                      commentData.images!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Center(
                                        child: SizedBox(
                                            height: 100,
                                            width: 150,
                                            child: _buildCarousel(
                                                commentData.images!,
                                                true,
                                                index)),
                                      ),
                                    ),
                                ]))
                      ]))
            ]));
  }

  Widget _buildCarousel(List<dynamic> postFiles, bool isCommentImage, index) {
    CarouselSliderController? commentCarouselController =
        CarouselSliderController();
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.zero,
        child: Stack(children: [
          CarouselSlider(
              carouselController: isCommentImage
                  ? commentCarouselController
                  : _carouselController,
              options: CarouselOptions(
                padEnds: false,
                autoPlay: false,
                enableInfiniteScroll: isCommentImage
                    ? commentDatas![index].images!.length > 1
                    : postFiles.length > 1,
                height: MediaQuery.of(context).size.height,
                aspectRatio: 1,
                viewportFraction: 1,
                enlargeCenterPage: false,
              ),
              items: isCommentImage
                  ? commnetImageSliders(index)
                  : productSliders()),
          (isCommentImage
                  ? commentDatas![index].images!.length > 1
                  : postFiles.length > 1)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      (isCommentImage && commentCarouselController != null)
                          ? commentCarouselController.previousPage()
                          : _carouselController.previousPage();
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: black),
                  ))
              : const SizedBox(),
          (isCommentImage
                  ? commentDatas![index].images!.length > 1
                  : postFiles.length > 1)
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        (isCommentImage && commentCarouselController != null)
                            ? commentCarouselController.nextPage()
                            : _carouselController.nextPage();
                      },
                      icon: const Icon(Icons.arrow_forward_ios, color: black)))
              : const SizedBox()
        ]));
  }

  List<Widget> productSliders() => postDetails!.mediaUrl!
      .map((postFile) => _buildProductCarouselItem(
          Post.getImagePath(postDetails!.postId, postFile),
          postDetails!.mediaUrl!.indexOf(postFile)))
      .toList();

  List<Widget> commnetImageSliders(index) => commentDatas![index]
      .images!
      .map((commentFile) => _buildCommentCarouselItem(
          PostComment.getCommentImagePath(commentDatas![index].postId,
              commentDatas![index].commentId, commentFile),
          index,
          commentDatas![index].images!.indexOf(commentFile)))
      .toList();

  Widget _buildProductCarouselItem(String fileName, int index) {
    bool isVideoUrl = checkVideoUrl(fileName);
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, PageName.carouselScreen,
              arguments: {'post': postDetails!, 'selectedIndex': index});
        },
        child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            color: greyBgColor.withValues(alpha: 0.4),
            child: isVideoUrl
                ? Stack(children: [
                    Center(
                        child: VideoPlayerWidget(
                            videoUrl: fileName, isListScreen: false)),
                  ])
                : widgetShowImages(fileName)));
  }

  Widget _buildCommentCarouselItem(
      String fileName, int commentIndex, int selectedIndex) {
    bool isVideoUrl = checkVideoUrl(fileName);
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, PageName.carouselScreen, arguments: {
            'postComment': commentDatas![commentIndex],
            'selectedIndex': selectedIndex
          });
        },
        child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            color: greyBgColor.withValues(alpha: 0.4),
            child: isVideoUrl
                ? Stack(children: [
                    Center(
                        child: VideoPlayerWidget(
                            videoUrl: fileName, isListScreen: false)),
                  ])
                : widgetShowImages(fileName)));
  }
}
