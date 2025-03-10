import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/utils/colors/colors.dart';

class UserAvatar extends StatefulWidget {
  final double radius;
  final String? profileURL;
  const UserAvatar({super.key, required this.radius, this.profileURL});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(BuildContext context) {
    return _buildProfileImage();
  }

  _buildProfileImage() {
    return CircleAvatar(
        backgroundColor: black,
        radius: widget.radius.r,
        child: ClipOval(
            child: SizedBox.fromSize(
                size: Size.fromRadius(widget.radius.r),
                child: Image.network(widget.profileURL!, fit: BoxFit.cover,
                    errorBuilder: (BuildContext? context, Object? exception,
                        StackTrace? stackTrace) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.error, size: 24.w)]);
                }))));
  }
}
