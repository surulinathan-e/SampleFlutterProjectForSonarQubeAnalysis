import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class AddFeed extends StatefulWidget {
  final bool? isMyPostUpdate;
  final Post? post;
  const AddFeed({super.key, this.isMyPostUpdate, this.post});

  @override
  State<AddFeed> createState() => _AddFeedState();
}

class _AddFeedState extends State<AddFeed> {
  String? userPost = '';
  final FocusNode postFocusNode = FocusNode();
  List<File>? selectedMedia = [];
  List<int> removedMediaPotisions = [];
  final ImagePicker imagePicker = ImagePicker();

  String? firstName;
  String? lastName;
  String? orgName;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  PostBloc? postBloc;
  String? orgId = UserDetailsDataStore.getSelectedOrganizationId;
  List<String>? mediaUrl = [];
  bool? isFeedAdded;
  bool isPostUpdate = false;
  String? postContent;

  TextEditingController? postController;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Post? post;

  @override
  void initState() {
    super.initState();
    firstName = UserDetailsDataStore.getUserFirstName;
    lastName = UserDetailsDataStore.getUserLastName;
    orgName = UserDetailsDataStore.getSelectedOrganizationName;
    postController = TextEditingController();
    postBloc = BlocProvider.of<PostBloc>(context);
    postFocusNode.requestFocus();
    post = widget.post;
    isPostUpdate = widget.isMyPostUpdate!;
    if (isPostUpdate && post != null) {
      postContent = postController!.text = post!.content ?? '';
    }
  }

  Future getImage() async {
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        selectedMedia!.add(File(pickedImage.path));
      }
    });
  }

  Future getFile() async {
    final pickedFile = await imagePicker.pickMultiImage();
    setState(() {
      if (pickedFile.isNotEmpty) {
        selectedMedia!.addAll(pickedFile.map((image) => File(image.path)));
      }
    });
  }

  Future getVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          final videoFile = File(file.path!);
          final kb = videoFile.lengthSync() / 1024;
          final mb = kb / 1024;
          var videoSize = num.parse(mb.toStringAsFixed(2));

          if (videoSize < 40) {
            selectedMedia!.add(videoFile);
          } else {
            showAlertSnackBar(
                context, translation(context).maxSizeSupport, AlertType.error);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        appBar: _buildAppTitlewithFilter(),
        body: BlocListener(
            bloc: postBloc,
            listener: (context, state) {
              if (state is AddPostSuccess) {
                Navigator.pop(context, true);
                showAlertSnackBar(context,
                    translation(context).successfullyPosted, AlertType.success);
                postFocusNode.unfocus();
                postController!.clear();
                Navigator.of(context).pop(true);
              } else if (state is AddPostFailed) {
                Navigator.pop(context);
                showAlertSnackBar(
                    context, translation(context).postFailed, AlertType.error);
              } else if (state is UpdatePostSuccess) {
                Navigator.pop(context);
                showAlertSnackBar(
                    context,
                    translation(context).postUpdatedSuccessfully,
                    AlertType.success);
                postFocusNode.unfocus();
                postController!.clear();
                Navigator.of(context).pop(true);
              } else if (state is UpdatePostFailed) {
                Navigator.pop(context);
                showAlertSnackBar(context,
                    translation(context).postUpdateFailed, AlertType.error);
              }
            },
            child: BlocBuilder<PostBloc, PostState>(
                bloc: postBloc,
                builder: ((context, state) {
                  return _buildPostScreen();
                }))));
  }

  Widget _buildPostScreen() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          _buildCreatePost(),
          Align(
              alignment: Alignment.bottomCenter,
              child: Column(children: [
                Row(children: [
                  Flexible(
                      child: Text(translation(context).videoSize,
                          style: TextStyle(fontSize: 16.sp), maxLines: 2))
                ]),
                SizedBox(height: 10.h),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        InkWell(
                            onTap: () {
                              getVideoFile();
                            },
                            child: const Icon(Icons.video_camera_back_rounded))
                      ]),
                      InkWell(
                          onTap: () {
                            postFocusNode.requestFocus();
                          },
                          child: const Icon(Icons.keyboard_alt_outlined))
                    ])
              ]))
        ]));
  }

  AppBar _buildAppTitlewithFilter() {
    return AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, false);
            },
            child: const Icon(Icons.arrow_back_ios, color: black)),
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        title: Text(
            widget.isMyPostUpdate!
                ? translation(context).updatePost
                : translation(context).createPost,
            style: TextStyle(
                color: black, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        actions: [
          Row(children: [
            ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (!widget.isMyPostUpdate!) {
                    if (userPost!.isNotEmpty ||
                        (selectedMedia != null && selectedMedia!.isNotEmpty)) {
                      progress(context);
                      if (selectedMedia != null && selectedMedia!.isNotEmpty) {
                        postBloc!.add(AddPost(
                            userPost!,
                            '$firstName $lastName',
                            FirebaseAuth.instance.currentUser!.uid,
                            UserDetailsDataStore.getSelectedOrganizationId!,
                            selectedMedia!));
                      } else if (userPost!.isNotEmpty) {
                        postBloc!.add(AddPost(
                            userPost!,
                            '$firstName $lastName',
                            FirebaseAuth.instance.currentUser!.uid,
                            UserDetailsDataStore.getSelectedOrganizationId!,
                            []));
                      } else {
                        showAlertSnackBar(context,
                            translation(context).nothingPost, AlertType.info);
                      }
                    } else {
                      showAlertSnackBar(context,
                          translation(context).nothingPost, AlertType.info);
                    }
                  } else {
                    if (postController!.text.trim().isEmpty &&
                        (post!.mediaUrl!.isEmpty ||
                            (post!.mediaUrl!.isNotEmpty &&
                                removedMediaPotisions.isNotEmpty &&
                                post!.mediaUrl!.length ==
                                    removedMediaPotisions.length)) &&
                        selectedMedia!.isEmpty) {
                      showAlertSnackBar(context,
                          translation(context).nothingPost, AlertType.info);
                    } else if ((postContent != postController!.text ||
                            (post!.mediaUrl!.length ==
                                    removedMediaPotisions.length &&
                                selectedMedia!.isNotEmpty) ||
                            selectedMedia!.isNotEmpty ||
                            removedMediaPotisions.isNotEmpty) &&
                        (selectedMedia!.isNotEmpty ||
                            (post!.mediaUrl!.isNotEmpty &&
                                    removedMediaPotisions.isEmpty ||
                                postController!.text.trim().isNotEmpty) ||
                            removedMediaPotisions.isEmpty)) {
                      progress(context);
                      postBloc!.add(UpdatePost(
                          post!.postId!,
                          postController!.text.trim(),
                          selectedMedia!,
                          removedMediaPotisions));
                    } else {
                      if (selectedMedia!.isEmpty &&
                          (post!.mediaUrl!.isNotEmpty &&
                              removedMediaPotisions.isNotEmpty &&
                              postController!.text.trim().isEmpty)) {
                        showAlertSnackBar(context,
                            translation(context).nothingPost, AlertType.info);
                      } else {
                        showAlertSnackBar(context,
                            translation(context).noChangesMade, AlertType.info);
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: Text(translation(context).submit,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500)))
          ])
        ]);
  }

  Widget header() {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(2.0),
          height: 35.0,
          width: 35.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              gradient: dartGreenToLightGreenVector),
          child: userAvatarNoStatus()),
      SizedBox(width: 10.w),
      Text('$firstName $lastName',
          style: TextStyle(
              color: black, fontSize: 16.sp, fontWeight: FontWeight.w600))
    ]);
  }

  Widget _buildCreatePost() {
    return Expanded(
        child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextFormField(
            focusNode: postFocusNode,
            controller: postController,
            enabled: true,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                hintText: translation(context).postHint,
                border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                userPost = value;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return translation(context).somethingEnter;
              } else {
                return null;
              }
            }),
        if (post != null &&
            post!.mediaUrl != null &&
            post!.mediaUrl!.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(children: [
                StaggeredGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children: post!.mediaUrl!.map((item) {
                      int index = post!.mediaUrl!.indexOf(item);
                      bool isDeleted = removedMediaPotisions.contains(index);
                      return item.toString().contains('.mp4') ||
                              item.toString().contains('.MOV')
                          ? StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1,
                              child: _buildChildWithRemoveIcon(
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: VideoPlayerWidget(
                                        videoUrl: Post.getImagePath(
                                            post!.postId, item),
                                        isListScreen: false),
                                  ),
                                  index,
                                  isDeleted,
                                  item))
                          : StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: _buildChildWithRemoveIcon(
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ZoomImage(
                                                    url: Post.getImagePath(
                                                        post!.postId, item))));
                                      },
                                      child: ThumbnailImage(
                                          imageUrl: Post.getImagePath(
                                              post!.postId, item),
                                          userProfile: true)),
                                  index,
                                  isDeleted,
                                  item));
                    }).toList())
              ])),
        selectedMedia != null && selectedMedia!.isNotEmpty
            ? Column(children: [
                StaggeredGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children: selectedMedia!.map((item) {
                      int index = selectedMedia!.indexOf(item);
                      bool isDeleted = false;
                      if (item.path.toString().contains('.mp4') ||
                          item.path.toString().contains('.MOV')) {
                        return StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1,
                            child: _buildChildWithRemoveIcon(
                                VideoPlayerWidget(
                                    video: item, isListScreen: false),
                                index,
                                isDeleted,
                                item));
                      } else {
                        return StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: _buildChildWithRemoveIcon(
                                InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ZoomImage(file: item)));
                                    },
                                    child: ThumbnailImage(
                                        file: item, userProfile: true)),
                                index,
                                isDeleted,
                                item));
                      }
                    }).toList())
              ])
            : const SizedBox()
      ])
    ])));
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
                                  selectedMedia!.remove(item);
                                });
                              } else if (!isDeleted) {
                                setState(() {
                                  removedMediaPotisions.add(index);
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
}
