import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasko/utils/utils.dart';

class UserDetail {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? countryISOCode;
  String? countryCode;
  String? phoneNumber;
  String? profileURL;
  bool? status = false;
  bool? isAdmin;
  bool? isActive;
  bool? isDeleted;
  bool? pushNotification;
  bool? emailNotification;
  bool isSelected = false;

  UserDetail(
      this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.countryISOCode,
      this.countryCode,
      this.phoneNumber,
      this.profileURL,
      this.status,
      this.isAdmin,
      this.isActive,
      this.isDeleted,
      this.pushNotification,
      this.emailNotification,
      {this.isSelected = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'countryISOCode': countryISOCode,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'profileUrl': profileURL,
      'status': status,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'pushNotification': pushNotification,
      'emailNotification': emailNotification,
    };
  }

  factory UserDetail.fromMap(Map<String, dynamic> map) {
    return UserDetail(
      map['id'],
      map['firstName'],
      map['lastName'],
      map['email'],
      map['countryIsoCode'] == null ? null : map['countryIsoCode'] as String,
      map['countryCode'] == null ? null : map['countryCode'] as String,
      map['phoneNumber'],
      map['profileUrl'] == null
          ? null
          : getProfileImagePath(map['profileUrl']
              .toString()
              .replaceAll("'", '"')
              .replaceAll('JPEG', 'jpg')
              .replaceAll('WEBP', 'webp')),
      map['status'] == null ? false : map['status'] as bool,
      map['isAdmin'] == null ? false : map['isAdmin'] as bool,
      map['isActive'] == null ? true : map['isActive'] as bool,
      map['isDeleted'] == null ? false : map['isDeleted'] as bool,
      map['pushNotification'] == null ? false : map['pushNotification'] as bool,
      map['emailNotification'] == null
          ? false
          : map['emailNotification'] as bool,
    );
  }

  factory UserDetail.fromJson(String source) =>
      UserDetail.fromMap(json.decode(source) as Map<String, dynamic>);

  static String getProfileImagePath(imageName) {
    return ImageUrlBuilder.getImage(
        'files/users/${FirebaseAuth.instance.currentUser!.uid}/$imageName');
  }
}
