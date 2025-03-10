part of 'clock_bloc.dart';

abstract class ClockEvent {}

class ClockInEvent extends ClockEvent {
  String userId;
  String shiftId;
  String organizationId;
  String attendanceRecordId;
  String clockOutReason;
  ClockInEvent(this.userId, this.shiftId, this.organizationId, this.attendanceRecordId, this.clockOutReason);
}

class ClockInDisableEvent extends ClockEvent {}

class ClockOutEvent extends ClockEvent {
  String userId;
  String shiftId;
  String organizationId;
  String attendanceRecordId;
  String clockOutReason;
  ClockOutEvent(this.userId, this.shiftId, this.organizationId, this.attendanceRecordId, this.clockOutReason);
}

class GetShiftDataEvent extends ClockEvent {
  String organizationId;
  GetShiftDataEvent(this.organizationId);
}

class GetUserPendingScheduledShifts extends ClockEvent {
  String organizationId;
  String userId;
  GetUserPendingScheduledShifts(this.organizationId, this.userId);
}

class GetTodayScheduledShift extends ClockEvent {
  String organizationId;
  GetTodayScheduledShift(this.organizationId);
}
