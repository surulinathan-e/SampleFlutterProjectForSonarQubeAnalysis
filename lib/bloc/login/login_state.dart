part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {
  LoginLoading();
}

class LoginSuccess extends LoginState {
  final TokenAccess userDetails;
  LoginSuccess(this.userDetails);
}

class LoginFailed extends LoginState {
  final String errorMessage;
  LoginFailed(this.errorMessage);
}

class ValidateOTPLoading extends LoginState {
  ValidateOTPLoading();
}

class ValidateOTPSuccess extends LoginState {
  ValidateOTPSuccess();
}

class ValidateOTPFailed extends LoginState {
  final String errorMessage;
  ValidateOTPFailed(this.errorMessage);
}

class ResendOTPLoading extends LoginState {
  ResendOTPLoading();
}

class ResendOTPSuccess extends LoginState {
  ResendOTPSuccess();
}

class ResendOTPFailed extends LoginState {
  final String errorMessage;
  ResendOTPFailed(this.errorMessage);
}