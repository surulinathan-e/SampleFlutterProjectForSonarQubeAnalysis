import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tasko/utils/utils.dart';

class ZoomImage extends StatefulWidget {
  final File? file;
  final String? url;
  static const String id = "ZoomImage";

  const ZoomImage({super.key, this.url, this.file});

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        body: Stack(children: [
          widget.file != null
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.file(widget.file!, fit: BoxFit.contain,
                      errorBuilder: (BuildContext? context, Object? exception,
                          StackTrace? stackTrace) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.error, size: 24.w)]);
                  }))
              : ZoomImageScreen(url: widget.url!),
          Positioned(
              top: 30,
              left: 16,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: CircleAvatar(
                      backgroundColor: white,
                      child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: black),
                          onPressed: () {
                            Navigator.pop(context);
                          }))))
        ]));
  }
}

class ZoomImageScreen extends StatefulWidget {
  final String? url;

  const ZoomImageScreen({super.key, @required this.url});

  @override
  State<ZoomImageScreen> createState() => ZoomImageScreenState();
}

class ZoomImageScreenState extends State<ZoomImageScreen> {
  String? url;

  ZoomImageScreenState();

  @override
  void initState() {
    url = widget.url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: NetworkImage(url!));
  }
}
