import 'dart:convert';

import 'package:tasko/utils/utils.dart';

class Member {
  String? projectMemberId;
  String? userId;
  String? firstName;
  String? lastName;
  String? profileUrl;
  Member(this.projectMemberId, this.userId, this.firstName, this.lastName,
      this.profileUrl);

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      map['projectMemberId'],
      map['userId'],
      map['firstName'],
      map['lastName'],
      map['profileUrl'] == null
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
      'projectMemberId': projectMemberId,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'profileUrl': profileUrl,
    };
  }

  String toJson() => json.encode(toMap());

  factory Member.fromJson(String source) => Member.fromMap(json.decode(source));

  static String getProfileImagePath(userId, imageName) {
    return ImageUrlBuilder.getImage('files/users/$userId/$imageName');
  }
}
