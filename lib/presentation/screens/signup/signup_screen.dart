import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController? _firstNameController,
      _lastNameController,
      _emailController,
      _phoneNumberController,
      _passwordController,
      _confirmPasswordController;
  FocusNode? firstnameFocusNode,
      lastnameFocusNode,
      emailFocusNode,
      phoneNumberFocusNode,
      passwordFocusNode,
      confirmPasswordFocusNode;
  SignupBloc? signupBloc;

  bool _isVisible = true;
  bool _isConfirmVisible = true;
  bool _isTermsConditionsAccepted = false;

  String? userEnteredEmail;
  String? _countryISOCode, _countryCode;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegExp passValid = RegExp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)');

  bool validatePassword(String pass) {
    String password = pass.trim();
    if (passValid.hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    firstnameFocusNode = FocusNode();
    lastnameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    phoneNumberFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();

    signupBloc = BlocProvider.of<SignupBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController!.dispose();
    _lastNameController!.dispose();
    _emailController!.dispose();
    _passwordController!.dispose();
    _confirmPasswordController!.dispose();
    firstnameFocusNode!.dispose();
    lastnameFocusNode!.dispose();
    emailFocusNode!.dispose();
    passwordFocusNode!.dispose();
    confirmPasswordFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<SignupBloc, SignupState>(
            bloc: signupBloc,
            listener: (context, state) {
              if (state is SignupSuccess) {
                showAlertSnackBar(context, translation(context).accountCreated,
                    AlertType.success);
                Navigator.pushReplacementNamed(
                    context, PageName.emailVerificationScreen,
                    arguments: userEnteredEmail!);
                clearTextData();
              } else if (state is SignupFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<SignupBloc, SignupState>(
                bloc: signupBloc,
                builder: (context, state) {
                  if (state is SignupLoading) {
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
                        _buildSignupMain()
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

  Widget _buildSignupMain() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildSignupImage(),
              SizedBox(height: 20.h),
              _buildSignupText(),
              SizedBox(height: 20.h),
              _buildLabelText(translation(context).firstName),
              SizedBox(height: 5.h),
              _buildFirstNameTextBox(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).lastName),
              SizedBox(height: 5.h),
              _buildLastNameTextBox(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).email),
              SizedBox(height: 5.h),
              _buildEmailTextBox(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).phoneNumber),
              SizedBox(height: 5.h),
              _buildPhoneNumberWidget(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).password),
              SizedBox(height: 5.h),
              _buildPasswordTextBox(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).confirmPassword),
              SizedBox(height: 5.h),
              _buildConfirmPasswordTextBox(),
              const SizedBox(height: 20),
              _buildSignInTermsAndConditions(),
              SizedBox(height: 20.h),
              _buildContinueButton(),
              SizedBox(height: 30.h)
            ])));
  }

  Widget _buildSignupImage() {
    return Center(
        child: Image.asset('assets/images/login_image.png',
            height: 150.h, width: 150.w));
  }

  Widget _buildLabelText(text) {
    return Text(text,
        textAlign: TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildSignupText() {
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
                Text(translation(context).register,
                    style: TextStyle(
                        fontSize: 24.sp, fontWeight: FontWeight.bold)),
                Text(translation(context).everythingYouNeed,
                    softWrap: true,
                    style: TextStyle(
                        color: lightTextColor,
                        overflow: TextOverflow.visible,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500))
              ]))
        ]));
  }

  Widget _buildFirstNameTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        focusNode: firstnameFocusNode,
        cursorColor: lightTextColor,
        controller: _firstNameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/user_icon.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            hintText: translation(context).firstName,
            hintStyle: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp)),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterFirstName;
          }
          return null;
        });
  }

  Widget _buildLastNameTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        focusNode: lastnameFocusNode,
        cursorColor: lightTextColor,
        controller: _lastNameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/user_icon.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            hintText: translation(context).lastName,
            hintStyle: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp)),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterLastName;
          }
          return null;
        });
  }

  Widget _buildEmailTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        focusNode: emailFocusNode,
        cursorColor: lightTextColor,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/email.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            hintText: translation(context).emailAddress,
            hintStyle: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp)),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterEmail;
          } else if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return translation(context).validEmail;
          }
          userEnteredEmail = value;
          return null;
        });
  }

  //phone number txt bx
  Widget _buildPhoneNumberWidget() {
    return IntlPhoneField(
      style: TextStyle(
          color: lightTextColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 12.sp),
      focusNode: phoneNumberFocusNode,
      controller: _phoneNumberController,
      enabled: true,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          _countryISOCode = value.countryISOCode;
          _countryCode = value.countryCode;
        });
      },
      keyboardType: TextInputType.phone,
      initialCountryCode: _countryISOCode ?? 'GB',
      showDropdownIcon: true,
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonMargin: const EdgeInsets.all(10),
      decoration: InputDecoration(
        hintStyle: TextStyle(
            color: lightTextColor.withValues(alpha: .5),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp),
        fillColor: white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        prefixIcon: const Icon(
          Icons.phone_android_outlined,
          color: Colors.black54,
        ),
        hintText: translation(context).phoneNumber,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(width: 1.w)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
                color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
      ),
      validator: (value) {
        String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        RegExp regExp = RegExp(pattern);
        if (value!.number.isEmpty) {
          return translation(context).enterPhoneNumber;
        } else if (!regExp.hasMatch(value.toString())) {
          return translation(context).enterPhoneNumber;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        focusNode: passwordFocusNode,
        cursorColor: lightTextColor,
        controller: _passwordController,
        obscureText: _isVisible,
        style: TextStyle(
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/password_lock.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            hintText: translation(context).password,
            errorMaxLines: 2,
            hintStyle: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp),
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
          String enteredPassword = value!.trim();
          if (enteredPassword.isEmpty) {
            return translation(context).enterPassword;
          } else {
            bool result = validatePassword(value);
            if (result) {
              return null;
            } else {
              return translation(context).passwordContains;
            }
          }
        });
  }

  Widget _buildConfirmPasswordTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        focusNode: confirmPasswordFocusNode,
        cursorColor: lightTextColor,
        controller: _confirmPasswordController,
        obscureText: _isConfirmVisible,
        style: TextStyle(
            color: lightTextColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                    color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/password_lock.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: .5))),
            filled: true,
            fillColor: white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            hintText: translation(context).confirmPassword,
            hintStyle: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp),
            errorMaxLines: 2,
            suffixIcon: IconButton(
                icon: Icon(
                    _isConfirmVisible
                        ? Icons.visibility
                        : Icons.visibility_off_outlined,
                    color: lightTextColor),
                onPressed: () {
                  setState(() {
                    _isConfirmVisible = !_isConfirmVisible;
                  });
                })),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterConfirmPassword;
          } else if (value != _passwordController!.text) {
            return translation(context).passwordNotMatch;
          }
          return null;
        });
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size.fromHeight(40.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            FocusManager.instance.primaryFocus?.unfocus();

            if (_isTermsConditionsAccepted) {
              signupBloc!.add(Signup(
                _emailController!.text.trim(),
                _passwordController!.text.trim(),
                _firstNameController!.text.trim(),
                _lastNameController!.text.trim(),
                _countryCode ?? "+91",
                _countryISOCode ?? "IN",
                _phoneNumberController!.text.trim(),
              ));
            } else {
              showAlertSnackBar(
                  context, translation(context).selectTerms, AlertType.info);
            }
          }
        },
        child: Text(translation(context).createMyAcc,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                color: white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500)));
  }

  Widget _buildSignInTermsAndConditions() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
              activeColor: primaryColor,
              checkColor: white,
              side: BorderSide(
                  color: greyTextColor.withValues(alpha: .5), width: 2.w),
              value: _isTermsConditionsAccepted,
              onChanged: (value) {
                setState(() {
                  _isTermsConditionsAccepted = value!;
                });
              }),
          Expanded(child: _buildTermsAndConditionAndPrivacyPolicy())
        ]);
  }

  Widget _buildTermsAndConditionAndPrivacyPolicy() {
    TextStyle defaultStyle = const TextStyle(
        wordSpacing: 1, height: 1.5, color: greyTextColor, fontSize: 14.0);
    TextStyle linkStyle = const TextStyle(
        height: 1.5,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
        color: primaryColor);
    return RichText(
        text: TextSpan(style: defaultStyle, children: <TextSpan>[
      TextSpan(text: '${translation(context).agreeTo} '),
      TextSpan(
          text: translation(context).termsOfService,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse('https://toolagen.com/terms-conditions/'));
            }),
      TextSpan(text: ' ${translation(context).termsAnd} '),
      TextSpan(
          text: translation(context).privacyPolicy,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse('https://toolagen.com/privacy-policy/'));
            })
    ]));
  }

  void clearTextData() {
    _firstNameController!.clear();
    _lastNameController!.clear();
    _emailController!.clear();
    _passwordController!.clear();
    _confirmPasswordController!.clear();
    _isTermsConditionsAccepted = false;
  }
}
