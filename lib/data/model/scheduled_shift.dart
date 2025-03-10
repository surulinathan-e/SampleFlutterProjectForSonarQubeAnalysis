import 'dart:convert';

import 'package:tasko/data/model/user_shift.dart';

class ScheduledShift {
  String? id;
  String? userShiftId;
  String? date;
  String? status;
  bool? isDeleted;
  UserShift? userShift;

  ScheduledShift(this.id, this.userShiftId, this.date, this.status,
      this.isDeleted, this.userShift);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userShiftScheduledId': id,
      'userShiftId': userShiftId,
      'date': date,
      'status': status,
      'isDeleted': isDeleted,
      'userShift': userShift
    };
  }

  factory ScheduledShift.fromMap(Map<String, dynamic> map) {
    return ScheduledShift(
        map['userShiftScheduledId'] == null ? null : map['userShiftScheduledId'] as String,
        map['userShiftId'] == null ? null : map['userShiftId'] as String,
        map['date'] == null ? null : map['date'] as String,
        map['status'] == null ? null : map['status'] as String,
        map['isDeleted'] == null ? null : map['isDeleted'] as bool,
        map['userShift'] == null ? null : UserShift.fromMap(map['userShift']));
  }

  factory ScheduledShift.fromJson(String source) =>
      ScheduledShift.fromMap(json.decode(source) as Map<String, dynamic>);
}
