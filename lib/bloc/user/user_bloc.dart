import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/data/repo/organization_repo.dart';

import '../../data/model/app_config.dart';
import '../../data/model/user_detail.dart';
import '../../data/repo/user_repo.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepo userRepo = UserRepo();
  final OrganizationRepo organizationRepo = OrganizationRepo();

  UserBloc() : super(UserInitial()) {
    on<UserEvent>((event, emit) async {
      if (event is AddUserDetails) {
        emit(AddUserDetailsLoading());
        try {
          UserDetail response = await userRepo.addUserDetails(
              event.userId, event.userName, event.email, event.age);
          emit(AddUserDetailsSuccess(response));
        } catch (error) {
          emit(AddUserDetailsFailed(error.toString()));
        }
      } else if (event is GetUserDetails) {
        emit(GetUserDetailsLoading());
        try {
          UserDetail response = await userRepo.getUserDetails();
          emit(GetUserDetailsSuccess(response));
        } catch (error) {
          emit(GetUserDetailsFailed(error.toString()));
        }
      } else if (event is UpdateUserDetails) {
        emit(UpdateUserDetailsLoading());
        try {
          await userRepo.updateUserDetails(
            event.userId,
            event.userName,
            event.pushNotificationEnabled,
            event.emailNotificationEnabled,
          );
          emit(UpdateUserDetailsSuccess());
        } catch (error) {
          emit(UpdateUserDetailsFailed(error.toString()));
        }
      } else if (event is ChangePasswordEvent) {
        emit(ChangePasswordLoading());
        var result = await UserRepo.changePassword(
            event.currentPassword!, event.newPassword!);
        if (result) {
          emit(ChangePasswordSuccess());
        } else {
          emit(ChangePasswordFailed(
              errorMessage:
                  'The current password is invalid or the user does not have a password.'));
        }
      } else if (event is DeleteUser) {
        emit(UserLoading());
        try {
          await userRepo.deleteUser(event.userId);
          emit(UserDeleteSuccess());
        } catch (err) {
          emit(UserFailed(err.toString()));
        }
      } else if (event is GetAppConfig) {
        emit(UserLoading());
        try {
          AppConfig response = await userRepo.getAppConfig();
          emit(GetAppConfigSuccess(response));
        } catch (err) {
          emit(GetAppConfigFailed(err.toString()));
        }
      } else if (event is GetAllUsers) {
        if (event.page == 1) {
          emit(GetAllUsersLoading());
        }
        try {
          List<UserDetail> users = await userRepo.getAllUsers(
              event.searchUser, event.limit, event.page);
          emit(GetAllUsersSuccess(users));
        } catch (err) {
          emit(GetAllUsersFailed(err.toString()));
        }
      } else if (event is ReadUserOrganizationEvent) {
        emit(OrganizationLoading());
        try {
          UserProfile user = await userRepo
              .getUserDetail(FirebaseAuth.instance.currentUser!.uid);
          List<Organization>? assignedOrganizations = await organizationRepo
              .getOrganizationList(FirebaseAuth.instance.currentUser!.uid);

          UserDetailsDataStore(
              uid: FirebaseAuth.instance.currentUser!.uid.trim(),
              firstName: user.firstName!.trim(),
              lastName: user.lastName != null ? user.lastName!.trim() : '',
              email: user.email!.trim(),
              countryISOCode: user.countryISOCode != null
                  ? user.countryISOCode!.trim()
                  : '',
              countryCode:
                  user.countryCode != null ? user.countryCode!.trim() : '',
              phoneNumber:
                  user.phoneNumber != null ? user.phoneNumber!.trim() : '',
              userProfilePic: user.profileUrl,
              status: user.status,
              organizations: assignedOrganizations,
              isAdmin: user.isAdmin,
              isActive: user.isActive,
              isDeleted: user.isDeleted);

          if (assignedOrganizations!.isEmpty) {
            emit(EmptyOrganizationState());
          } else {
            if (assignedOrganizations.length == 1) {
              String organizationId = assignedOrganizations[0].id!;
              String organizationName = assignedOrganizations[0].name!;
              String organizationLatitude = assignedOrganizations[0].latitude!;
              String organizationLongitude =
                  assignedOrganizations[0].longitude!;
              String? radius = assignedOrganizations[0].radius;
              bool? geoLocationEnable =
                  assignedOrganizations[0].geoLocationEnable;
              bool? isParentOrganization =
                  assignedOrganizations[0].isParentOrganization;
              bool? isSubOrganization =
                  assignedOrganizations[0].isSubOrganization;
              String? parentOrganizationId =
                  assignedOrganizations[0].parentOrganizationId;
              List<Organization>? subOrganizations =
                  assignedOrganizations[0].subOrganizations;
              emit(SingleOrganizationState(
                  organizationId,
                  organizationName,
                  organizationLatitude,
                  organizationLongitude,
                  radius,
                  geoLocationEnable,
                  isParentOrganization,
                  isSubOrganization,
                  parentOrganizationId,
                  subOrganizations));
            } else if (assignedOrganizations.length > 1) {
              if (UserDetailsDataStore.getUserStatus!) {
                final prefs = await SharedPreferences.getInstance();
                try {
                  AttendanceHistroy userRecord =
                      await userRepo.getUserClockInId(
                          UserDetailsDataStore.getCurrentFirebaseUserID!);
                  UserDetailsDataStore.setCurrentClockInId = userRecord.id!;
                  prefs.setString('currentClockInId', userRecord.id!);
                  emit(GetAttendanceHistorySuccess(
                      userRecord, assignedOrganizations));
                } catch (error) {
                  emit(GetAttendanceHistoryFailed(error.toString()));
                }
              } else {
                emit(MultipleOrganizationState(assignedOrganizations));
              }
            }
          }
        } catch (error) {
          emit(UpdateProfileFailedState(error.toString()));
        }
      } else if (event is GetMyAttendanceHistoryEvent) {
        try {
          if (event.page == 1) {
            emit(UserDataLoading());
          }
          List<AttendanceHistroy> attendanceHistory =
              await userRepo.getMyAttendanceHistory(
                  event.userId, event.organizationId, event.page, event.limit);

          emit(GetMyAttendanceHistorySuccess(attendanceHistory));
        } catch (error) {
          emit(GetAttendanceHistoryFailed(error.toString()));
        }
      } else if (event is UpdateProfileEvent) {
        emit(UserDataLoading());
        try {
          UserDetail updateUserDetail = await userRepo.updateUserDetail(
              event.uid!,
              event.firstName!,
              event.lastName!,
              event.email!,
              event.countryCode!,
              event.countryISOCode!,
              event.phoneNumber!,
              event.userProfilePhoto);
          UserDetailsDataStore(
              uid: FirebaseAuth.instance.currentUser!.uid.trim(),
              firstName: updateUserDetail.firstName != null
                  ? updateUserDetail.firstName!.trim()
                  : '',
              lastName: updateUserDetail.lastName != null
                  ? updateUserDetail.lastName!.trim()
                  : '',
              email: updateUserDetail.email != null
                  ? updateUserDetail.email!.trim()
                  : '',
              countryISOCode: updateUserDetail.countryISOCode != null
                  ? updateUserDetail.countryISOCode!.trim()
                  : '',
              countryCode: updateUserDetail.countryCode != null
                  ? updateUserDetail.countryCode!.trim()
                  : '',
              phoneNumber: updateUserDetail.phoneNumber != null
                  ? updateUserDetail.phoneNumber!.trim()
                  : '',
              userProfilePic: updateUserDetail.profileURL,
              status: updateUserDetail.status,
              organizations: UserDetailsDataStore.getUserOrganizations,
              isAdmin: updateUserDetail.isAdmin,
              isActive: updateUserDetail.isActive,
              isDeleted: updateUserDetail.isDeleted);
          emit(UpdateProfileSuccessState());
        } catch (error) {
          emit(UpdateProfileFailedState(error.toString()));
        }
      } else if (event is DeleteUserEvent) {
        emit(UserDataLoading());
        var result = await userRepo.deleteUser(event.password!);
        if (result) {
          emit(DeleteUserSuccessState());
        } else {
          emit(UserError(
              errorMessage:
                  'The password is invalid or the user does not have a password.'));
        }
      } else if (event is ChangePasswordEvent) {
        emit(UserDataLoading());
        var result = await UserRepo.changePassword(
            event.currentPassword!, event.newPassword!);

        if (result) {
          emit(ChangePasswordSuccessState());
        } else {
          emit(UserError(
              errorMessage:
                  'The current password is invalid or the user does not have a password.'));
        }
      } else if (event is GetUserDetails) {
        try {
          UserProfile response = await userRepo.getUserDetail(event.userId!);
          emit(GetUserDetailSuccessState(response));
        } catch (error) {
          emit(GetUserDetailFailedState(error.toString()));
        }
      }
    });
  }
}
