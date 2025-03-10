import 'package:flutter/material.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/utils/assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/utils/colors/colors.dart';
import 'package:tasko/utils/connectivity.dart';

import 'background/background_image.dart';

class NetworkWidgets {
  static Widget netWorkStatus(BuildContext context, Function reload) {
    return Container(
        color: bgColor,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              bgLogin(),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(Assets.noInternetConnection,
                        width: 180.w, height: 180.h),
                    SizedBox(height: 50.h),
                    Padding(
                        padding: EdgeInsets.only(left: 40.w),
                        child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        color: primaryColor, width: 8))),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10.w),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(translation(context).oops,
                                            style: TextStyle(
                                                fontSize: 30.sp,
                                                fontWeight: FontWeight.w600)),
                                        Text(translation(context).noInternet,
                                            style: TextStyle(
                                                overflow: TextOverflow.visible,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400)),
                                        Text(
                                            translation(context)
                                                .checkConnection,
                                            softWrap: true,
                                            style: TextStyle(
                                                overflow: TextOverflow.visible,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400))
                                      ]))
                                ]))),
                    SizedBox(height: 50.h),
                    Container(
                        height: 40.h,
                        width: 300.w,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        child: InkWell(
                            onTap: () {
                              connectivityCheck().then((internet) {
                                if (internet && context.mounted) {
                                  Navigator.pop(context);
                                  reload();
                                }
                              });
                              reload();
                            },
                            child: Center(
                                child: Text(translation(context).tryAgain,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ))))),
                    SizedBox(height: 30.h),
                  ])
            ])));
  }
}
