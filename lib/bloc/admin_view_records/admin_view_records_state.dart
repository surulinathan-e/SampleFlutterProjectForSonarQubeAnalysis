part of 'admin_view_records_bloc.dart';

abstract class AdminViewRecordsState {}

class ViewRecordsInitialState extends AdminViewRecordsState {}

class ViewRecordsLoadingState extends AdminViewRecordsState {}

class ViewRecordsLoadState extends AdminViewRecordsState {
  ViewRecordsLoadState();
}

class ViewNoRecordFoundState extends AdminViewRecordsState {
  ViewNoRecordFoundState();
}

class ViewRecordsCompletedState extends AdminViewRecordsState {
  List<List<String>> lls;
  ViewRecordsCompletedState(this.lls);
}

class GetUserAttendanceHistorySuccess extends AdminViewRecordsState {
  List<AttendanceHistroy> attendanceHistory = [];
  GetUserAttendanceHistorySuccess(this.attendanceHistory);
}

class GetUserAttendanceHistoryFailed extends AdminViewRecordsState {
  String errorMessage;
  GetUserAttendanceHistoryFailed(this.errorMessage);
}
