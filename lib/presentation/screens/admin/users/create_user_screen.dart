import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  //controllers
  TextEditingController? _firstNameController,
      _lastNameController,
      _countryCodeController,
      _phoneNumberController,
      _emailController,
      _passwordController,
      _confirmationPasswordController;

  //focusNode
  FocusNode? _firstNameFocusNode,
      _lastNameFocusNode,
      _countryCodeFocusNode,
      _phoneNumberFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _confirmPasswordFocusNode,
      _submitFocusNode;

  //formKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Obscure
  bool _isPasswordObscure = true, _isConfirmPasswordObscure = true;

  String? _countryISOCode, _countryCode, _phoneNumber;
  String? selectedOrganization;
  List<Organization>? organizations;
  String? userEnteredEmail;

  SignupBloc? registerBloc;

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
    organizations = UserDetailsDataStore.getUserOrganizations!;
    //controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _countryCodeController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmationPasswordController = TextEditingController();
    //focusNodes
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _countryCodeFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _submitFocusNode = FocusNode();

    registerBloc = BlocProvider.of<SignupBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    //controllers
    _firstNameController!.dispose();
    _lastNameController!.dispose();
    _countryCodeController!.dispose();
    _phoneNumberController!.dispose();
    _emailController!.dispose();
    _passwordController!.dispose();
    _confirmationPasswordController!.dispose();

    //focusNodes
    _firstNameFocusNode!.dispose();
    _lastNameFocusNode!.dispose();
    _countryCodeFocusNode!.dispose();
    _phoneNumberFocusNode!.dispose();
    _submitFocusNode!.dispose();
    _emailFocusNode!.dispose();
    _passwordFocusNode!.dispose();
    _confirmPasswordFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = HeightFinder(context).scrHt;
    final double keyboardHeight = HeightFinder(context).kbrdHt;
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: BlocListener<SignupBloc, SignupState>(
        bloc: registerBloc,
        listener: (context, state) {
          if (state is SignupFailed) {
            showAlertSnackBar(context, state.errorMessage, AlertType.error);
          } else if (state is SignupFailed) {
            showAlertSnackBar(context, state.errorMessage, AlertType.error);
          } else if (state is SignupSuccess) {
            showAlertSnackBar(
                context, translation(context).userCreated, AlertType.success);
            _clearTextData();
          }
        },
        child: BlocBuilder<SignupBloc, SignupState>(
          bloc: registerBloc,
          builder: (context, state) {
            return Stack(
              children: [
                // bGMain(),
                SizedBox(
                  height: screenHeight - keyboardHeight,
                  child: SingleChildScrollView(
                    child: _buildBodyContentWidget(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //register form
  Widget _buildBodyContentWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 75.0, bottom: 30.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dashBoardGoBack(() => {Navigator.pop(context)}),
                ],
              ),
            ),
            _buildHeadingsWidget(),
            sizedBoxHeight_20(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  sizedBoxHeight_20(),
                  _buildFirstNameTextWidget(),
                  sizedBoxHeight_10(),
                  _buildLastNameTextWidget(),
                  sizedBoxHeight_10(),
                  _buildEmailTextWidget(),
                  sizedBoxHeight_10(),
                  _buildPhoneNumberTextWidget(),
                  sizedBoxHeight_10(),
                  _buildPasswordTextWidget(),
                  sizedBoxHeight_10(),
                  _buildConfirmPasswordTextWidget(),
                  sizedBoxHeight_10(),
                  _buildOrganizationWidget(),
                  sizedBoxHeight_20(),
                ],
              ),
            ),
            Column(
              children: [
                _buildSubmitButtonWidget(),
                sizedBoxHeight_20(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //heading
  Widget _buildHeadingsWidget() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            translation(context).welcome,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            translation(context).letsStart,
            style: const TextStyle(
              fontSize: 14.0,
              color: darkTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // //first name txt bx
  Widget _buildFirstNameTextWidget() {
    return TextFormField(
      autofocus: true,
      focusNode: _firstNameFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _firstNameController,
      keyboardType: TextInputType.name,
      enableSuggestions: true,
      autocorrect: true,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        prefixIcon: const Icon(
          Icons.verified_user_outlined,
          color: darkTextColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        hintText: translation(context).firstName,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: grayBorderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context).enterFirstName;
        }
        return null;
      },
      onFieldSubmitted: (term) {
        _firstNameFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_lastNameFocusNode);
      },
    );
  }

  // //last name txt bx
  Widget _buildLastNameTextWidget() {
    return TextFormField(
      focusNode: _lastNameFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _lastNameController,
      keyboardType: TextInputType.name,
      enableSuggestions: true,
      autocorrect: true,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        prefixIcon: const Icon(
          Icons.verified_user_outlined,
          color: Colors.black54,
        ),
        hintText: translation(context).lastName,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context).enterLastName;
        }
        return null;
      },
      onFieldSubmitted: (term) {
        _lastNameFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_submitFocusNode);
      },
    );
  }

  //email txt bx
  Widget _buildEmailTextWidget() {
    return TextFormField(
      focusNode: _emailFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enableSuggestions: false,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        prefixIcon: const Icon(
          Icons.mail_outlined,
          color: darkTextColor,
        ),
        hintText: translation(context).eMail,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: grayBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context).entereMail;
        } else if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value)) {
          return translation(context).propereMail;
        }
        userEnteredEmail = value;
        return null;
      },
      onFieldSubmitted: (term) {
        _emailFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
    );
  }

  // //phone number txt bx
  Widget _buildPhoneNumberTextWidget() {
    return IntlPhoneField(
      focusNode: _phoneNumberFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _phoneNumberController,
      onSaved: (value) {
        _countryISOCode = value!.countryISOCode;
        _countryCode = value.countryCode;
        _phoneNumber = value.number;
      },
      keyboardType: TextInputType.phone,
      initialCountryCode: 'GB',
      showDropdownIcon: true,
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonMargin: const EdgeInsets.all(10),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        prefixIcon: const Icon(
          Icons.phone_android_outlined,
          color: Colors.black54,
        ),
        hintText: translation(context).phoneNumber,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: (value) {
        if (value!.number.isEmpty) {
          return translation(context).enterPhoneNumber;
        }
        return null;
      },
    );
  }

  // //password txt bx
  Widget _buildPasswordTextWidget() {
    return TextFormField(
      focusNode: _passwordFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _passwordController,
      obscureText: _isPasswordObscure,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        hintText: translation(context).password,
        errorMaxLines: 2,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: darkTextColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscure
                ? Icons.visibility
                : Icons.visibility_off_outlined,
            color: darkIconColor,
          ),
          onPressed: () {
            setState(() {
              _isPasswordObscure = !_isPasswordObscure;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: grayBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
      ),
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
      },
      onFieldSubmitted: (term) {
        _passwordFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      },
    );
  }

  // //confirm password txt bx
  Widget _buildConfirmPasswordTextWidget() {
    return TextFormField(
      focusNode: _confirmPasswordFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _confirmationPasswordController,
      obscureText: _isConfirmPasswordObscure,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
        hintText: translation(context).confirmPassword,
        errorMaxLines: 2,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: darkTextColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordObscure
                ? Icons.visibility
                : Icons.visibility_off_outlined,
            color: darkIconColor,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: grayBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context).enterConfirmPassword;
        } else if (value != _passwordController!.text) {
          return translation(context).passwordNotMatch;
        }
        return null;
      },
      onFieldSubmitted: (term) {
        _confirmPasswordFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_submitFocusNode);
      },
    );
  }

  Widget _buildOrganizationWidget() {
    return DropdownButtonFormField(
        hint: Text(translation(context).selectOrganisation),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 10, right: 20),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: grayBorderColor, width: 2),
            borderRadius: BorderRadius.circular(25.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: darkBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: darkBorderColor),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) =>
            value == null ? translation(context).selectOrganisation : null,
        dropdownColor: Colors.white,
        value: selectedOrganization,
        onChanged: (String? newValue) {
          setState(() {
            selectedOrganization = newValue!;
          });
        },
        items: organizations!
            .map((organization) => DropdownMenuItem(
                value: '${organization.id}',
                child: Text('${organization.name}')))
            .toList());
  }

  //submit btn
  Widget _buildSubmitButtonWidget() {
    return BlocBuilder(
        bloc: registerBloc,
        builder: (context, state) {
          if (state is SignupLoading) {
            return const Loading();
          }
          // else if (state is CreateDbUserLoading) {
          //   return showCirclularLoading();
          // }
          else {
            return _buildRegisterBtn();
            // }
          }
        });
  }

  //submit btn
  Widget _buildRegisterBtn() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.0),
          )),
      focusNode: _submitFocusNode,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _firstNameFocusNode!.unfocus();
          _lastNameFocusNode!.unfocus();
          _countryCodeFocusNode!.unfocus();
          _phoneNumberFocusNode!.unfocus();
          _emailFocusNode!.unfocus();
          _passwordFocusNode!.unfocus();
          _confirmPasswordFocusNode!.unfocus();

          FocusScope.of(context).requestFocus(_submitFocusNode);
          _formKey.currentState!.save();
          registerBloc!.add(Signup(
              _emailController!.text.trim(),
              _passwordController!.text.trim(),
              _firstNameController!.text.trim(),
              _lastNameController!.text.trim(),
              _countryCode!,
              _countryISOCode!,
              _phoneNumber!,
              selectedOrganization: selectedOrganization!));
        }
      },
      child: Text(
        // 'Register',
        translation(context).create,
        style: TextStyle(
            color: brightTextColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  // clear txt
  void _clearTextData() {
    _firstNameController!.clear();
    _lastNameController!.clear();
    _countryCodeController!.clear();
    _phoneNumberController!.clear();
    _emailController!.clear();
    _passwordController!.clear();
    _confirmationPasswordController!.clear();

    setState(() {
      _countryISOCode = "GB";
      _countryCode = "+44";
      _phoneNumber = null;
      selectedOrganization = null;
    });
  }
}
