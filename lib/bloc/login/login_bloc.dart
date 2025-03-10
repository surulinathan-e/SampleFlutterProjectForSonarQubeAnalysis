import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/data/model/token_access.dart';
import 'package:tasko/data/repo/login_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo loginRepo = LoginRepo();

  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      if (event is Login) {
        emit(LoginLoading());
        try {
          String? platform;
          if (Platform.isAndroid) {
            platform = 'android';
          } else if (Platform.isIOS) {
            platform = 'ios';
          }
          final firebaseMessaging = FirebaseMessaging.instance;
          await loginRepo.loginUser(event.email.trim(), event.password.trim());
          final prefs = await SharedPreferences.getInstance();

          var fcmToken = await firebaseMessaging.getToken();

          TokenAccess user = await loginRepo.getAccessToken(
              FirebaseAuth.instance.currentUser!.uid, fcmToken!, platform!);
          var authToken = user.accessToken;
          var refreshToken = user.refreshToken;
          await prefs.setString('accessToken', authToken!);
          await prefs.setString('refreshToken', refreshToken!);

          if (user.userDetail != null) {
            await prefs.setBool('isLoggedIn', true);
            await prefs.setBool('userRegister', true);
          }
          emit(LoginSuccess(user));
        } catch (error) {
          emit(LoginFailed(error.toString()));
        }
      } else if (event is ValidateOTP) {
        emit(ValidateOTPLoading());
        try {
          await loginRepo.validateOTP(event.userId, event.otp);
          emit(ValidateOTPSuccess());
        } catch (error) {
          emit(ValidateOTPFailed(error.toString()));
        }
      } else if (event is ResendEmailOTP) {
        emit(ResendOTPLoading());
        try {
          await loginRepo.resendOTP(event.userId);
          emit(ResendOTPSuccess());
        } catch (error) {
          emit(ResendOTPFailed(error.toString()));
        }
      }
    });
  }
}
