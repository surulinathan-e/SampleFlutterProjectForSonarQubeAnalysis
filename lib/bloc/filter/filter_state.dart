part of 'filter_bloc.dart';

abstract class FilterState {}

class FilterInitialState extends FilterState {}

class FilterLoadState extends FilterState {
  FilterLoadState();
}

class FilterNoRecordFoundState extends FilterState {
  FilterNoRecordFoundState();
}

class FilterCompletedState extends FilterState {
  List<List<String>> lls;
  FilterCompletedState(this.lls);
}
