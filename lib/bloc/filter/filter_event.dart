part of 'filter_bloc.dart';

abstract class FilterEvent {}

class ShiftFilter extends FilterEvent {
  String shift;
  ShiftFilter(this.shift);
}

class MonthFilter extends FilterEvent {
  String month;
  MonthFilter(this.month);
}

class DateFilter extends FilterEvent {
  String date;
  DateFilter(this.date);
}

class ReloadRecords extends FilterEvent {}
