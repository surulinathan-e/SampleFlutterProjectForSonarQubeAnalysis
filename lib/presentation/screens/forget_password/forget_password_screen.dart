import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';

import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ForgetPasswordBloc? forgetPasswordBloc;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    forgetPasswordBloc = BlocProvider.of<ForgetPasswordBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
            bloc: forgetPasswordBloc,
            listener: (context, state) {
              if (state is ForgetPasswordSuccess) {
                showAlertSnackBar(context, translation(context).passwordReset,
                    AlertType.success);
                Navigator.pop(context);
              } else if (state is ForgetPasswordFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                bloc: forgetPasswordBloc,
                builder: (context, state) {
                  if (state is ForgetPasswordLoading) {
                    return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: const Center(child: Loading()));
                  }
                  return Stack(children: [
                    bgLogin(),
                    SingleChildScrollView(
                        child: Column(
                            children: [buildAppBar(), _bodyForgetpassword()]))
                  ]);
                })));
  }

  Widget _bodyForgetpassword() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 50.h),
              _buildImage(),
              SizedBox(height: 50.h),
              _buildHeading(),
              SizedBox(height: 20.h),
              _buildFormLabel(),
              SizedBox(height: 8.h),
              _buildEmailTextBox(),
              SizedBox(height: 40.h),
              _buildSubmitButton()
            ])));
  }

  Widget _buildImage() {
    return Center(
      child: Image.asset('assets/images/forgot_password_image.png',
          width: 200, height: 200),
    );
  }

  Widget _buildHeading() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: primaryColor, width: 8))),
      child: Row(children: [
        SizedBox(width: 10.w),
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                translation(context).forgotPassword,
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5.h),
              Text(translation(context).forgotPasswordMessage,
                  softWrap: true,
                  style: TextStyle(
                      overflow: TextOverflow.visible,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400))
            ]))
      ]),
    );
  }

  Widget _buildFormLabel() {
    return Text(translation(context).email,
        textAlign: TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.w600));
  }

  Widget _buildEmailTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        cursorColor: lightTextColor,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: lightTextColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: Image.asset('assets/images/email.png',
                  width: 11.w, color: lightTextColor.withValues(alpha: .5))),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: greyBorderColor, width: 1.0)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: grayBorderColor, width: 1.0)),
          hintText: translation(context).emailAddress,
          hintStyle: TextStyle(
              fontSize: 12.sp,
              color: lightTextColor.withValues(alpha: .5),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterEmail;
          } else if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return translation(context).validEmail;
          }
          return null;
        });
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size.fromHeight(35.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.r),
            )),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            FocusManager.instance.primaryFocus?.unfocus();

            forgetPasswordBloc!
                .add(GetForgetPassword(_emailController.text.trim()));
          }
        },
        child: Text(
          translation(context).sendCode,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: white, fontSize: 12.sp, fontWeight: FontWeight.w500),
        ));
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
                            color: greyBorderColor))))),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: lightGreyColor,
                  child: buildLanguageSectionWidget(context)))
        ]);
  }
}
