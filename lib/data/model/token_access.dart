
import 'user_detail.dart';

class TokenAccess {
  bool? success;
  String? accessToken;
  String? refreshToken;
  UserDetail? userDetail;

  TokenAccess(
      this.success, this.accessToken, this.refreshToken, this.userDetail);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': userDetail
    };
  }

  factory TokenAccess.fromMap(Map<String, dynamic> map) {
    return TokenAccess(
        map['success'] == null ? null : map['success'] as bool,
        map['accessToken'],
        map['refreshToken'],
        map['user'] == null ? null : UserDetail.fromMap(map['user']));
  }
}
