import 'package:flutter/material.dart';
import 'package:tasko/utils/assets.dart';

Widget userAvatarNoStatus() {
  return const Stack(
    clipBehavior: Clip.none,
    fit: StackFit.expand,
    children: [
      CircleAvatar(
        backgroundImage: AssetImage(Assets.account),
      ),
    ],
  );
}
