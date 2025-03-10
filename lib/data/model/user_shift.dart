import 'dart:convert';

import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/shift.dart';


class UserShift {
  String? id;
  String? userId;
  String? shiftId;
  String? organizationId;
  bool? isDeleted;
  Shift? shiftDetail;
  Organization? organizationDetail;

  UserShift(this.id, this.userId, this.shiftId, this.organizationId,
      this.isDeleted, this.shiftDetail, this.organizationDetail);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userShiftId': id,
      'userId': userId,
      'shiftId': shiftId,
      'organizationId': organizationId,
      'isDeleted': isDeleted,
      'shiftDetail': shiftDetail,
      'organizationDetail': organizationDetail
    };
  }

  factory UserShift.fromMap(Map<String, dynamic> map) {
    return UserShift(
        map['userShiftId'] == null ? null : map['userShiftId'] as String,
        map['userId'] == null ? null : map['userId'] as String,
        map['shiftId'] == null ? null : map['shiftId'] as String,
        map['organizationId'] == null ? null : map['organizationId'] as String,
        map['isDeleted'] == null ? null : map['isDeleted'] as bool,
        map['shiftDetail'] == null ? null : Shift.fromMap(map['shiftDetail']),
        map['organizationDetail'] == null
            ? null
            : Organization.fromMap(map['organizationDetail']));
  }

  factory UserShift.fromJson(String source) =>
      UserShift.fromMap(json.decode(source) as Map<String, dynamic>);
}
