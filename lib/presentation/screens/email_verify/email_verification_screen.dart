import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userEmail;
  const EmailVerificationScreen({super.key, required this.userEmail});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  SignupBloc? signupBloc;
  String? userId;

  @override
  void initState() {
    super.initState();
    signupBloc = BlocProvider.of<SignupBloc>(context);
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<SignupBloc, SignupState>(
            bloc: signupBloc,
            listener: (context, state) {
              if (state is EmailVerifySuccess) {
                showAlertSnackBar(context, translation(context).emailVerifySent,
                    AlertType.success);
              } else if (state is EmailVerifyFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<SignupBloc, SignupState>(
                bloc: signupBloc,
                builder: (context, state) {
                  if (state is EmailVerifyLoading) {
                    return const Loading();
                  } else {
                    return Stack(children: [
                      bgLogin(),
                      SingleChildScrollView(
                          child: Column(children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          child: buildAppBar(),
                        ),
                        _buildEmailVerifyMain()
                      ]))
                    ]);
                  }
                })));
  }

  Widget buildAppBar() {
    return AppBar(
        backgroundColor: transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 3),
                child: CircleAvatar(
                    radius: 25.r,
                    backgroundColor: lightGreyColor,
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: const Icon(Icons.arrow_back_ios,
                            color: greyIconColor))))),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: lightGreyColor,
                  child: buildLanguageSectionWidget(context)))
        ]);
  }

  Widget _buildEmailVerifyMain() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(left: 30.w, right: 30.w),
          child: Column(children: [
            _buildEmailVerifyImage(),
            SizedBox(height: 20.h),
            _buildEmailVerifyText(),
            _buildVerifyMessage(),
            _buildResentEmailHeading(),
            _buildWrongEmailInformation(),
            SizedBox(height: 20.h),
            _buildLoginButton(),
            SizedBox(height: 20.h)
          ]))
    ]);
  }

  Widget _buildEmailVerifyImage() {
    return Center(
        child: Image.asset('assets/images/login_image.png',
            height: 150.h, width: 150.w));
  }

  Widget _buildEmailVerifyText() {
    return Container(
        decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: primaryColor, width: 8))),
        child: Row(children: [
          SizedBox(width: 8.h),
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(translation(context).verifyEmail,
                    style: TextStyle(
                        fontSize: 24.sp, fontWeight: FontWeight.bold)),
                Text(translation(context).checkYourEmailAuthorize,
                    softWrap: true,
                    style: TextStyle(
                        color: lightTextColor,
                        overflow: TextOverflow.visible,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500))
              ]))
        ]));
  }

  Widget _buildVerifyMessage() {
    return Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${translation(context).clickVerifyButton} ${widget.userEmail}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontSize: 14.sp)),
              SizedBox(height: 30.h),
              Text(translation(context).noEmailInSpam,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontSize: 14.sp))
            ]));
  }

  Widget _buildResentEmailHeading() {
    return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: InkWell(
            onTap: () {
              signupBloc!.add(EmailVerify(userId!));
            },
            child: Text(translation(context).resendVerifyEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor,
                    decorationThickness: 1.w,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    fontSize: 20.sp))));
  }

  Widget _buildWrongEmailInformation() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 20.h),
      Text(translation(context).verifyEmailNote,
          textAlign: TextAlign.justify,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: black,
              fontSize: 14.sp,
              fontFamily: 'Poppins'))
    ]);
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size.fromHeight(40.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r))),
        onPressed: () async {
          Navigator.pop(context);
        },
        child: Text(
            translation(context).goToLogin,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                color: white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold)));
  }
}
