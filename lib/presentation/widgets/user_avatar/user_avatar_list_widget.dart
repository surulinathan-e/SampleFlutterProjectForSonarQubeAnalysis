import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/model/member.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

Widget userAvatarListWidget(List<Member> membersList) {
  List<String>? users = [];
  for (int i = 0; i < membersList.length; i++) {
    users.add(ConvertionUtil.convertSingleName(
        membersList[i].firstName!, membersList[i].lastName!));
  }
  return membersList.length > 3
      ? Row(children: [
          Row(children: [
            for (int i = membersList.length - 3; i < membersList.length; i++)
              membersList[i].profileUrl != null &&
                      membersList[i].profileUrl!.isNotEmpty
                  ? Align(
                      widthFactor: 0.5,
                      child: UserAvatar(
                          radius: 10.r, profileURL: membersList[i].profileUrl))
                  : Align(
                      widthFactor: 0.5,
                      child: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: white,
                          child: CircleAvatar(
                              radius: 12.r,
                              backgroundColor: getAvatarColor(i),
                              child: Text(getInitials(users[i]),
                                  style: TextStyle(
                                      fontSize: 10.sp, color: white)))))
          ]),
          Align(
              widthFactor: 0.5,
              child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: white,
                  child: CircleAvatar(
                      radius: 12.r,
                      backgroundColor: getAvatarColor(4),
                      child: Text('+${membersList.length - 3}',
                          style: TextStyle(fontSize: 10.sp, color: white)))))
        ])
      : Row(children: [
          for (int i = 0; i < membersList.length; i++)
            membersList[i].profileUrl != null &&
                    membersList[i].profileUrl!.isNotEmpty
                ? Align(
                    widthFactor: 0.5,
                    child: UserAvatar(
                        radius: 11.r, profileURL: membersList[i].profileUrl))
                : Align(
                    widthFactor: 0.5,
                    child: CircleAvatar(
                        radius: 14.r,
                        backgroundColor: white,
                        child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: getAvatarColor(i),
                            child: Text(getInitials(users[i]),
                                style:
                                    TextStyle(fontSize: 10.sp, color: white)))))
        ]);
}
