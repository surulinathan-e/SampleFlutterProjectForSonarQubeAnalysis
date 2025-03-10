import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class LoginEntryScreen extends StatefulWidget {
  const LoginEntryScreen({super.key});

  @override
  State<LoginEntryScreen> createState() => _FirstIntroScreenState();
}

class _FirstIntroScreenState extends State<LoginEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: bgColor, body: _buildBody());
  }

  Widget _buildBody() {
    return Stack(children: [
      bgLogin(),
      SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: 100.h),
          _buildImage(),
          SizedBox(height: 50.h),
          _buildToolagenLogo(),
          SizedBox(height: 30.h),
          _buildHeading(),
          SizedBox(height: 40.h),
          _buildCreateAccountButton(),
          SizedBox(height: 20.h),
          _buildLoginAccountButton()
        ]),
      ))
    ]);
  }

  Widget _buildImage() {
    return Center(
        child: Image.asset('assets/images/productivity_intro_image.png',
            width: 180.w, height: 180.h));
  }

  Widget _buildToolagenLogo() {
    return Padding(
        padding: EdgeInsets.only(left: 40.w),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/images/toolagen_logo_with_name.png',
                width: 200.w)));
  }

  Widget _buildHeading() {
    return Padding(
        padding: EdgeInsets.only(left: 40.w),
        child: Container(
            decoration: const BoxDecoration(
                border:
                    Border(left: BorderSide(color: primaryColor, width: 8))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 10.w),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(translation(context).letsGet,
                        style: TextStyle(
                            fontSize: 30.sp, fontWeight: FontWeight.w600)),
                    Text(translation(context).started,
                        style: TextStyle(
                            fontSize: 30.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 5.h),
                    Text(translation(context).everythingsOnePlace,
                        softWrap: true,
                        style: TextStyle(
                            overflow: TextOverflow.visible,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400))
                  ]))
            ])));
  }

  Widget _buildCreateAccountButton() {
    return Padding(
        padding: EdgeInsets.only(left: 40.w, right: 40.w),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size.fromHeight(40.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.r))),
            onPressed: () {
              Navigator.pushNamed(context, PageName.signupScreen);
            },
            child: Text(translation(context).createAccounts,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500))));
  }

  Widget _buildLoginAccountButton() {
    return Padding(
        padding: EdgeInsets.only(left: 40.w, right: 40.w),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: bgColor,
                foregroundColor: bgColor,
                minimumSize: Size.fromHeight(40.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.r),
                    side: const BorderSide(color: primaryColor, width: 1.0))),
            onPressed: () {
              Navigator.pushNamed(context, PageName.loginScreen);
            },
            child: Text(translation(context).logintoAccount,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500))));
  }
}
