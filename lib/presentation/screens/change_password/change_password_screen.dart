import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  //controllers
  TextEditingController? _currentPasswordController,
      _newPasswordController,
      _confirmationPasswordController;
  UserBloc? userBloc;

  //focusNode
  FocusNode? _currentPasswordFocusNode,
      _newPasswordFocusNode,
      _confirmPasswordFocusNode,
      _submitFocusNode;

  //formKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Obscure
  bool _isCurrentPasswordObscure = true,
      _isNewPasswordObscure = true,
      _isConfirmPasswordObscure = true;

  @override
  void initState() {
    super.initState();
    //controllers
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmationPasswordController = TextEditingController();
    //focusNodes
    _currentPasswordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _submitFocusNode = FocusNode();
    userBloc = BlocProvider.of<UserBloc>(context);
  }

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
  void dispose() {
    super.dispose();
    //controllers
    _currentPasswordController!.dispose();
    _newPasswordController!.dispose();
    _confirmationPasswordController!.dispose();

    //focusNodes
    _submitFocusNode!.dispose();
    _currentPasswordFocusNode!.dispose();
    _newPasswordFocusNode!.dispose();
    _confirmPasswordFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: Stack(children: [
          BlocListener<UserBloc, UserState>(
              bloc: userBloc,
              listener: (context, state) {
                if (state is ChangePasswordFailed) {
                  if (mounted) {
                    if (ModalRoute.of(context)?.isCurrent != true) {
                      Navigator.of(context).pop();
                    }
                    showAlertSnackBar(
                        context, state.errorMessage!, AlertType.error);
                  }
                } else if (state is ChangePasswordSuccess) {
                  showAlertSnackBar(
                      context,
                      translation(context).passwordChangeSuccess,
                      AlertType.success);
                  Navigator.pop(context);
                  _clearTextData();
                }
              },
              child: BlocBuilder<UserBloc, UserState>(
                  bloc: userBloc,
                  builder: (context, state) {
                    return Stack(children: [
                      bgLogin(),
                      SingleChildScrollView(
                          child: Column(children: [
                        buildAppBar(),
                        _buildBodyContentWidget()
                      ]))
                    ]);
                  }))
        ]));
  }

  Widget _buildBodyContentWidget() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildChangePasswordImage(),
              SizedBox(height: 10.h),
              _buildChangePasswordText(),
              const SizedBox(height: 40),
              _buildLabelText(translation(context).currentPassword),
              SizedBox(height: 5.h),
              _buildCurrentPasswordTextWidget(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).newPassword),
              SizedBox(height: 5.h),
              _buildNewPasswordTextWidget(),
              const SizedBox(height: 10),
              _buildLabelText(translation(context).confirmPassword),
              SizedBox(height: 5.h),
              _buildConfirmPasswordTextWidget(),
              const SizedBox(height: 40),
              _buildSubmitButtonWidget()
            ])));
  }

  Widget _buildChangePasswordImage() {
    return Center(
        child: Image.asset('assets/images/login_image.png',
            height: 150.h, width: 150.w));
  }

  Widget _buildLabelText(text) {
    return Text(text,
        textAlign: TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildChangePasswordText() {
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
                Text(translation(context).changePassword,
                    style: TextStyle(
                        fontSize: 24.sp, fontWeight: FontWeight.bold)),
                Text(translation(context).changePasswordMessage,
                    softWrap: true,
                    style: TextStyle(
                        color: lightTextColor,
                        overflow: TextOverflow.visible,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500))
              ]))
        ]));
  }

  Widget _buildCurrentPasswordTextWidget() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        cursorColor: lightTextColor,
        controller: _currentPasswordController,
        focusNode: _currentPasswordFocusNode,
        obscureText: _isCurrentPasswordObscure,
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
                    color: greyBorderColor.withValues(alpha: 0.2), width: 2.w)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: greyBorderColor, width: 2.w)),
            prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Image.asset('assets/images/password_lock.png',
                    width: 11.w, color: lightTextColor.withValues(alpha: 0.5))),
            filled: true,
            fillColor: white,
            errorMaxLines: 2,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            hintText: translation(context).currentPassword,
            hintStyle: TextStyle(
                fontSize: 12.sp,
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            suffixIcon: IconButton(
                icon: Icon(
                    _isCurrentPasswordObscure
                        ? Icons.visibility
                        : Icons.visibility_off_outlined,
                    color: lightTextColor),
                onPressed: () {
                  setState(() {
                    _isCurrentPasswordObscure = !_isCurrentPasswordObscure;
                  });
                })),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterCurrentPassword;
          }
          return value.length < 6
              ? translation(context).currentPasswordMust
              : null;
        },
        onFieldSubmitted: (term) {
          _currentPasswordFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_newPasswordFocusNode);
        });
  }

  Widget _buildNewPasswordTextWidget() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        cursorColor: lightTextColor,
        controller: _newPasswordController,
        focusNode: _newPasswordFocusNode,
        obscureText: _isNewPasswordObscure,
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
            errorMaxLines: 2,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            hintText: translation(context).newPassword,
            hintStyle: TextStyle(
                fontSize: 12.sp,
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            suffixIcon: IconButton(
                icon: Icon(
                    _isNewPasswordObscure
                        ? Icons.visibility
                        : Icons.visibility_off_outlined,
                    color: lightTextColor),
                onPressed: () {
                  setState(() {
                    _isNewPasswordObscure = !_isNewPasswordObscure;
                  });
                })),
        validator: (value) {
          var enteredPassword = value!.trim();
          if (enteredPassword.isEmpty) {
            return translation(context).enterNewPassword;
          } else {
            bool result = validatePassword(value);
            if (result) {
              return null;
            } else {
              return translation(context).newPasswordMust;
            }
          }
        },
        onFieldSubmitted: (term) {
          _newPasswordFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        });
  }

  Widget _buildConfirmPasswordTextWidget() {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      cursorColor: lightTextColor,
      controller: _confirmationPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: _isConfirmPasswordObscure,
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
          errorMaxLines: 2,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          hintText: translation(context).confirmPassword,
          hintStyle: TextStyle(
              fontSize: 12.sp,
              color: lightTextColor.withValues(alpha: .5),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500),
          suffixIcon: IconButton(
              icon: Icon(
                  _isConfirmPasswordObscure
                      ? Icons.visibility
                      : Icons.visibility_off_outlined,
                  color: lightTextColor),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                });
              })),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context).enterConfirmPassword;
        } else if (value != _newPasswordController!.text) {
          return translation(context).newPasswordNotMatch;
        } else {
          return null;
        }
      },
      onFieldSubmitted: (term) {
        _confirmPasswordFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_submitFocusNode);
      },
    );
  }

  Widget _buildSubmitButtonWidget() {
    return BlocBuilder(
        bloc: userBloc,
        builder: (context, state) {
          if (state is ChangePasswordLoading) {
            return const Loading();
          } else {
            return _buildSubmitButton();
          }
        });
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size.fromHeight(40.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _currentPasswordFocusNode!.unfocus();
            _newPasswordFocusNode!.unfocus();
            _confirmPasswordFocusNode!.unfocus();

            FocusScope.of(context).requestFocus(_submitFocusNode);
            FocusManager.instance.primaryFocus?.unfocus();

            _formKey.currentState!.save();
            userBloc!.add(ChangePasswordEvent(
                currentPassword: _currentPasswordController!.text,
                newPassword: _newPasswordController!.text));
          }
        },
        child: Text(
          translation(context).changePassword,
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

  void _clearTextData() {
    _currentPasswordController!.clear();
    _newPasswordController!.clear();
    _confirmationPasswordController!.clear();
  }
}
