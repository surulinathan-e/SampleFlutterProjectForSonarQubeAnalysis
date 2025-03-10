import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/utils/utils.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilteringBloc extends Bloc<FilterEvent, FilterState> {
  // variables
  List<List<String>> lls = [];
  List<String> ls = [];

  FilteringBloc() : super(FilterInitialState()) {
    on<FilterEvent>((event, emit) {
      if (event is ReloadRecords) {
        emit(FilterInitialState());
      } else if (event is ShiftFilter) {
        filterShift(event.shift);
        lls.isEmpty
            ? emit(FilterNoRecordFoundState())
            : emit(FilterCompletedState(lls));
      } else if (event is MonthFilter) {
        filterMonth(event.month);
        lls.isEmpty
            ? emit(FilterNoRecordFoundState())
            : emit(FilterCompletedState(lls));
      } else if (event is DateFilter) {
        filterDate(event.date);
        lls.isEmpty
            ? emit(FilterNoRecordFoundState())
            : emit(FilterCompletedState(lls));
      }
    });
  }

  // shiftId filter method
  filterShift(String shft) {
    lls = [];
    if (shft == "All") {
      for (int i = 0;
          i < UserDetailsDataStore.getAttendanceHistory.length;
          i++) {
        if (UserDetailsDataStore.getAttendanceHistory[i].clockOut != null) {
          DateTime inDate = DateTime.parse(
              UserDetailsDataStore.getAttendanceHistory[i].clockIn!);
          DateTime outDate = DateTime.parse(
              UserDetailsDataStore.getAttendanceHistory[i].clockOut!);
          Duration diff = outDate.difference(inDate);

          ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
          ls.add(DateFormat("dd/MM/yy").format(inDate));
          ls.add(DateFormat("hh:mm a").format(inDate));
          ls.add(DateFormat("hh:mm a").format(outDate));
          ls.add('${_printDuration(diff)} hrs');
          lls.add(ls);
          ls = [];
        }
      }
    } else {
      for (int i = 0;
          i < UserDetailsDataStore.getAttendanceHistory.length;
          i++) {
        String s = UserDetailsDataStore.getAttendanceHistory[i].shiftId!;
        if (s == shft &&
            UserDetailsDataStore.getAttendanceHistory[i].clockOut != null) {
          // timeStamps
          DateTime inDate = DateTime.parse(
              UserDetailsDataStore.getAttendanceHistory[i].clockIn!);
          DateTime outDate = DateTime.parse(
              UserDetailsDataStore.getAttendanceHistory[i].clockOut!);
          Duration diff = outDate.difference(inDate);
          ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
          ls.add(DateFormat("dd/MM/yy").format(inDate));
          ls.add(DateFormat("hh:mm a").format(inDate));
          ls.add(DateFormat("hh:mm a").format(outDate));
          ls.add('${_printDuration(diff)} hrs');
          lls.add(ls);
          ls = [];
        }
      }
    }
  }

  List<String> addM2ls(DateTime inT, DateTime outT) {
    List<String> dls = [];
    Duration diff = outT.difference(inT);

    dls.add(DateFormat("dd/MM/yy").format(inT));
    dls.add(DateFormat("hh:mm a").format(inT));
    dls.add(DateFormat("hh:mm a").format(outT));
    dls.add('${_printDuration(diff)} hrs');
    return dls;
  }

  String _printDuration(Duration diff) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));
    return "${twoDigits(diff.inHours)}:$twoDigitMinutes";
  }

  // mont filter method
  filterMonth(String mth) {
    lls = [];
    for (int i = 0; i < UserDetailsDataStore.getAttendanceHistory.length; i++) {
      // timeStamps
      if (UserDetailsDataStore.getAttendanceHistory[i].clockOut != null) {
        DateTime inDate = DateTime.parse(
            UserDetailsDataStore.getAttendanceHistory[i].clockIn!);
        DateTime outDate = DateTime.parse(
            UserDetailsDataStore.getAttendanceHistory[i].clockOut!);

        switch (mth) {
          case "January":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "February":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "March":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "April":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "May":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "June":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "July":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "August":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "September":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "October":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "November":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          case "December":
            {
              ls = [];
              if (DateFormat("MMMM").format(inDate) == mth) {
                ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
                ls.addAll(addM2ls(inDate, outDate));
                lls.add(ls);
              }
            }
            break;
          default:
            Logger.printLog("### something went wrong in month filters ####");
        }
      }
    }
  }

  // date filter
  filterDate(String date) {
    lls = [];
    for (int i = 0; i < UserDetailsDataStore.getAttendanceHistory.length; i++) {
      ls = [];
      if (UserDetailsDataStore.getAttendanceHistory[i].clockOut != null) {
        DateTime inDate = DateTime.parse(
            UserDetailsDataStore.getAttendanceHistory[i].clockIn!);
        DateTime outDate = DateTime.parse(
            UserDetailsDataStore.getAttendanceHistory[i].clockOut!);
        if (date == DateFormat("dd/MM/yyyy").format(inDate)) {
          ls.add(UserDetailsDataStore.getAttendanceHistory[i].shiftId!);
          ls.addAll(addM2ls(inDate, outDate));
          lls.add(ls);
        }
      }
    }
  }
}
