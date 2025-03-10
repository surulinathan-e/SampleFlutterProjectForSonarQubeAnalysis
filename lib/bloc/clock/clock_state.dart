part of 'clock_bloc.dart';

abstract class ClockState {}

class ClockInit extends ClockState {
  bool status;
  ClockInit(this.status);
}

class ClockIn extends ClockState {
  bool status;
  ClockIn(this.status);
}

class ClockOut extends ClockState {
  bool status;
  ClockOut(this.status);
}

class ClockInDisable extends ClockState {}

class ClockLoading extends ClockState {}

class ClockFailed extends ClockState {
  final String errorMessage;
  ClockFailed(this.errorMessage);
}

class ClockFailedState extends ClockState {}

class GetShiftDataSuccess extends ClockState {
  List<Shift> shiftData;
  GetShiftDataSuccess(this.shiftData);
}

class GetShiftFailed extends ClockState {
  final String errorMessage;
  GetShiftFailed(this.errorMessage);
}

class GetUserPendingScheduledShiftsLoading extends ClockState {}

class GetUserPendingScheduledShiftsSuccess extends ClockState {
  List<UserPendingScheduledShift> pendingScheduledShift;
  GetUserPendingScheduledShiftsSuccess(this.pendingScheduledShift);
}

class GetUserPendingScheduledShiftsFailed extends ClockState {
  final String errorMessage;
  GetUserPendingScheduledShiftsFailed(this.errorMessage);
}

class GetTodayScheduledShiftSuccess extends ClockState {
  Shift? shiftData;
  GetTodayScheduledShiftSuccess(this.shiftData);
}

class GetTodayScheduledShiftFailed extends ClockState {
  final String errorMessage;
  GetTodayScheduledShiftFailed(this.errorMessage);
}
