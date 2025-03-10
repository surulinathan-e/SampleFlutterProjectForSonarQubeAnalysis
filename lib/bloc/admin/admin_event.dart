part of 'admin_bloc.dart';

abstract class AdminEvent {}

class GetUsersDataEvent extends AdminEvent {
  GetUsersDataEvent();
}

class GetAllOrganization extends AdminEvent {
  GetAllOrganization();
}

class AddOrganization extends AdminEvent {
  dynamic parentOrganizationId;
  String name;
  String email;
  String address;
  bool geoLocationEnable;
  String latitude;
  String longitude;
  String geoRadius;
  AddOrganization(
      this.parentOrganizationId,
      this.name,
      this.email,
      this.address,
      this.geoLocationEnable,
      this.latitude,
      this.longitude,
      this.geoRadius);
}

class UpdateOrganization extends AdminEvent {
  String id;
  dynamic parentOrganizationId;
  String name;
  String email;
  String address;
  bool geoLocationEnable;
  String latitude;
  String longitude;
  String geoRadius;
  bool isParentOrganization;
  UpdateOrganization(
      this.id,
      this.parentOrganizationId,
      this.name,
      this.email,
      this.address,
      this.geoLocationEnable,
      this.latitude,
      this.longitude,
      this.geoRadius,
      this.isParentOrganization);
}

class DeleteOrganization extends AdminEvent {
  String orgId;
  DeleteOrganization(this.orgId);
}

class GetUsersByOrganization extends AdminEvent {
  String orgId;
  int page;
  int limit;
  String searchUser;
  GetUsersByOrganization(this.orgId, this.page, this.limit, this.searchUser);
}

class GetUnassignedOrganizationUsers extends AdminEvent {
  String orgId;
  GetUnassignedOrganizationUsers(this.orgId);
}

class GetUnassignedUsers extends AdminEvent {
  String orgId;
  String searchKey;
  int page;
  int limit;
  GetUnassignedUsers(this.orgId, this.searchKey, this.page, this.limit);
}

class UpdateDbUser extends AdminEvent {
  String id;
  String firstName;
  String lastName;
  String email;
  String countryCode;
  String countryIsoCode;
  String phoneNumber;
  bool isActive;
  bool isAdmin;
  UpdateDbUser(
      this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.countryCode,
      this.countryIsoCode,
      this.phoneNumber,
      this.isActive,
      this.isAdmin);
}

class DeleteUserAdmin extends AdminEvent {
  String userId;
  String organizationId;
  bool isAdmin;
  DeleteUserAdmin(this.userId, this.organizationId, this.isAdmin);
}

class AddOrganizationUser extends AdminEvent {
  String organizationId;
  // List<String> userId;
  List<Map<String, dynamic>> users;
  AddOrganizationUser(this.organizationId, this.users);
}

class GetOrganizationShifts extends AdminEvent {
  String organizationId;
  int page;
  int limit;
  GetOrganizationShifts(this.organizationId, this.page, this.limit);
}

class CreateShift extends AdminEvent {
  String organizationId;
  String shiftName;
  String shiftStartDate;
  String shiftEndDate;
  DateTime startTime;
  DateTime endTime;
  bool sunday;
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  CreateShift(
      this.organizationId,
      this.shiftName,
      this.shiftStartDate,
      this.shiftEndDate,
      this.startTime,
      this.endTime,
      this.sunday,
      this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday);
}

class UpdateShift extends AdminEvent {
  String shiftId;
  String organizationId;
  String shiftName;
  String shiftStartDate;
  String shiftEndDate;
  DateTime startTime;
  DateTime endTime;
  bool sunday;
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  UpdateShift(
      this.shiftId,
      this.organizationId,
      this.shiftName,
      this.shiftStartDate,
      this.shiftEndDate,
      this.startTime,
      this.endTime,
      this.sunday,
      this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday);
}

class DeleteShift extends AdminEvent {
  String shiftId;
  DeleteShift(this.shiftId);
}

class AssignShiftUser extends AdminEvent {
  String organizationId;
  List<String> userId;
  String shiftId;
  AssignShiftUser(this.organizationId, this.userId, this.shiftId);
}

class GetUserScheduledShifts extends AdminEvent {
  String organizationId;
  String userId;
  GetUserScheduledShifts(this.organizationId, this.userId);
}

class ShiftAcceptOrReject extends AdminEvent {
  String scheduledShiftId;
  String status;
  ShiftAcceptOrReject(this.scheduledShiftId, this.status);
}

class GetUnassignedShiftUser extends AdminEvent {
  String organizationId;
  String shiftId;
  String searchKey;
  GetUnassignedShiftUser(this.organizationId, this.shiftId, this.searchKey);
}

class RemoveOrganizationUser extends AdminEvent {
  String organizationId;
  String userId;
  RemoveOrganizationUser(this.organizationId, this.userId);
}

class AcceptAllPendingScheduledShifts extends AdminEvent {
  String userId;
  String organizationId;
  AcceptAllPendingScheduledShifts(this.userId, this.organizationId);
}
