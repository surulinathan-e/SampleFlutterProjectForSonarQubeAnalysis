part of 'forget_password_bloc.dart';


class ForgetPasswordEvent {}
class GetForgetPassword extends ForgetPasswordEvent {
  final String email;

  GetForgetPassword(this.email);
}