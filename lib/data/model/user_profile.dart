import 'dart:convert';
import 'package:tasko/data/model/organization_user.dart';
import 'package:tasko/utils/utils.dart';

class UserProfile {
  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? countryISOCode;
  String? countryCode;
  String? phoneNumber;
  String? profileUrl;
  bool? status = false;
  bool? isAdmin;
  bool? isActive;
  bool? isDeleted;
  OrganizationUser? organizationUser;

  UserProfile(
      this.userId,
      this.firstName,
      this.lastName,
      this.email,
      this.countryISOCode,
      this.countryCode,
      this.phoneNumber,
      this.profileUrl,
      this.status,
      this.isAdmin,
      this.isActive,
      this.isDeleted,
      this.organizationUser);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'countryISOCode': countryISOCode,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'profileUrl': profileUrl,
      'status': status,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'OrganizationUsers': organizationUser
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      map['id'] == null ? null : map['id'] as String,
      map['firstName'] == null ? null : map['firstName'] as String,
      map['lastName'] == null ? null : map['lastName'] as String,
      map['email'] == null ? null : map['email'] as String,
      map['countryIsoCode'] == null ? null : map['countryIsoCode'] as String,
      map['countryCode'] == null ? null : map['countryCode'] as String,
      map['phoneNumber'] == null ? '' : map['phoneNumber'] as String,
      map['profileUrl'] == null
          ? null
          : getImagePath(
              map['id'],
              map['profileUrl']
                  .toString()
                  .replaceAll("'", '"')
                  .replaceAll('JPEG', 'jpg')
                  .replaceAll('WEBP', 'webp')),
      map['status'] == null ? false : map['status'] as bool,
      map['isAdmin'] == null ? false : map['isAdmin'] as bool,
      map['isActive'] == null ? true : map['isActive'] as bool,
      map['isDeleted'] == null ? false : map['isDeleted'] as bool,
      map['organizationUser'] == null
          ? null
          : OrganizationUser.fromMap(map['organizationUser']),
    );
  }

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  static String getImagePath(userId, imageName) {
    return ImageUrlBuilder.getImage('files/users/$userId/$imageName');
  }
}
