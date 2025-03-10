import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/utils/colors/colors.dart';

class UserAvatarWithAddStory extends StatefulWidget {
  final double radius;
  final bool isVisible;
  final String text;
  final String? profileURL;
  final File? userPhotoPath;
  final Function? isProfilePictureEdit;
  const UserAvatarWithAddStory(
      {super.key,
      required this.radius,
      required this.isVisible,
      required this.text,
      this.profileURL,
      this.userPhotoPath,
      this.isProfilePictureEdit});

  @override
  State<UserAvatarWithAddStory> createState() => _UserAvatarWithAddStoryState();
}

class _UserAvatarWithAddStoryState extends State<UserAvatarWithAddStory> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10.w, top: 5.h, right: 5.w),
        child: Column(children: [
          Stack(children: [
            widget.profileURL != null || widget.userPhotoPath != null
                ? _buildProfileImage(widget.radius.r)
                : CircleAvatar(
                    radius: widget.radius.r,
                    backgroundImage:
                        const AssetImage('assets/images/account.png')),
            Positioned(
                right: 5.w,
                bottom: 2.h,
                child: CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: (widget.radius / 3.5).r,
                    child: widget.isVisible
                        ? const Icon(
                            Icons.add,
                            size: 15,
                            color: Colors.white,
                          )
                        : InkWell(
                            onTap: () {
                              widget.isProfilePictureEdit!();
                            },
                            child: const Icon(
                              Icons.mode_edit_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                          )))
          ]),
        ]));
  }

  _buildProfileImage(double radius) {
    return ClipOval(
      child: SizedBox.fromSize(
        size: Size.fromRadius(radius),
        child: widget.userPhotoPath != null
            ? Image.file(widget.userPhotoPath!, fit: BoxFit.cover, errorBuilder:
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
            : Image.network(widget.profileURL!, fit: BoxFit.cover, errorBuilder:
                (BuildContext? context, Object? exception,
                    StackTrace? stackTrace) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 24.w),
                  ],
                );
              }),
      ),
    );
  }
}
