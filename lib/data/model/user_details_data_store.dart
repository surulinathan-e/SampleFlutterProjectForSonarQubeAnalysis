import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/organization.dart';

class UserDetailsDataStore {
  // static variables
  static String? _firstName,
      _lastName,
      _countryISOCode,
      _countryCode,
      _phoneNumber,
      _email,
      _userProfilePic,
      _uid,
      _selectedOrganizationId,
      _selectedOrganizationName,
      _selectedOrganizationLatitude,
      _selectedOrganizationLongitude,
      _selectedOrganizationRadius,
      _currentClockInId;

  static bool? _status = false,
      _isAdmin = true,
      _isActive,
      _selectedOrganizationGeoLocationEnable,
      _isDeleted;
  static List<Organization>? _organizations = [];
  static List<AttendanceHistroy> _attendanceHistory = [];
  bool? isActive;
  bool? isDeleted;

  // constructor
  UserDetailsDataStore(
      {String? firstName,
      String? lastName,
      String? email,
      String? countryISOCode,
      String? countryCode,
      String? phoneNumber,
      String? userProfilePic,
      bool? status,
      bool? isAdmin,
      List<Organization>? organizations,
      String? uid,
      bool? isActive,
      bool? isDeleted}) {
    // assign to static variable
    _firstName = firstName;
    _lastName = lastName;
    _countryISOCode = countryISOCode;
    _countryCode = countryCode;
    _phoneNumber = phoneNumber;
    _email = email;
    _status = status;
    _isAdmin = isAdmin;
    _organizations = organizations;
    _uid = uid;
    _userProfilePic = userProfilePic;
    _isActive = isActive;
    _isDeleted = isDeleted;
  }

  // set first name
  static set setFirstName(String fName) {
    _firstName = fName;
  }

  // set last name
  static set setLastName(String lName) {
    _lastName = lName;
  }

  static set setUserProfilePic(String userProfilePic) {
    _userProfilePic = userProfilePic;
  }

  // set status
  static set setClockOut(bool sts) {
    _status = sts;
  }

  // set admin bool
  static set setAdminFlag(bool saf) {
    _isAdmin = saf;
  }

  // set status
  static set setClockIn(bool sts) {
    _status = sts;
  }

  // set organization id
  static set setOrganizationId(String setOrganizationId) {
    _selectedOrganizationId = setOrganizationId;
  }

  // set organization name
  static set setOrganizationName(String organizationName) {
    _selectedOrganizationName = organizationName;
  }

  // set organization latitude
  static set setOrganizationLatitude(String organizationLatitude) {
    _selectedOrganizationLatitude = organizationLatitude;
  }

  // set organization longitude
  static set setOrganizationLongitude(String organizationLongitude) {
    _selectedOrganizationLongitude = organizationLongitude;
  }

  // set organization radius
  static set setOrganizationRadius(String organizationRadius) {
    _selectedOrganizationRadius = organizationRadius;
  }

  // set organization geo location enable
  static set setOrganizationGeoLocationEnable(
      bool organizationGeoLocationEnable) {
    _selectedOrganizationGeoLocationEnable = organizationGeoLocationEnable;
  }

  // set clock doc id
  static set setCurrentClockInId(String? currentClockInId) {
    _currentClockInId = currentClockInId;
  }

  // set clock history from firebase
  static set setClockHistory(List<AttendanceHistroy> attendanceHistory) {
    _attendanceHistory = attendanceHistory;
  }

  // return first name
  static String? get getUserFirstName {
    return _firstName;
  }

  // return last name
  static String? get getUserLastName {
    return _lastName;
  }

  // return country code
  static String? get getUserCountryISOCode {
    return _countryISOCode;
  }

  // return country code
  static String? get getUserCountryCode {
    return _countryCode;
  }

  // return phone number
  static String? get getUserPhoneNumber {
    return _phoneNumber;
  }

  // return email
  static String? get getUserEmail {
    return _email;
  }

  static String? get getUserProfilePic {
    return _userProfilePic;
  }

  // return status
  static bool? get getUserStatus {
    return _status;
  }

  // return organizations
  static List<Organization>? get getUserOrganizations {
    return _organizations!
        .where((organization) =>
            organization.isActive! && !organization.isDeleted!)
        .toList();
  }

  // return current firebase user id
  static String? get getCurrentFirebaseUserID {
    return _uid;
  }

  // return selected organization id
  static String? get getSelectedOrganizationId {
    return _selectedOrganizationId;
  }

  // return current firebase user id
  static String? get getSelectedOrganizationName {
    return _selectedOrganizationName;
  }

  static String? get getSelectedOrganizationLatitude {
    return _selectedOrganizationLatitude;
  }

  static String? get getSelectedOrganizationLongitude {
    return _selectedOrganizationLongitude;
  }

  static String? get getSelectedOrganizationRadius {
    return _selectedOrganizationRadius;
  }

  static bool? get getSelectedOrganizationGeoLocationEnable {
    return _selectedOrganizationGeoLocationEnable;
  }

  // return clockin id
  static String? get getCurrentClockInId {
    return _currentClockInId;
  }

  // return clock user history
  static List<AttendanceHistroy> get getAttendanceHistory {
    return _attendanceHistory;
  }

  // return admin bool
  static bool? get getAdminFlag {
    return _isAdmin ?? false;
  }

  // return user active status
  static bool? get getIsActive {
    return _isActive ?? false;
  }

  // return user deleted status
  static bool? get getIsDeleted {
    return _isDeleted ?? false;
  }
}
