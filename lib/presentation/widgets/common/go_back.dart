import 'package:flutter/material.dart';
import 'package:tasko/utils/utils.dart';

Widget goBack(Function navfun) {
  return IconButton(
      icon:
          const Icon(Icons.arrow_back_ios_new_outlined, color: brightIconColor),
      onPressed: () {
        navfun();
      });
}

Widget dashBoardGoBack(Function navfun) {
  return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_outlined, color: darkIconColor),
      onPressed: () {
        navfun();
      });
}

Widget darkBackArrow(Function navfun) {
  return InkWell(
      onTap: () {
        navfun();
      },
      child: const Icon(Icons.arrow_back_ios, color: darkIconColor));
}

Widget brightBackArrow(Function navfun) {
  return InkWell(
      onTap: () {
        navfun();
      },
      child: const Icon(Icons.arrow_back_ios, color: brightIconColor));
}

Widget chatGoBack(Function navfun) {
  return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_outlined, color: blueIconColor),
      onPressed: () {
        navfun();
      });
}
