import 'dart:convert';

import 'package:tasko/utils/utils.dart';

class Owner {
  String? userId;
  String? firstName;
  String? lastName;
  String? profileUrl;

  Owner({this.userId, this.firstName, this.lastName, this.profileUrl});

  factory Owner.fromMap(Map<String, dynamic> map) {
    return Owner(
      userId: map['userId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileUrl: map['profileUrl'] == null
          ? null
          : getProfileImagePath(
              map['userId'],
              map['profileUrl']
                  .toString()
                  .replaceAll("'", '"')
                  .replaceAll('JPEG', 'jpg')
                  .replaceAll('WEBP', 'webp')),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'profileUrl': profileUrl,
    };
  }

  factory Owner.fromJson(String source) =>
      Owner.fromMap(json.decode(source) as Map<String, dynamic>);

  static String getProfileImagePath(userId, imageName) {
    return ImageUrlBuilder.getImage('files/users/$userId/$imageName');
  }
}
