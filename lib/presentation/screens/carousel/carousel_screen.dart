import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/model/post_comment.dart';
import 'package:tasko/data/model/task_comment.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class CarouselScreen extends StatefulWidget {
  final Post? post;
  final PostComment? postComment;
  final TaskComment? taskComment;
  final int selectedIndex;
  const CarouselScreen(this.post, this.postComment, this.taskComment,
      {super.key, required this.selectedIndex});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(jumpToSelectedPage);
    super.initState();
  }

  jumpToSelectedPage(_) {
    _carouselController.animateToPage(widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildCarousel());
  }

  List<Widget> postMediaSliders() => widget.post!.mediaUrl!
      .map((postFile) => _buildProductCarouselItem(
            Post.getImagePath(widget.post!.postId, postFile),
          ))
      .toList();

  List<Widget> commentImageSliders() => widget.postComment!.images!
      .map((commentFile) => _buildProductCarouselItem(
            PostComment.getCommentImagePath(widget.postComment!.postId,
                widget.postComment!.commentId, commentFile),
          ))
      .toList();

  List<Widget> taskCommentImageSliders() =>
      widget.taskComment!.taskCommentImages!
          .map((commentFile) => _buildProductCarouselItem(
                TaskComment.getCommentImagePath(widget.taskComment!.taskId,
                    widget.taskComment!.commentId, commentFile),
              ))
          .toList();

  Widget _buildCarousel() {
    bool isCommentData = widget.postComment != null;
    bool isTaskCommentData = widget.taskComment != null;
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.zero,
        child: Stack(children: [
          CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                  padEnds: false,
                  autoPlay: false,
                  enableInfiniteScroll: isTaskCommentData
                      ? widget.taskComment!.taskCommentImages!.length > 1
                      : isCommentData
                          ? widget.postComment!.images!.length > 1
                          : widget.post!.mediaUrl!.length > 1,
                  height: MediaQuery.of(context).size.height,
                  aspectRatio: 1,
                  viewportFraction: 1,
                  enlargeCenterPage: false),
              items: isTaskCommentData
                  ? taskCommentImageSliders()
                  : isCommentData
                      ? commentImageSliders()
                      : postMediaSliders()),
          (isTaskCommentData
                  ? widget.taskComment!.taskCommentImages!.length > 1
                  : isCommentData
                      ? widget.postComment!.images!.length > 1
                      : widget.post!.mediaUrl!.length > 1)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      onPressed: () {
                        // Use the controller to change the current page
                        _carouselController.previousPage();
                      },
                      icon: const CircleAvatar(
                          backgroundColor: white,
                          child: Padding(
                              padding: EdgeInsets.only(left: 5),
                              child:
                                  Icon(Icons.arrow_back_ios, color: black)))))
              : const SizedBox(),
          (isTaskCommentData
                  ? widget.taskComment!.taskCommentImages!.length > 1
                  : isCommentData
                      ? widget.postComment!.images!.length > 1
                      : widget.post!.mediaUrl!.length > 1)
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        // Use the controller to change the current page
                        _carouselController.nextPage();
                      },
                      icon: const CircleAvatar(
                          backgroundColor: white,
                          child: Icon(Icons.arrow_forward_ios, color: black))))
              : const SizedBox()
        ]));
  }

  Widget _buildProductCarouselItem(dynamic image) {
    bool isVideoUrl = checkVideoUrl(image);
    return Container(
        padding: EdgeInsets.zero,
        child: isVideoUrl
            ? Stack(children: [
                Center(
                    child: VideoPlayerWidget(
                  videoUrl: image,
                  isListScreen: false,
                )),
                Padding(
                    padding: EdgeInsets.only(left: 10, top: 30.h),
                    child: CircleAvatar(
                        backgroundColor: white,
                        child: IconButton(
                            padding: EdgeInsets.only(left: 8.w),
                            icon:
                                const Icon(Icons.arrow_back_ios, color: black),
                            onPressed: () {
                              Navigator.pop(context);
                            })))
              ])
            : ZoomImage(url: image));
  }
}
