part of 'user_bloc.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserDataLoading extends UserState {}

class AddUserDetailsLoading extends UserState {
  AddUserDetailsLoading();
}

class AddUserDetailsSuccess extends UserState {
  final UserDetail userDetail;
  AddUserDetailsSuccess(this.userDetail);
}

class AddUserDetailsFailed extends UserState {
  final String errorMessage;
  AddUserDetailsFailed(this.errorMessage);
}

class GetUserDetailsLoading extends UserState {
  GetUserDetailsLoading();
}

class GetUserDetailsSuccess extends UserState {
  final UserDetail userDetail;
  GetUserDetailsSuccess(this.userDetail);
}

class GetUserDetailsFailed extends UserState {
  final String errorMessage;
  GetUserDetailsFailed(this.errorMessage);
}

class UpdateUserDetailsLoading extends UserState {
  UpdateUserDetailsLoading();
}

class UpdateUserDetailsSuccess extends UserState {
  UpdateUserDetailsSuccess();
}

class UpdateUserDetailsFailed extends UserState {
  final String errorMessage;
  UpdateUserDetailsFailed(this.errorMessage);
}

class ChangePasswordLoading extends UserState {
  ChangePasswordLoading();
}

class ChangePasswordSuccess extends UserState {
  ChangePasswordSuccess();
}

class ChangePasswordFailed extends UserState {
  String? errorMessage;
  ChangePasswordFailed({this.errorMessage});
}

class UserLoading extends UserState {
  UserLoading();
}

class UserDeleteSuccess extends UserState {
  UserDeleteSuccess();
}

class UserFailed extends UserState {
  final String errorMessage;
  UserFailed(this.errorMessage);
}

class GetAppConfigSuccess extends UserState {
  final AppConfig appConfig;
  GetAppConfigSuccess(this.appConfig);
}

class GetAppConfigFailed extends UserState {
  final String errorMessage;
  GetAppConfigFailed(this.errorMessage);
}

class GetAllUsersLoading extends UserState {
  GetAllUsersLoading();
}

class GetAllUsersSuccess extends UserState {
  final List<UserDetail> usersList;
  GetAllUsersSuccess(this.usersList);
}

class GetAllUsersFailed extends UserState {
  final String errorMessage;
  GetAllUsersFailed(this.errorMessage);
}

class OrganizationLoading extends UserState {}

class CompleteUserState extends UserState {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  bool status;
  List<Organization> organizations;
  CompleteUserState(this.firstName, this.lastName, this.email, this.phone,
      this.status, this.organizations);
}

class CompleteUserOrganizationListState extends UserState {
  Set<dynamic> filtredOrganizations;
  CompleteUserOrganizationListState(this.filtredOrganizations);
}

class SingleOrganizationState extends UserState {
  String organizationId;
  String organizationName;
  String organizationLatitude;
  String organizationLongitude;
  String? organizationRadius;
  bool? geoLocationEnable;
  bool? isParentOrganization;
  bool? isSubOrganization;
  String? parentOrganizationId;
  List<Organization>? subOrganizations;

  SingleOrganizationState(
      this.organizationId,
      this.organizationName,
      this.organizationLatitude,
      this.organizationLongitude,
      this.organizationRadius,
      this.geoLocationEnable,
      this.isParentOrganization,
      this.isSubOrganization,
      this.parentOrganizationId,
      this.subOrganizations);
}

class EmptyOrganizationState extends UserState {
  EmptyOrganizationState();
}

class MultipleOrganizationState extends UserState {
  List<Organization> organizationList;
  MultipleOrganizationState(this.organizationList);
}

class GetMyAttendanceHistorySuccess extends UserState {
  List<AttendanceHistroy> attendanceHistory = [];
  GetMyAttendanceHistorySuccess(this.attendanceHistory);
}

class UpdateProfileSuccessState extends UserState {
  UpdateProfileSuccessState();
}

class UpdateProfileFailedState extends UserState {
  String? errorMessage;
  UpdateProfileFailedState(this.errorMessage);
}

class UserError extends UserState {
  String? errorMessage;
  UserError({this.errorMessage});
}

class DeleteUserSuccessState extends UserState {
  DeleteUserSuccessState();
}

class ChangePasswordSuccessState extends UserState {
  ChangePasswordSuccessState();
}

class GetUserDetailSuccessState extends UserState {
  final UserProfile userProfile;
  GetUserDetailSuccessState(this.userProfile);
}

class GetUserDetailFailedState extends UserState {
  String? errorMessage;
  GetUserDetailFailedState(this.errorMessage);
}

class GetAttendanceHistorySuccess extends UserState {
  AttendanceHistroy record;
  List<Organization> assignedOrganizations;
  GetAttendanceHistorySuccess(this.record, this.assignedOrganizations);
}

class GetAttendanceHistoryFailed extends UserState {
  String errorMessage;
  GetAttendanceHistoryFailed(this.errorMessage);
}
