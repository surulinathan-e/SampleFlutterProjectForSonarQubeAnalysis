part of 'forget_password_bloc.dart';

class ForgetPasswordState {}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordLoading extends ForgetPasswordState {
  ForgetPasswordLoading();
}

class ForgetPasswordSuccess extends ForgetPasswordState {
  ForgetPasswordSuccess();
}

class ForgetPasswordFailed extends ForgetPasswordState {
  final String errorMessage;
  ForgetPasswordFailed(this.errorMessage);
}
