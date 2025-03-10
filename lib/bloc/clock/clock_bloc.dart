import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_pending_scheduled_shift.dart';
import 'package:tasko/data/repo/clock_repo.dart';
part 'clock_event.dart';
part 'clock_state.dart';

class ClockBloc extends Bloc<ClockEvent, ClockState> {
  final ClockRepo clockRepo = ClockRepo();

  ClockBloc() : super(ClockInit(UserDetailsDataStore.getUserStatus!)) {
    on<ClockEvent>((event, emit) async {
      if (event is ClockInEvent) {
        try {
          emit(ClockLoading());
          final prefs = await SharedPreferences.getInstance();
          AttendanceHistroy attendanceRecord = await clockRepo.userClockIn(
              event.userId,
              event.shiftId,
              event.organizationId,
              event.attendanceRecordId,
              event.clockOutReason);
          prefs.setString('currentClockInId', attendanceRecord.id!);
          UserDetailsDataStore.setCurrentClockInId = attendanceRecord.id;
          bool clockInStatus = UserDetailsDataStore.getUserStatus!;
          prefs.setBool('userStatus', true);
          UserDetailsDataStore.setClockIn = true;
          emit(ClockIn(clockInStatus));
        } catch (error) {
          emit(ClockFailed(error.toString()));
        }
      } else if (event is ClockOutEvent) {
        try {
          emit(ClockLoading());
          final prefs = await SharedPreferences.getInstance();
          await clockRepo.userClockOut(
              event.userId,
              event.shiftId,
              event.organizationId,
              event.attendanceRecordId,
              event.clockOutReason);
          bool clockOutStatus = UserDetailsDataStore.getUserStatus!;
          prefs.setBool('userStatus', false);
          UserDetailsDataStore.setClockOut = false;
          emit(ClockOut(clockOutStatus));
        } catch (error) {
          emit(ClockFailed(error.toString()));
        }
      } else if (event is ClockInDisableEvent) {
        emit(ClockInDisable());
      } else if (event is GetShiftDataEvent) {
        try {
          List<Shift> shiftData =
              await clockRepo.getShiftData(event.organizationId);
          emit(GetShiftDataSuccess(shiftData));
        } catch (error) {
          emit(GetShiftFailed(error.toString()));
        }
      } else if (event is GetUserPendingScheduledShifts) {
        try {
          emit(GetUserPendingScheduledShiftsLoading());
          List<UserPendingScheduledShift> pendingScheduledShifts =
              await clockRepo.getUserPendingScheduledShifts(
                  event.organizationId, event.userId);
          emit(GetUserPendingScheduledShiftsSuccess(pendingScheduledShifts));
        } catch (error) {
          emit(GetUserPendingScheduledShiftsFailed(error.toString()));
        }
      }else if (event is GetTodayScheduledShift) {
        try {
          Shift? shiftData =
              await clockRepo.getTodayScheduledShift(event.organizationId);
          emit(GetTodayScheduledShiftSuccess(shiftData));
        } catch (error) {
          emit(GetTodayScheduledShiftFailed(error.toString()));
        }
      } 
    });
  }
}
