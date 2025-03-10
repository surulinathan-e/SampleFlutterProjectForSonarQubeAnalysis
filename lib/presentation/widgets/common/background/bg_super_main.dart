import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/utils/utils.dart';

Widget buildBackgroundWidget() {
  return Stack(children: [
    Container(
        height: 120.w,
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        )),
    Positioned(
        top: -130.0,
        left: 10.0,
        child: Opacity(
            opacity: 0.15,
            child: Container(
                height: 185.0,
                width: 185.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(416.0),
                    gradient: dartGreenToLightGreenVector)))),
    Positioned(
        top: -90.0,
        left: -90.0,
        child: Opacity(
            opacity: 0.15,
            child: Container(
                height: 185.0,
                width: 185.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(416.0),
                    gradient: dartGreenToLightGreenVector))))
  ]);
}
