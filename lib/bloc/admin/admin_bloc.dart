import 'package:bloc/bloc.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/organization_user.dart';
import 'package:tasko/data/model/scheduled_shift.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/user_detail.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/data/repo/admin_repo.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepo adminRepo = AdminRepo();

  AdminBloc() : super(AdminInitialState()) {
    on<AdminEvent>((event, emit) async {
      if (event is GetAllOrganization) {
        emit(GetAllOrganizationLoading());
        try {
          List<Organization> organizationList =
              await adminRepo.getAllOrganization();
          emit(GetAllOrganizationSuccess(organizationList));
        } catch (error) {
          emit(GetAllOrganizationFailed(error.toString()));
        }
      } else if (event is AddOrganization) {
        emit(AddOrganizationLoading());
        try {
          await adminRepo.addOrganization(
              event.parentOrganizationId,
              event.name,
              event.email,
              event.address,
              event.geoLocationEnable,
              event.latitude,
              event.longitude,
              event.geoRadius);
          emit(AddOrganizationSuccess());
        } catch (error) {
          emit(AddOrganizationFailed(error.toString()));
        }
      } else if (event is UpdateOrganization) {
        emit(UpdateOrganizationLoading());
        try {
          await adminRepo.updateOrganization(
              event.id,
              event.parentOrganizationId,
              event.name,
              event.email,
              event.address,
              event.geoLocationEnable,
              event.latitude,
              event.longitude,
              event.geoRadius,
              event.isParentOrganization);
          emit(UpdateOrganizationSuccess());
        } catch (error) {
          emit(UpdateOrganizationFailed(error.toString()));
        }
      } else if (event is DeleteOrganization) {
        try {
          emit(DeleteOrganizationLoading());
          await adminRepo.deleteOrganization(event.orgId);
          emit(DeleteOrganizationSuccess());
        } catch (error) {
          emit(DeleteOrganizationFailed(error.toString()));
        }
      } else if (event is GetUsersByOrganization) {
        try {
          if (event.page == 1) {
            emit(GetUsersOrganizationLoading());
          }
          List<UserProfile> userList = await adminRepo.getUsersByOrganization(
              event.orgId, event.page, event.limit, event.searchUser);
          emit(GetUsersOrganizationSuccess(userList));
        } catch (error) {
          emit(GetUsersOrganizationFailed(error.toString()));
        }
      } else if (event is GetOrganizationShifts) {
        if (event.page == 1) {
          emit(GetOrganizationShiftsLoading());
        }
        try {
          List<Shift> shiftList = await adminRepo.getOrganizationShifts(
              event.organizationId, event.page, event.limit);
          emit(GetOrganizationShiftsSuccess(shiftList));
        } catch (error) {
          emit(GetOrganizationShiftsFailed(error.toString()));
        }
      } else if (event is CreateShift) {
        emit(CreateShiftLoading());
        try {
          await adminRepo.createShift(
              event.organizationId,
              event.shiftName,
              event.shiftStartDate,
              event.shiftEndDate,
              event.startTime,
              event.endTime,
              event.sunday,
              event.monday,
              event.tuesday,
              event.wednesday,
              event.thursday,
              event.friday,
              event.saturday);
          emit(CreateShiftSuccess());
        } catch (error) {
          emit(CreateShiftFailed(error.toString()));
        }
      } else if (event is UpdateShift) {
        emit(UpdateShiftLoading());
        try {
          await adminRepo.updateShift(
              event.shiftId,
              event.organizationId,
              event.shiftName,
              event.shiftStartDate,
              event.shiftEndDate,
              event.startTime,
              event.endTime,
              event.sunday,
              event.monday,
              event.tuesday,
              event.wednesday,
              event.thursday,
              event.friday,
              event.saturday);
          emit(UpdateShiftSuccess());
        } catch (error) {
          emit(UpdateShiftFailed(error.toString()));
        }
      } else if (event is DeleteShift) {
        emit(DeleteShiftLoading());
        try {
          await adminRepo.deleteShift(event.shiftId);
          emit(DeleteShiftSuccess());
        } catch (error) {
          emit(DeleteShiftFailed(error.toString()));
        }
      } else if (event is AssignShiftUser) {
        emit(AssignShiftUserLoading());
        try {
          await adminRepo.assignShiftUser(
              event.organizationId, event.userId, event.shiftId);
          emit(AssignShiftUserSuccess());
        } catch (error) {
          emit(AssignShiftUserFailed(error.toString()));
        }
      } else if (event is GetUserScheduledShifts) {
        emit(GetUserScheduledShiftsLoading());
        try {
          List<ScheduledShift> scheduledShiftList = await adminRepo
              .getScheduledUserShifts(event.organizationId, event.userId);
          emit(GetUserScheduledShiftsSuccess(scheduledShiftList));
        } catch (error) {
          emit(GetUserScheduledShiftsFailed(error.toString()));
        }
      } else if (event is ShiftAcceptOrReject) {
        emit(ShiftAcceptOrRejectLoading());
        try {
          await adminRepo.shiftAcceptOrReject(
              event.scheduledShiftId, event.status);
          emit(ShiftAcceptOrRejectSuccess());
        } catch (error) {
          emit(ShiftAcceptOrRejectFailed(error.toString()));
        }
      } else if (event is GetUnassignedShiftUser) {
        emit(GetUnassignedShiftUserLoading());
        try {
          List<OrganizationUser> unAssignedUserList =
              await adminRepo.getUnassignedShiftUser(
                  event.organizationId, event.shiftId, event.searchKey);
          emit(GetUnassignedShiftUserSuccess(unAssignedUserList));
        } catch (error) {
          emit(GetUnassignedShiftUserFailed(error.toString()));
        }
      } else if (event is DeleteUserAdmin) {
        try {
          emit(DeleteUserLoading());
          await adminRepo.deleteUser(
              event.userId, event.organizationId, event.isAdmin);
          emit(DeleteUserSuccess());
        } catch (error) {
          emit(DeleteUserFailed(error.toString()));
        }
      } else if (event is AddOrganizationUser) {
        emit(AddOrganizationUserLoading());
        try {
          await adminRepo.addOrganizationUser(
              event.organizationId, event.users);
          emit(AddOrganizationUserSuccess());
        } catch (error) {
          emit(AddOrganizationUserFailed(error.toString()));
        }
      } else if (event is RemoveOrganizationUser) {
        emit(RemoveOrganizationUserLoading());
        try {
          await adminRepo.removeOrganizationUser(
              event.organizationId, event.userId);
          emit(RemoveOrganizationUserSuccess());
        } catch (error) {
          emit(RemoveOrganizationUserFailed(error.toString()));
        }
      } else if (event is UpdateDbUser) {
        try {
          emit(UpdateDbUserLoading());
          await adminRepo.updateUser(
              event.id,
              event.firstName,
              event.lastName,
              event.email,
              event.countryCode,
              event.countryIsoCode,
              event.phoneNumber,
              event.isActive,
              event.isAdmin);
          emit(UpdateDbUserSuccess());
        } catch (error) {
          emit(UpdateDbUserFailed(error.toString()));
        }
      } else if (event is GetUnassignedOrganizationUsers) {
        try {
          emit(GetUnassignedOrganizationUsersLoading());
          List<UserProfile> userList =
              await adminRepo.getUnassignedOrganizationUsers(event.orgId);
          emit(GetUnassignedOrganizationUsersSuccess(userList));
        } catch (error) {
          emit(GetUnassignedOrganizationUsersFailed(error.toString()));
        }
      } else if (event is GetUnassignedUsers) {
        try {
          if (event.page == 1) {
            emit(GetUnassignedUsersLoading());
          }
          List<UserProfile> userList = await adminRepo.getUnassignedUsers(
              event.orgId, event.searchKey, event.page, event.limit);
          emit(GetUnassignedUsersSuccess(userList));
        } catch (error) {
          emit(GetUnassignedUsersFailed(error.toString()));
        }
      } else if (event is AcceptAllPendingScheduledShifts) {
        try {
          emit(AcceptAllPendingScheduledShiftsLoading());
          await adminRepo.acceptAllPendingUserShifts(
              event.userId, event.organizationId);
          emit(AcceptAllPendingScheduledShiftsSuccess());
        } catch (error) {
          emit(AcceptAllPendingScheduledShiftsFailed(error.toString()));
        }
      }
    });
  }
}
