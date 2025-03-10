part of 'user_bloc.dart';

abstract class UserEvent {}

class AddUserDetails extends UserEvent {
  String userId;
  String? userName;
  String? email;
  String? age;
  AddUserDetails(
    this.userId,
    this.userName,
    this.email,
    this.age,
  );
}

class GetUserDetails extends UserEvent {
  String? userId;
  GetUserDetails(this.userId);
}

class UpdateUserDetails extends UserEvent {
  String userId;
  String? userName;
  bool? pushNotificationEnabled;
  bool? emailNotificationEnabled;

  UpdateUserDetails(this.userId, this.userName, this.pushNotificationEnabled,
      this.emailNotificationEnabled);
}

class ChangePasswordEvent extends UserEvent {
  String? currentPassword;
  String? newPassword;
  ChangePasswordEvent({this.currentPassword, this.newPassword});
}

class DeleteUser extends UserEvent {
  String userId;
  DeleteUser(this.userId);
}

class GetAppConfig extends UserEvent {
  GetAppConfig();
}

class GetAllUsers extends UserEvent {
  String searchUser;
  int limit;
  int page;
  GetAllUsers(this.searchUser, this.limit, this.page);
}

class ReadUserOrganizationEvent extends UserEvent {
  ReadUserOrganizationEvent();
}

class ReadUserEvent extends UserEvent {
  ReadUserEvent();
}

class SetUserOrganization extends UserEvent {
  String organization;
  SetUserOrganization(this.organization);
}

class GetMyAttendanceHistoryEvent extends UserEvent {
  String userId;
  String organizationId;
  int page;
  int limit;
  GetMyAttendanceHistoryEvent(
      this.userId, this.organizationId, this.page, this.limit);
}

class UpdateProfileEvent extends UserEvent {
  String? firstName;
  String? lastName;
  String? email;
  String? countryISOCode;
  String? countryCode;
  String? phoneNumber;
  File? userProfilePhoto;
  bool? status = false;
  bool? isAdmin;
  String? uid;
  List<Organization>? organizations = [];
  bool? isActive;
  bool? isDeleted;
  UpdateProfileEvent(
      {this.firstName,
      this.lastName,
      this.email,
      this.countryISOCode,
      this.countryCode,
      this.phoneNumber,
      this.userProfilePhoto,
      this.status,
      this.isAdmin,
      this.uid,
      this.organizations,
      this.isActive,
      this.isDeleted});
}

class DeleteUserEvent extends UserEvent {
  String? password;
  DeleteUserEvent({this.password});
}
