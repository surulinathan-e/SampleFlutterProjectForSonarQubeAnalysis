import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/data/repo/signup_repo.dart';
part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepo signupRepo = SignupRepo();

  SignupBloc() : super(SignupInitial()) {
    on<SignupEvent>((event, emit) async {
      if (event is Signup) {
        emit(SignupLoading());
        try {
          await signupRepo.signupUser(event.email.trim(), event.password.trim(),
              event.firstName.trim(), event.lastName.trim());
          String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
          String firstName = capitalize(event.firstName);
          String lastName = capitalize(event.lastName);
          await signupRepo.createUserDB(
              FirebaseAuth.instance.currentUser!.uid,
              firstName,
              lastName,
              event.email,
              event.countryCode,
              event.countryIsoCode,
              event.phoneNumber,
              event.selectedOrganization ?? '');
          emit(SignupSuccess());
        } catch (error) {
          emit(SignupFailed(error.toString()));
        }
      } else if (event is EmailVerify) {
        emit(EmailVerifyLoading());
        try {
          var response = await signupRepo.emailVerify(event.userId);
          emit(EmailVerifySuccess(response));
        } catch (error) {
          emit(EmailVerifyFailed(error.toString()));
        }
      }
    });
  }
}
