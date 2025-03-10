part of 'admin_view_records_bloc.dart';

abstract class AdminViewRecordsEvent {}

class GetUsersAttendanceHistoryEvent extends AdminViewRecordsEvent {
  String organizarionId;
  int page;
  int limit;
  GetUsersAttendanceHistoryEvent(this.organizarionId, this.page, this.limit);
}

class CheckShiftFilter extends AdminViewRecordsEvent {
  String shift;
  CheckShiftFilter(this.shift);
}

class CheckMonthFilter extends AdminViewRecordsEvent {
  String month;
  CheckMonthFilter(this.month);
}

class CheckDateFilter extends AdminViewRecordsEvent {
  String date;
  CheckDateFilter(this.date);
}

class ReloadViewRecords extends AdminViewRecordsEvent {}

class DummyEvent extends AdminViewRecordsEvent {
  DummyEvent();
}
