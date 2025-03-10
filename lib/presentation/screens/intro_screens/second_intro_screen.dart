import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/utils/utils.dart';

class SecondIntroScreen extends StatefulWidget {
  const SecondIntroScreen({super.key});

  @override
  State<SecondIntroScreen> createState() => _FirstIntroScreenState();
}

class _FirstIntroScreenState extends State<SecondIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: transparent, body: _buildBody());
  }

  Widget _buildBody() {
    return Stack(children: [
      SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 150.h),
        _buildImage(),
        SizedBox(height: 50.h),
        _buildToolagenLogo(),
        SizedBox(height: 30.h),
        _buildHeading()
      ]))
    ]);
  }

  Widget _buildImage() {
    return Center(
        child: Image.asset('assets/images/collaborate_intro_image.png',
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
                    Text(translation(context).collaborate,
                        style: TextStyle(
                            fontSize: 30.sp, fontWeight: FontWeight.w600)),
                    Text(translation(context).easily,
                        style: TextStyle(
                            fontSize: 30.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 5.h),
                    Text(translation(context).workTogether,
                        softWrap: true,
                        style: TextStyle(
                            overflow: TextOverflow.visible,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400))
                  ]))
            ])));
  }
}
