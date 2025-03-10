import 'package:flutter/material.dart';
import 'package:tasko/utils/assets.dart';

Widget buildHorizontalLogo() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        Assets.appLogo,
        height: 30,
        // width: 48,
        fit: BoxFit.contain,
      ),
    ],
  );
}
