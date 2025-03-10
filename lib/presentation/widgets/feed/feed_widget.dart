import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/post/post_bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/like_details.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class FeedWidget extends StatefulWidget {
  const FeedWidget({super.key, required this.onBack});
  final Function onBack;

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  String? firstName;
  String? lastName;
  String? orgId;
  bool? isLiked;
  List<Post>? postData;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  PostBloc? postBloc;
  int? likedIndex;
  int page = 1;
  int limit = 10;
  bool isLastPost = false;
  Like? userLike;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    firstName = UserDetailsDataStore.getUserFirstName;
    lastName = UserDetailsDataStore.getUserLastName;
    orgId = UserDetailsDataStore.getSelectedOrganizationId;
    postBloc = BlocProvider.of<PostBloc>(context);
    netWorkStatusCheck();
    scrollController.addListener(loadMore);
  }

  netWorkStatusCheck() async {
    await connectivityCheck().then((internet) {
      if (!internet && mounted) {
        showModal(context, () {
          getPost();
        });
      } else {
        getPost();
      }
    });
  }

  getPost() {
    postBloc!.add(GetPost(orgId!, page, limit));
  }

  loadMore() {
    double maxScroll = scrollController.position.maxScrollExtent;
    double offset = scrollController.offset;
    bool outOfRange = scrollController.position.outOfRange;

    if (offset >= maxScroll && !outOfRange && !isLastPost) {
      page = page + 1;
      getPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: white,
      backgroundColor: primaryColor,
      strokeWidth: 4.0,
      onRefresh: () async {
        page = 1;
        netWorkStatusCheck();
      },
      child: BlocListener(
        bloc: postBloc,
        listener: (context, state) {
          if (state is GetPostFailed) {
            showAlertSnackBar(context,
                translation(context).failedToGetUserPosts, AlertType.error);
          } else if (state is LikeUnLikeFailed) {
            showAlertSnackBar(context,
                translation(context).pleaseTryAfterSometime, AlertType.error);
          } else if (state is LikeUnLikeSuccess) {
            if (state.postLike.isDeleted!) {
              postData![likedIndex!].likes!.remove(userLike);
            } else {
              if (userLike!.id == null) {
                postData![likedIndex!].likes!.remove(userLike);
              }
              postData![likedIndex!].likes!.add(state.postLike);
            }
          } else if (state is GetPostSuccess) {
            isLastPost = state.posts.isEmpty || state.posts.length < 10;
            if (page == 1) {
              postData = state.posts;
            } else {
              postData!.addAll(state.posts);
            }
          } else if (state is DeletePostSuccess) {
            showAlertSnackBar(context, translation(context).postDeleteSuccess,
                AlertType.success);
            page = 1;
            getPost();
          } else if (state is DeletePostFailed) {
            showAlertSnackBar(context, translation(context).postDeleteFailed,
                AlertType.error);
          }
        },
        child: BlocBuilder<PostBloc, PostState>(
          bloc: postBloc,
          builder: ((context, state) {
            if (postData != null) {
              return _buildList(context, state, postData);
            } else if (state is GetPostLoading) {
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                    child: CircularProgressIndicator(color: primaryColor)),
              );
            } else {
              return _buildNoPostOrFailed(
                  context, translation(context).pleaseTryAfterSometime);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildList(context, state, postData) {
    return postData != null && postData.isNotEmpty
        ? SingleChildScrollView(
            controller: scrollController,
            child: ListView.separated(
                primary: false,
                shrinkWrap: true,
                itemCount: !isLastPost ? postData.length + 1 : postData.length,
                separatorBuilder: (context, index) {
                  return const Divider(height: 16);
                },
                itemBuilder: (context, index) {
                  if (index == postData.length) {
                    return isLastPost
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    height: 40,
                                    width: 40,
                                    child: const CircularProgressIndicator(
                                        color: primaryColor))
                              ]);
                  } else {
                    return _buildUserFeeds(
                        postData[index], context, state, index);
                  }
                }),
          )
        : _buildNoPostOrFailed(context, translation(context).noPost);
  }

  Widget _buildNoPostOrFailed(BuildContext context, content) {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0),
      child: Center(
        child: Text(content),
      ),
    );
  }

  Widget _buildUserFeeds(Post postData, context, state, index) {
    List filterLikesCount = postData.likes!
        .where((element) => element.id != null && element.isDeleted == false)
        .toList();
    int likesCount = filterLikesCount.length;
    DateTime postedDateTime = DateTime.parse(postData.createdAt!);
    int commentsCount = postData.comments!.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(2),
                    height: 45.0,
                    width: 45.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90.0),
                      gradient: dartGreenToLightGreenVector,
                    ),
                    child: postData.profileUrl != null
                        ? UserAvatar(
                            radius: 20.r,
                            profileURL: postData.profileUrl,
                          )
                        : userAvatarNoStatus()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postData.userName ?? 'Username',
                        style: const TextStyle(
                          color: black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: black,
                          ),
                          children: [
                            TextSpan(
                              text: ConvertionUtil.timeAgo(
                                  postedDateTime.toString()),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (postData.userId ==
                UserDetailsDataStore.getCurrentFirebaseUserID)
              PopupMenuButton(
                color: white,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'Edit',
                      child: Text(
                        translation(context).edit,
                        style: const TextStyle(fontSize: 13.0),
                      ),
                      onTap: () async {
                        var result = await Navigator.pushNamed(
                            context, PageName.addFeed, arguments: {
                          'isMyPostUpdate': true,
                          'post': postData
                        });
                        if (result == true) {
                          page = 1;
                          getPost();
                        }
                      },
                    ),
                    PopupMenuItem(
                      value: 'Delete',
                      child: Text(
                        translation(context).delete,
                        style: const TextStyle(fontSize: 13.0),
                      ),
                      onTap: () async {
                        showAlertWithAction(
                            context: context,
                            title: translation(context).deletePost,
                            content: translation(context).wantToDelete,
                            onPress: () {
                              postBloc!.add(DeletePost(postData.postId!));
                            });
                      },
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (postData.content != null &&
                postData.content!.toString().trim().isNotEmpty)
              ExpandableText(postData.content, trimLines: 2),
            const SizedBox(height: 10),
            if (postData.mediaUrl!.isNotEmpty)
              SizedBox(
                  height: 200,
                  child: _buildCarousel(postData.mediaUrl!, index)),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            if (state is! LikeUnLikeLoading) {
                              postBloc!.add(
                                  LikeUnlikePost(userId, postData.postId!));
                              userLike = postData.likes!.firstWhere(
                                (element) => element.userId == userId,
                                orElse: () {
                                  return Like(null, postData.postId, userId,
                                      false, null);
                                },
                              );
                              if (userLike!.id != null) {
                                postData.likes!.remove(userLike);
                              } else {
                                postData.likes!.add(userLike!);
                              }
                              setState(() {
                                likedIndex = index;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              postData.likes!.any((item) =>
                                      item.userId == userId &&
                                      item.isDeleted == false)
                                  ? const Icon(Icons.favorite_rounded,
                                      size: 20, color: redIconColor)
                                  : const Icon(Icons.favorite_border_outlined,
                                      size: 20, color: black),
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      InkWell(
                        child: Row(
                          children: [
                            SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset('assets/icons/comment.png')),
                          ],
                        ),
                        onTap: () async {
                          var result = await Navigator.pushNamed(
                              context, PageName.addComment,
                              arguments: postData);
                          if (result != null) {
                            getPost();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            likesCount == 0
                ? const SizedBox()
                : Text(
                    likesCount < 0
                        ? ''
                        : likesCount > 1
                            ? postData.likes!.any((item) =>
                                    item.userId == userId &&
                                    item.isDeleted == false)
                                ? likesCount == 2
                                    ? '${translation(context).likedByYouAnd} ${likesCount - 1} ${translation(context).other}'
                                    : '${translation(context).likedByYouAnd} ${likesCount - 1} ${translation(context).others}'
                                : '${translation(context).likedBy} $likesCount'
                            : likesCount == 1
                                ? postData.likes!.any((item) =>
                                        item.userId == userId &&
                                        item.isDeleted == false)
                                    ? translation(context).likedByYou
                                    : '${translation(context).likedBy} $likesCount'
                                : '',
                    style: const TextStyle(fontSize: 12),
                  ),
            const SizedBox(height: 5),
            commentsCount >= 1
                ? Row(
                    children: [
                      Container(
                        height: 25.0,
                        width: 25.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90.0),
                          //gradient: dartGreenToLightGreenVector ,
                        ),
                        child: UserDetailsDataStore.getUserProfilePic != null
                            ? UserAvatar(
                                radius: 20.r,
                                profileURL:
                                    UserDetailsDataStore.getUserProfilePic,
                              )
                            : userAvatarNoStatus(),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 16, top: 2, right: 16, bottom: 2),
                        decoration: BoxDecoration(
                          color: responseBgColor,
                          borderRadius: BorderRadius.circular(65.0),
                        ),
                        child: InkWell(
                            onTap: () async {
                              var result = await Navigator.pushNamed(
                                  context, PageName.addComment,
                                  arguments: postData);
                              if (result != null) {
                                getPost();
                              }
                            },
                            child: Text(
                              commentsCount > 1
                                  ? '$commentsCount ${translation(context).responses}'
                                  : '$commentsCount ${translation(context).response}',
                              style: const TextStyle(fontSize: 12),
                            )),
                      )
                    ],
                  )
                : const SizedBox()
          ],
        )
      ],
    );
  }

  Widget _buildCarousel(List<dynamic> postFiles, index) {
    final CarouselSliderController carouselController =
        CarouselSliderController();
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.zero,
        child: Stack(children: [
          CarouselSlider(
              carouselController: carouselController,
              options: CarouselOptions(
                padEnds: false,
                autoPlay: false,
                enableInfiniteScroll: postFiles.length > 1,
                height: MediaQuery.of(context).size.height,
                aspectRatio: 1,
                viewportFraction: 1,
                enlargeCenterPage: false,
              ),
              items: productSliders(index)),
          postFiles.length > 1
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      if (carouselController != null) {
                        carouselController.previousPage();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: black),
                  ))
              : const SizedBox(),
          postFiles.length > 1
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        if (carouselController != null) {
                          carouselController.nextPage();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward_ios, color: black)))
              : const SizedBox()
        ]));
  }

  List<Widget> productSliders(index) => postData![index]
      .mediaUrl!
      .map((postFile) => _buildProductCarouselItem(
          Post.getImagePath(postData![index].postId, postFile),
          postData![index].mediaUrl!.indexOf(postFile),
          index))
      .toList();

  Widget _buildProductCarouselItem(
      String fileName, int selectedIndex, int postDataIndex) {
    bool isVideoUrl = checkVideoUrl(fileName);
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, PageName.carouselScreen, arguments: {
            'post': postData![postDataIndex],
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
                      videoUrl: fileName,
                      isListScreen: true,
                    )),
                    const Center(
                        child: Icon(Icons.play_circle_outline,
                            color: white, size: 40))
                  ])
                : widgetShowImages(fileName)));
  }
}
