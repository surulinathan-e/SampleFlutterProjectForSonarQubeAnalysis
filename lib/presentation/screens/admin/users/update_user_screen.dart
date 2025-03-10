import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserProfile? user;
  const UpdateUserScreen({super.key, this.user});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  TextEditingController? _firstNameController,
      _lastNameController,
      _countryCodeController,
      _phoneNumberController,
      _emailController;

  //focusNode
  FocusNode? _firstNameFocusNode,
      _lastNameFocusNode,
      _countryCodeFocusNode,
      _phoneNumberFocusNode,
      _emailFocusNode,
      _submitFocusNode;

  bool isProfileUpdated = false;
  bool isCountryCodeChanged = false;

  //formKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AdminBloc? adminBloc;

  String? _countryISOCode, _countryCode, _phoneNumber;

  String? updatedFirstName;
  String? updatedLastName;
  String? updatedPhoneNumber;
  String? updatedCountryCode;
  UserProfile? user;
  bool? isUserActive;
  bool? isUserAdmin;
  bool? updatedUserActive;
  bool? updatedUserAdmin;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    adminBloc = BlocProvider.of<AdminBloc>(context);
    //controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _countryCodeController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    //focusNodes
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _countryCodeFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _submitFocusNode = FocusNode();
    setSelectedUserValue();
  }

  setSelectedUserValue() {
    _firstNameController!.text = user!.firstName!;
    _lastNameController!.text = user!.lastName!;

    _countryCodeController!.text = user!.countryCode ?? '';
    _phoneNumberController!.text = user!.phoneNumber!;

    _emailController!.text = user!.email!;

    _countryISOCode = user!.countryISOCode;
    _countryCode = user!.countryCode ?? '';
    _phoneNumber = user!.phoneNumber!;
    isUserActive = user!.isActive!;
    isUserAdmin = user!.isAdmin!;

    updatedFirstName = _firstNameController!.text;
    updatedLastName = _lastNameController!.text;
    updatedPhoneNumber = _phoneNumberController!.text;
    updatedCountryCode = _countryCode;
    updatedUserActive = isUserActive;
    updatedUserAdmin = isUserAdmin;
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

    //focusNodes
    _firstNameFocusNode!.dispose();
    _lastNameFocusNode!.dispose();
    _countryCodeFocusNode!.dispose();
    _phoneNumberFocusNode!.dispose();
    _submitFocusNode!.dispose();
    _emailFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = HeightFinder(context).scrHt;
    final double keyboardHeight = HeightFinder(context).kbrdHt;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(isProfileUpdated);
          return Future.value();
        },
        child: Scaffold(
            backgroundColor: bgColor,
            resizeToAvoidBottomInset: false,
            body: BlocListener<AdminBloc, AdminState>(
                bloc: adminBloc,
                listener: (context, state) {
                  if (state is UpdateDbUserSuccess) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).userUpdatedSuccess,
                        AlertType.success);
                    isProfileUpdated = true;
                  } else if (state is UpdateDbUserFailed) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  }
                },
                child: BlocBuilder<AdminBloc, AdminState>(
                    bloc: adminBloc,
                    builder: (context, state) {
                      return Stack(children: [
                        bGMainMini(),
                        SizedBox(
                            height: screenHeight - keyboardHeight,
                            child: SingleChildScrollView(
                                child: _buildBodyContentWidget()))
                      ]);
                    }))));
  }

  //login frm
  Widget _buildBodyContentWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: brightBackArrow(() {
                  Navigator.of(context).pop(isProfileUpdated);
                }),
              )),
          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(translation(context).updateUserProfile,
                  style: const TextStyle(
                      color: white,
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold))),
          sizedBoxHeight_20(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                sizedBoxHeight_20(),
                _buildFirstNameWidget(),
                sizedBoxHeight_10(),
                _buildLastNameWidget(),
                sizedBoxHeight_10(),
                _buildPhoneNumberWidget(),
                sizedBoxHeight_10(),
                _buildEmailwidget(),
                Row(
                  children: [
                    Expanded(child: _buildIsActive()),
                    Expanded(child: _buildIsAdmin())
                  ],
                ),
                sizedBoxHeight_20(),
                _buildSubmitBtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //first name txt bx
  Widget _buildFirstNameWidget() {
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
        hintText: translation(context).firstName,
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
          return translation(context).enterFirstName;
        }
        updatedFirstName = value.trim();
        return null;
      },
      onFieldSubmitted: (term) {
        _firstNameFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_lastNameFocusNode);
      },
    );
  }

  //last name txt bx
  Widget _buildLastNameWidget() {
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
          color: darkTextColor,
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
        var enteredValue = value!.trim();
        if (enteredValue.isEmpty) {
          return translation(context).enterLastName;
        }
        updatedLastName = enteredValue;
        return null;
      },
      onFieldSubmitted: (term) {
        _lastNameFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_submitFocusNode);
      },
    );
  }

  //phone number txt bx
  Widget _buildPhoneNumberWidget() {
    return IntlPhoneField(
      focusNode: _phoneNumberFocusNode,
      controller: _phoneNumberController,
      enabled: true,
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        _countryISOCode = value!.countryISOCode;
        _countryCode = value.countryCode;
        _phoneNumber = value.number;

        _countryCodeController!.text = _countryCode!;
        _phoneNumberController!.text = _phoneNumber!;
      },
      keyboardType: TextInputType.phone,
      initialCountryCode: _countryISOCode,
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
      onCountryChanged: (value) {
        isCountryCodeChanged = true;
      },
      validator: (value) {
        updatedPhoneNumber = value!.number;
        updatedCountryCode = value.countryCode;
        String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        RegExp regExp = RegExp(pattern);
        if (value.number.isEmpty) {
          return translation(context).enterPhoneNumber;
        } else if (!regExp.hasMatch(value.toString())) {
          return translation(context).enterPhoneNumber;
        }
        return null;
      },
    );
  }

  //email txt bx
  Widget _buildEmailwidget() {
    return TextFormField(
      focusNode: _emailFocusNode,
      enabled: false,
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
        return null;
      },
      onFieldSubmitted: (term) {
        _emailFocusNode!.unfocus();
      },
    );
  }

  Widget _buildIsActive() {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: primaryColor,
      title: Text(translation(context).isActive),
      value: updatedUserActive,
      onChanged: (value) {
        setState(() {
          updatedUserActive = value!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildIsAdmin() {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: primaryColor,
      title: Text(translation(context).isAdmin),
      value: updatedUserAdmin,
      onChanged: (value) {
        setState(() {
          updatedUserAdmin = value!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  //final submit btn
  Widget _buildSubmitBtn() {
    return BlocBuilder(
        bloc: adminBloc,
        builder: (context, state) {
          if (state is UserDataLoading) {
            return const Loading();
          } else {
            return showSubmitBtn();
          }
        });
  }

  //submit btn
  Widget showSubmitBtn() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.0),
          )),
      focusNode: _submitFocusNode,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (_firstNameController!.text != updatedFirstName ||
            _lastNameController!.text != updatedLastName ||
            _phoneNumber != updatedPhoneNumber ||
            isCountryCodeChanged ||
            isUserAdmin != updatedUserAdmin ||
            isUserActive != updatedUserActive) {
          if (_formKey.currentState!.validate()) {
            progress(context);
            _firstNameFocusNode!.unfocus();
            _lastNameFocusNode!.unfocus();
            _countryCodeFocusNode!.unfocus();
            _phoneNumberFocusNode!.unfocus();
            _emailFocusNode!.unfocus();
            FocusScope.of(context).requestFocus(_submitFocusNode);
            _formKey.currentState!.save();

            String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
            String firstName = capitalize(updatedFirstName!);
            String lastName = capitalize(updatedLastName!);

            adminBloc!.add(UpdateDbUser(
                user!.userId!,
                firstName,
                lastName,
                user!.email!,
                _countryCode!,
                _countryISOCode!,
                _phoneNumber!,
                updatedUserActive!,
                updatedUserAdmin!));
          }
        } else {
          showAlertSnackBar(
              context, translation(context).noUpdateChanges, AlertType.info);
        }
      },
      child: Text(
        translation(context).update,
        style: const TextStyle(
            color: brightTextColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
