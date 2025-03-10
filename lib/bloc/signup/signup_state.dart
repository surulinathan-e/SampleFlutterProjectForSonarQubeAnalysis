part of 'signup_bloc.dart';

abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {
  SignupLoading();
}

class SignupSuccess extends SignupState {
  SignupSuccess();
}

class SignupFailed extends SignupState {
  final String errorMessage;
  SignupFailed(this.errorMessage);
}

class EmailVerifyLoading extends SignupState {
  EmailVerifyLoading();
}

class EmailVerifySuccess extends SignupState {
  final dynamic response;
  EmailVerifySuccess(this.response);
}

class EmailVerifyFailed extends SignupState {
  final String errorMessage;
  EmailVerifyFailed(this.errorMessage);
}
