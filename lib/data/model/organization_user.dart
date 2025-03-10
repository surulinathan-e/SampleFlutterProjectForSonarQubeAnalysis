import 'package:tasko/data/model/user_profile.dart';

class OrganizationUser {
  String? id;
  String? organizationId;
  String? userId;
  bool? isDeleted;
  UserProfile? user;

  OrganizationUser(
      this.id,
      this.organizationId,
      this.userId,
      this.isDeleted,
      this.user);

  factory OrganizationUser.fromMap(Map<String, dynamic> map) {
    return OrganizationUser(
        map['organizationUsersId'] == null ? null : map['organizationUsersId'] as String,
        map['organizationId'] == null ? null : map['organizationId'] as String,
        map['userId'] == null ? null : map['userId'] as String,
        map['isDeleted'] == null ? true : map['isDeleted'] as bool,
        map['user'] == null ? null : UserProfile.fromMap(map['user'])
        );
  }
}
