part of 'signup_bloc.dart';

abstract class SignupEvent {}

class Signup extends SignupEvent {
  String email,
      password,
      firstName,
      lastName,
      countryCode,
      countryIsoCode,
      phoneNumber;
  String? selectedOrganization;

  Signup(this.email, this.password, this.firstName, this.lastName,
      this.countryCode, this.countryIsoCode, this.phoneNumber, {this.selectedOrganization});
}

class EmailVerify extends SignupEvent {
  String userId;

  EmailVerify(this.userId);
}
