import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/forget_password_repo.dart';

part 'forget_password_event.dart';
part 'forget_password_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepo forgetPasswordRepo = ForgetPasswordRepo();
  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    on<ForgetPasswordEvent>((event, emit) async {
      if (event is GetForgetPassword) {
        emit(ForgetPasswordLoading());
        try {
          await forgetPasswordRepo.getForgetPassword(event.email);
          emit(ForgetPasswordSuccess());
        } catch (error) {
          emit(ForgetPasswordFailed(error.toString()));
        }
      }
    });
  }
}
