part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class Login extends LoginEvent {
  final String email, password;

  Login(this.email, this.password);
}

class ValidateOTP extends LoginEvent {
  final String userId;
  final String otp;
  ValidateOTP(this.userId, this.otp);
}

class ResendEmailOTP extends LoginEvent {
  final String userId;
  ResendEmailOTP(this.userId);
}
