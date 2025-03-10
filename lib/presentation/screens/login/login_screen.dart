import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController? _emailController, _passwordController;
  FocusNode? emailFocusNode, passwordFocusNode;
  LoginBloc? loginBloc;

  bool _isVisible = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController!.dispose();
    _passwordController!.dispose();
    emailFocusNode!.dispose();
    passwordFocusNode!.dispose();
  }

  setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<LoginBloc, LoginState>(
            bloc: loginBloc,
            listener: (_, state) async {
              if (state is LoginSuccess) {
                clearTextData();
                setLoggedIn();
                showAlertSnackBar(context, translation(context).loginSuccess,
                    AlertType.success);
                // Navigator.pushReplacementNamed(
                //     context, PageName.emailOTPVerificationScreen,
                //     arguments: state.userDetails.userDetail);
                Navigator.pushReplacementNamed(
                    context, PageName.organizationSelectionScreen);
              } else if (state is LoginFailed) {
                String errMsg = state.errorMessage.toString();
                if (errMsg == 'Email not verified') {
                  showAlertSnackBar(context, translation(context).verifyEmail,
                      AlertType.error);
                  Navigator.pushNamed(context, PageName.emailVerificationScreen,
                      arguments: _emailController!.text.trim());
                } else {
                  showAlertSnackBar(
                      context, state.errorMessage, AlertType.error);
                }
              }
            },
            child: BlocBuilder<LoginBloc, LoginState>(
                bloc: loginBloc,
                builder: (context, state) {
                  if (state is LoginLoading) {
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
                        _buildBody()
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
              Navigator.pushNamed(context, PageName.loginEntryScreen);
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
          SizedBox(width: 5.h),
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: lightGreyColor,
                  child: buildLanguageSectionWidget(context)))
        ]);
  }

  Widget _buildBody() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLoginImage(),
              SizedBox(height: 20.h),
              _buildLoginText(),
              SizedBox(height: 20.h),
              _buildLabelText(translation(context).email),
              SizedBox(height: 5.h),
              _buildEmailTextBox(),
              SizedBox(height: 10.h),
              _buildLabelText(translation(context).password),
              SizedBox(height: 5.h),
              _buildPasswordTextBox(),
              SizedBox(height: 10.h),
              _buildForgetPassword(),
              SizedBox(height: 30.h),
              _buildLoginButton(),
              SizedBox(height: 30.h),
              signPageNavigation(),
              SizedBox(height: 30.h)
            ])));
  }

  Widget _buildLoginText() {
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
                Text(translation(context).loginHeading,
                    style: TextStyle(
                        fontSize: 30.sp, fontWeight: FontWeight.w600)),
                Text(translation(context).loginToContinue,
                    softWrap: true,
                    style: TextStyle(
                        color: lightTextColor,
                        overflow: TextOverflow.visible,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500))
              ]))
        ]));
  }

  Widget _buildForgetPassword() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, PageName.forgetPasswordScreen,
                    arguments: true);
              },
              child: Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Text(translation(context).forgotPassword,
                      style: TextStyle(
                          color: black.withValues(alpha: .7),
                          fontWeight: FontWeight.w600))))
        ]);
  }

  Widget _buildLoginImage() {
    return Center(
        child: Image.asset('assets/images/login_image.png',
            height: 150.h, width: 150.w));
  }

  Widget _buildLabelText(text) {
    return Text(text,
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
        focusNode: emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
            fontSize: 12.sp,
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 2.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 2.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 2.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/email.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            hintText: translation(context).emailAddress,
            hintStyle: TextStyle(
                fontSize: 12.sp,
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500)),
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

  Widget _buildPasswordTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        cursorColor: lightTextColor,
        controller: _passwordController,
        focusNode: passwordFocusNode,
        obscureText: _isVisible,
        style: TextStyle(
            fontSize: 12.sp,
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 2.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 2.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 2.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/password_lock.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            hintText: translation(context).password,
            hintStyle: TextStyle(
                fontSize: 12.sp,
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            suffixIcon: IconButton(
                icon: Icon(
                    _isVisible
                        ? Icons.visibility
                        : Icons.visibility_off_outlined,
                    color: lightTextColor),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                })),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterPassword;
          }
          return null;
        });
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size.fromHeight(40.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            emailFocusNode!.unfocus();
            passwordFocusNode!.unfocus();
            loginBloc!
                .add(Login(_emailController!.text, _passwordController!.text));
          }
        },
        child: Text(translation(context).loginHeading,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                color: white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500)));
  }

  Widget signPageNavigation() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(translation(context).dontHaveAnAccount,
          style: TextStyle(
              fontSize: 12.sp,
              color: greyTextColor,
              fontWeight: FontWeight.w500)),
      SizedBox(height: 15.h),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: bgColor,
              elevation: 0,
              minimumSize: Size.fromHeight(40.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.r),
                  side: const BorderSide(color: primaryColor, width: 1.0))),
          onPressed: () async {
            Navigator.pushNamed(context, PageName.signupScreen);
          },
          child: Center(
              child: Text(translation(context).signupButton,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.bold))))
    ]);
  }

  void clearTextData() {
    _emailController!.clear();
    _passwordController!.clear();
  }
}
