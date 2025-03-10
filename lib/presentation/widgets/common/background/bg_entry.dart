import 'package:flutter/cupertino.dart';

Widget bGEntry() {
  return Stack(
    children: [
      SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/images/pattern_warehouse.png",
          fit: BoxFit.fill,
        ),
      ),
      // Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: const BoxDecoration(
      //     gradient: dartBlueToLightBlueVector,
      //   ),
      // ),
    ],
  );
}
