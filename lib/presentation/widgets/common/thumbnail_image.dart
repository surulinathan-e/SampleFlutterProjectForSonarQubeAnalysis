import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThumbnailImage extends StatefulWidget {
  final File? file;
  final String? imageUrl;
  final bool? userProfile;

  const ThumbnailImage({super.key, this.file, this.imageUrl, this.userProfile});

  @override
  State<ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<ThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: !widget.userProfile!
            ? BorderRadius.circular(8.0)
            : BorderRadius.zero,
        child: SizedBox(
            height: widget.userProfile! ? 75.h : 105.h,
            width: widget.userProfile! ? 95.h : 75.h,
            child: widget.file != null
                ? Image.file(widget.file!, fit: BoxFit.cover, errorBuilder:
                    (BuildContext? context, Object? exception,
                        StackTrace? stackTrace) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 24.w),
                      ],
                    );
                  })
                : Image.network(widget.imageUrl!, fit: BoxFit.cover,
                    errorBuilder: (BuildContext? context, Object? exception,
                        StackTrace? stackTrace) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 24.w),
                      ],
                    );
                  })));
  }
}
