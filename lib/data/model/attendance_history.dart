import 'dart:convert';

import 'package:tasko/data/model/user.dart';

class AttendanceHistroy {
  String? id;
  String? clockIn;
  String? clockOut;
  String? clockOutReason;
  String? organizationId;
  String? shiftId;
  String? userId;
  bool? isAutoClockOut;
  User? user;

  AttendanceHistroy(
      this.id,
      this.clockIn,
      this.clockOut,
      this.clockOutReason,
      this.organizationId,
      this.shiftId,
      this.userId,
      this.isAutoClockOut,
      this.user);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'clockIn': clockIn,
      'clockOut': clockOut,
      'clockOutReason': clockOutReason,
      'organizationId': organizationId,
      'shiftId': shiftId,
      'userId': userId,
      'isAutoClockOut': isAutoClockOut,
      'user': user
    };
  }

  factory AttendanceHistroy.fromMap(Map<String, dynamic> map) {
    return AttendanceHistroy(
        map['id'] == null ? null : map['id'] as String,
        map['clockIn'] == null ? null : map['clockIn'] as String,
        map['clockOut'] == null ? '' : map['clockOut'] as String,
        map['clockOutReason'] == null ? '' : map['clockOutReason'] as String,
        map['organizationId'] == null ? '' : map['organizationId'] as String,
        map['shiftId'] == null ? '' : map['shiftId'] as String,
        map['userId'] == null ? '' : map['userId'] as String,
        map['isAutoClockOut'] == null ? false : map['isAutoClockOut'] as bool,
        map['user'] == null ? null : User.fromJson(map['user']));
  }

  factory AttendanceHistroy.fromJson(String source) =>
      AttendanceHistroy.fromMap(json.decode(source) as Map<String, dynamic>);

  // AttendanceHistroy.fromJson(data) {
  //   id = data['id'];
  //   clockIn = data['clockIn'];
  //   clockOut = data['clockOut'];
  //   organizationId = data['organizationId'];
  //   shiftId = data['shiftId'];
  //   userId = data['userId'];
  //   isAutoClockOut = data['isAutoClockOut'];
  // }
}
