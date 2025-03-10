import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/app_config.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class EmailOTPVerifyScreen extends StatefulWidget {
  //final UserDetail? userDetail;

  const EmailOTPVerifyScreen({
    super.key,
    //required this.userDetail
  });

  @override
  State<EmailOTPVerifyScreen> createState() => _EmailOTPVerifyScreenState();
}

class _EmailOTPVerifyScreenState extends State<EmailOTPVerifyScreen> {
  // var otpController = List.generate(6, (index) => TextEditingController());

  String? emailOtp = '';
  LoginBloc? loginBloc;
  AppConfig? appConfigDetail;

  @override
  void initState() {
    loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: MultiBlocListener(
            listeners: [
              BlocListener<LoginBloc, LoginState>(
                  bloc: loginBloc,
                  listener: (context, state) async {
                    if (state is ValidateOTPSuccess) {
                      setLoggedIn();
                      // showAlertSnackBar(context, 'Login successful', AlertType.success);
                      Navigator.pushReplacementNamed(
                          context, PageName.taskListScreen);
                    } else if (state is ValidateOTPFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is ResendOTPSuccess) {
                      showAlertSnackBar(
                          context,
                          translation(context).resendOtpSuccess,
                          AlertType.success);
                    } else if (state is ResendOTPFailed) {
                      showAlertSnackBar(
                          context,
                          translation(context).resendOtpFailed,
                          AlertType.error);
                    }
                  })
            ],
            child: BlocBuilder<LoginBloc, LoginState>(
                bloc: loginBloc,
                builder: (context, state) {
                  if (state is ValidateOTPLoading ||
                      state is ResendOTPLoading) {
                    return const Loading();
                  } else {
                    return Stack(children: [
                      Stack(children: [
                        bgLogin(),
                        SingleChildScrollView(
                            child: Column(children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child: buildAppBar(),
                          ),
                          _buildOTPVerficationDetail()
                        ]))
                      ])
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

  Widget _buildOTPText() {
    return Container(
        decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: primaryColor, width: 8))),
        child: Row(children: [
          SizedBox(width: 10.w),
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(translation(context).otpVerification,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w600)),
                Text(translation(context).checkYourEmailForOTP,
                    softWrap: true,
                    style: TextStyle(
                        color: lightTextColor,
                        overflow: TextOverflow.visible,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500))
              ]))
        ]));
  }

  Widget _buildOTPImage() {
    return Center(
        child: Image.asset('assets/images/login_image.png',
            height: 150.h, width: 150.w));
  }

  Widget _buildOTPVerficationDetail() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(children: [
        _buildOTPImage(),
        const SizedBox(height: 20),
        _buildOTPText(),
        const SizedBox(height: 30),
        Text(translation(context).otpVerifyDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: black, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(translation(context).otpSentTo,
            //${widget.userDetail!.email}',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: black, fontSize: 12.sp, fontWeight: FontWeight.w400)),
        const SizedBox(height: 30),
        _buildOTPField(),
        const SizedBox(height: 30),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor:
                    emailOtp!.length == 6 ? primaryColor : greyBgColor,
                minimumSize: Size.fromHeight(40.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40.r)),
                    side: const BorderSide(color: transparent))),
            onPressed: () async {
              // if (emailOtp!.isNotEmpty && emailOtp!.length == 6) {
              //   loginBloc!.add(ValidateOTP(widget.userDetail!.id!, emailOtp!));
              // }
            },
            child: Text(translation(context).validate,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        InkWell(
            onTap: () {
              // emailOtp = '';
              // // for (int i = 0; i < 6; i++) {
              // //  otpController[i].clear();
              // // }
              // loginBloc!.add(ResendEmailOTP(widget.userDetail!.id!));
            },
            child: RichText(
                text: TextSpan(
                    text: translation(context).otpNotRecieved,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: black),
                    children: [
                      TextSpan(
                          text: translation(context).resendOtp,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor))
                    ]),
                maxLines: 2,
                softWrap: true))
      ]),
    );
  }

  Widget _buildOTPField() {
    return TextField(
        keyboardType: TextInputType.number,
        cursorColor: greyTextColor,
        maxLength: 6,
        onChanged: (value) {
          setState(() {
            emailOtp = value;
          });
        },
        style: const TextStyle(
            letterSpacing: 15.0,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: greyTextColor),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            filled: true,
            fillColor: white,
            counterText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 2.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 2.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 2.w))));
  }
}
