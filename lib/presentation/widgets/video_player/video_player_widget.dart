import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasko/utils/colors/colors.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final bool? isListScreen;
  final File? video;
  const VideoPlayerWidget(
      {super.key, this.isListScreen, this.videoUrl, this.video});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else if (widget.video != null && widget.video!.path.isNotEmpty) {
      videoPlayerController = VideoPlayerController.file(widget.video!);
    }

    videoPlayerController!.initialize().then((_) {
      setState(() {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          aspectRatio: videoPlayerController!.value.aspectRatio,
          autoInitialize: false,
          autoPlay: widget.isListScreen != true,
          allowFullScreen: true,
          allowMuting: true,
          looping: false,
          showControls: widget.isListScreen != true,
          errorBuilder: (context, errorMessage) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 24),
                Text('Error playing video'),
              ],
            );
          },
        );
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    videoPlayerController!.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController!.value.isInitialized
        ? AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: Chewie(controller: chewieController!),
          )
        : const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
  }
}
