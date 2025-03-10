import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/utils/utils.dart';

// Widget bGMainMini() {
//   return Stack(
//     children: [
//       // top right big circle
//       Positioned(
//         top: -280.0,
//         left: 100.0,
//         child: Container(
//           height: 416.0,
//           width: 416.0,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(416.0),
//             gradient: darkBlueToLightBlueGradient,
//           ),
//         ),
//       ),

//       // top right small circle
//       Positioned(
//         top: 100.0,
//         right: 30,
//         child: Container(
//           height: 58.0,
//           width: 58.0,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(100.0),
//             gradient: darkBlueToLightBlueGradient,
//           ),
//         ),
//       ),

//       // bottom left small circle
//       Positioned(
//         bottom: 10.0,
//         left: -20,
//         child: Container(
//           height: 35.0,
//           width: 35.0,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(100.0),
//             gradient: darkBlueToLightBlueGradient,
//           ),
//         ),
//       ),
//     ],
//   );
// }

Widget bGMainMini() {
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
