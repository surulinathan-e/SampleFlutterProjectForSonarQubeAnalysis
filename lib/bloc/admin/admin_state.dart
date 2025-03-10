part of 'admin_bloc.dart';

abstract class AdminState {}

class AdminInitialState extends AdminState {}

class AdminLoadingState extends AdminState {}

class UsersCountState extends AdminState {
  int activeUserCount;
  int inActiveUserCount;
  int totalUserCount;
  List<UserDetail> userList;
  UsersCountState(this.activeUserCount, this.inActiveUserCount,
      this.totalUserCount, this.userList);
}

class GetAllOrganizationLoading extends AdminState {}

class GetAllOrganizationSuccess extends AdminState {
  List<Organization> organizations;
  GetAllOrganizationSuccess(this.organizations);
}

class GetAllOrganizationFailed extends AdminState {
  String errorMessage;
  GetAllOrganizationFailed(this.errorMessage);
}

class AddOrganizationLoading extends AdminState {}

class AddOrganizationSuccess extends AdminState {}

class AddOrganizationFailed extends AdminState {
  String errorMessage;
  AddOrganizationFailed(this.errorMessage);
}

class UpdateOrganizationLoading extends AdminState {}

class UpdateOrganizationSuccess extends AdminState {}

class UpdateOrganizationFailed extends AdminState {
  String errorMessage;
  UpdateOrganizationFailed(this.errorMessage);
}

class DeleteOrganizationLoading extends AdminState {}

class DeleteOrganizationSuccess extends AdminState {}

class DeleteOrganizationFailed extends AdminState {
  String errorMessage;
  DeleteOrganizationFailed(this.errorMessage);
}

class GetUsersOrganizationLoading extends AdminState {}

class GetUsersOrganizationSuccess extends AdminState {
  List<UserProfile> users;
  GetUsersOrganizationSuccess(this.users);
}

class GetUsersOrganizationFailed extends AdminState {
  String errorMessage;
  GetUsersOrganizationFailed(this.errorMessage);
}

class UpdateDbUserLoading extends AdminState {}

class UpdateDbUserSuccess extends AdminState {}

class UpdateDbUserFailed extends AdminState {
  String errorMessage;
  UpdateDbUserFailed(this.errorMessage);
}

class DeleteUserLoading extends AdminState {}

class DeleteUserSuccess extends AdminState {}

class DeleteUserFailed extends AdminState {
  String errorMessage;
  DeleteUserFailed(this.errorMessage);
}

class GetAllUserLoading extends AdminState {}

class GetAllUserSuccess extends AdminState {
  List<UserProfile> users;
  GetAllUserSuccess(this.users);
}

class GetAllUserFailed extends AdminState {
  String errorMessage;
  GetAllUserFailed(this.errorMessage);
}

class AddOrganizationUserLoading extends AdminState {}

class AddOrganizationUserSuccess extends AdminState {}

class AddOrganizationUserFailed extends AdminState {
  String errorMessage;
  AddOrganizationUserFailed(this.errorMessage);
}

class GetOrganizationShiftsLoading extends AdminState {}

class GetOrganizationShiftsSuccess extends AdminState {
  List<Shift> shifts;
  GetOrganizationShiftsSuccess(this.shifts);
}

class GetOrganizationShiftsFailed extends AdminState {
  String errorMessage;
  GetOrganizationShiftsFailed(this.errorMessage);
}

class CreateShiftLoading extends AdminState {}

class CreateShiftSuccess extends AdminState {}

class CreateShiftFailed extends AdminState {
  String errorMessage;
  CreateShiftFailed(this.errorMessage);
}

class UpdateShiftLoading extends AdminState {}

class UpdateShiftSuccess extends AdminState {}

class UpdateShiftFailed extends AdminState {
  String errorMessage;
  UpdateShiftFailed(this.errorMessage);
}

class DeleteShiftLoading extends AdminState {}

class DeleteShiftSuccess extends AdminState {}

class DeleteShiftFailed extends AdminState {
  String errorMessage;
  DeleteShiftFailed(this.errorMessage);
}

class AssignShiftUserLoading extends AdminState {}

class AssignShiftUserSuccess extends AdminState {}

class AssignShiftUserFailed extends AdminState {
  String errorMessage;
  AssignShiftUserFailed(this.errorMessage);
}

class GetUserScheduledShiftsLoading extends AdminState {}

class GetUserScheduledShiftsSuccess extends AdminState {
  List<ScheduledShift> scheduledShifts;
  GetUserScheduledShiftsSuccess(this.scheduledShifts);
}

class GetUserScheduledShiftsFailed extends AdminState {
  String errorMessage;
  GetUserScheduledShiftsFailed(this.errorMessage);
}

class ShiftAcceptOrRejectLoading extends AdminState {}

class ShiftAcceptOrRejectSuccess extends AdminState {}

class ShiftAcceptOrRejectFailed extends AdminState {
  String errorMessage;
  ShiftAcceptOrRejectFailed(this.errorMessage);
}

class GetUnassignedShiftUserLoading extends AdminState {}

class GetUnassignedShiftUserSuccess extends AdminState {
  List<OrganizationUser> unAssignedUserList;
  GetUnassignedShiftUserSuccess(this.unAssignedUserList);
}

class GetUnassignedShiftUserFailed extends AdminState {
  String errorMessage;
  GetUnassignedShiftUserFailed(this.errorMessage);
}

class RemoveOrganizationUserLoading extends AdminState {}

class RemoveOrganizationUserSuccess extends AdminState {}

class RemoveOrganizationUserFailed extends AdminState {
  String errorMessage;
  RemoveOrganizationUserFailed(this.errorMessage);
}

class GetUnassignedOrganizationUsersLoading extends AdminState {}

class GetUnassignedOrganizationUsersSuccess extends AdminState {
  List<UserProfile> users;
  GetUnassignedOrganizationUsersSuccess(this.users);
}

class GetUnassignedOrganizationUsersFailed extends AdminState {
  String errorMessage;
  GetUnassignedOrganizationUsersFailed(this.errorMessage);
}

class GetUnassignedUsersLoading extends AdminState {}

class GetUnassignedUsersSuccess extends AdminState {
  List<UserProfile> users;
  GetUnassignedUsersSuccess(this.users);
}

class GetUnassignedUsersFailed extends AdminState {
  String errorMessage;
  GetUnassignedUsersFailed(this.errorMessage);
}

class AcceptAllPendingScheduledShiftsLoading extends AdminState {
  AcceptAllPendingScheduledShiftsLoading();
}

class AcceptAllPendingScheduledShiftsSuccess extends AdminState {
  AcceptAllPendingScheduledShiftsSuccess();
}

class AcceptAllPendingScheduledShiftsFailed extends AdminState {
  String errorMessage;
  AcceptAllPendingScheduledShiftsFailed(this.errorMessage);
}
