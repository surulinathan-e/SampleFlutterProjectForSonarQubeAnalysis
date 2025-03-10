import 'dart:convert';

import 'package:tasko/data/model/scheduled_shift.dart';

class UserPendingScheduledShift {
  String? id;
  String? userId;
  String? shiftId;
  String? organizationId;
  bool? isDeleted;
  List<ScheduledShift>? pendingShifts;

  UserPendingScheduledShift(this.id, this.userId, this.shiftId,
      this.organizationId, this.isDeleted, this.pendingShifts);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userShiftId': id,
      'userId': userId,
      'shiftId': shiftId,
      'organizationId': organizationId,
      'isDeleted': isDeleted,
      'userScheduledShift': pendingShifts
    };
  }

  factory UserPendingScheduledShift.fromMap(Map<String, dynamic> map) {
    List<ScheduledShift> userShiftScheduledStatuses = map['userScheduledShift'] == null
        ? []
        : map['userScheduledShift']
            .map<ScheduledShift>(
                (image) => ScheduledShift.fromMap(image))
            .toList();
    return UserPendingScheduledShift(
        map['userShiftId'] == null ? null : map['userShiftId'] as String,
        map['userId'] == null ? null : map['userId'] as String,
        map['shiftId'] == null ? null : map['shiftId'] as String,
        map['organizationId'] == null ? null : map['organizationId'] as String,
        map['isDeleted'] == null ? null : map['isDeleted'] as bool,
        map['userScheduledShift'] == null ? null : userShiftScheduledStatuses,);
  }

  factory UserPendingScheduledShift.fromJson(String source) =>
      UserPendingScheduledShift.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
