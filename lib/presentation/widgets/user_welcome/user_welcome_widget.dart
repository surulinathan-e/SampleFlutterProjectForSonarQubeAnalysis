import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

Widget userRowWidget(String firstName, String lastName, bool status,
    bool profilePic, BuildContext context) {
  String userName = ConvertionUtil.convertSingleName(firstName, lastName);
  return Padding(
      padding: EdgeInsets.only(left: 10.0, top: profilePic ? 0 : 40),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        // user name banner
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(translation(context).welcomeBack,
                style: TextStyle(color: white, fontSize: 14.sp)),
            SizedBox(width: 5.w),
            !profilePic
                ? Container(
                    height: 12.0,
                    width: 12.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: status ? greenStatusColor : yellowStatusColor))
                : const SizedBox()
          ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Text(userName,
                        style: TextStyle(
                            color: white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold)))
              ])
        ])),
        // buildLanguageSectionWidget(context, iconColor: Colors.white),
        profilePic
            ? userAvatar(UserDetailsDataStore.getUserProfilePic, status, false)
            : IconButton(
                icon: const Icon(Icons.menu),
                color: white,
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                })
      ]));
}
