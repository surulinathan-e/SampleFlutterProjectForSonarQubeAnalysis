import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  //controllers
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

  UserBloc? userBloc;

  String? _countryISOCode, _countryCode, _phoneNumber;

  String? updatedFirstName;
  String? updatedLastName;
  String? updatedPhoneNumber;
  String? updatedCountryCode;
  String? updatedCountryISOCode;
  final ImagePicker imagePicker = ImagePicker();
  File? userProfilePic;
  Future getImageFromGallery() async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        userProfilePic = File(pickedImage.path);
      });
    }
  }

  Future getImageFromCamera() async {
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    await processPickedImage(pickedImage);
  }

  processPickedImage(pickedImage) async {
    var croppedFile = await cropImage(pickedImage);
    setState(() {
      if (croppedFile != null) {
        setState(() {
          userProfilePic = File(croppedFile.path);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    userBloc = BlocProvider.of<UserBloc>(context);
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
    setValue();
  }

  setValue() {
    _firstNameController!.text = UserDetailsDataStore.getUserFirstName!;
    _lastNameController!.text = UserDetailsDataStore.getUserLastName!;
    _countryCodeController!.text = UserDetailsDataStore.getUserCountryCode!;
    _phoneNumberController!.text = UserDetailsDataStore.getUserPhoneNumber!;

    _emailController!.text = UserDetailsDataStore.getUserEmail!;

    _countryISOCode = UserDetailsDataStore.getUserCountryISOCode;
    _countryCode = UserDetailsDataStore.getUserCountryCode!;
    _phoneNumber = UserDetailsDataStore.getUserPhoneNumber!;

    updatedFirstName = _firstNameController!.text;
    updatedLastName = _lastNameController!.text;
    updatedPhoneNumber = _phoneNumberController!.text;
    updatedCountryCode = _countryCode;
    updatedCountryISOCode = _countryISOCode;
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
            body: BlocListener<UserBloc, UserState>(
                bloc: userBloc,
                listener: (context, state) {
                  if (state is UserError) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAlertSnackBar(
                          context, state.errorMessage!, AlertType.error);
                    }
                  } else if (state is UpdateProfileSuccessState) {
                    showAlertSnackBar(
                        context,
                        translation(context).profileUpdateSuccess,
                        AlertType.success);
                    Navigator.of(context).pop();
                  } else if (state is UpdateProfileFailedState) {
                    showAlertSnackBar(
                        context, state.errorMessage!, AlertType.error);
                  }
                },
                child: BlocBuilder<UserBloc, UserState>(
                    bloc: userBloc,
                    builder: (context, state) {
                      return Stack(children: [
                        bGMainMini(),
                        _buildBodyContentWidget(keyboardHeight)
                      ]);
                    }))));
  }

  //login frm
  Widget _buildBodyContentWidget(keyboardHeight) {
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
            child: Text(
              translation(context).updateProfile,
              style: TextStyle(
                  color: white,
                  fontSize: 24.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600),
            ),
          ),
          sizedBoxHeight_20(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Center(
                        child: Stack(children: [
                      InkWell(
                          onTap: () {
                            showCameraDialog();
                          },
                          child: UserAvatarWithAddStory(
                              radius: 35.r,
                              isVisible: false,
                              text: '',
                              profileURL:
                                  UserDetailsDataStore.getUserProfilePic,
                              userPhotoPath: userProfilePic,
                              isProfilePictureEdit: () {
                                showCameraDialog();
                              }))
                    ])),
                    sizedBoxHeight_20(),
                    _buildFirstNameWidget(),
                    sizedBoxHeight_10(),
                    _buildLastNameWidget(),
                    sizedBoxHeight_10(),
                    _buildPhoneNumberWidget(),
                    sizedBoxHeight_10(),
                    _buildEmailwidget(),
                    sizedBoxHeight_20(),
                    _buildSubmitBtn(),
                    SizedBox(
                      height: keyboardHeight,
                    )
                  ],
                ),
              ),
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
        hintText: translation(context).fullName,
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
      initialCountryCode: _countryISOCode ?? 'GB',
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
              borderSide: const BorderSide(color: grayBorderColor, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(color: darkBorderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(color: black))),
      onCountryChanged: (value) {
        isCountryCodeChanged = true;
      },
      validator: (value) {
        updatedPhoneNumber = value!.number;
        updatedCountryISOCode = value.countryISOCode;
        updatedCountryCode = value.countryCode;
        String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        RegExp regExp = RegExp(pattern);
        if (value.number.isEmpty) {
          return translation(context).enterPhoneNumber;
        } else if (!regExp.hasMatch(value.toString())) {
          return translation(context).validPhoneNumber;
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
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor))),
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
        });
  }

  //final submit btn
  Widget _buildSubmitBtn() {
    return BlocBuilder(
        bloc: userBloc,
        builder: (context, state) {
          if (state is UserDataLoading) {
            return showCirclularLoading();
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
                borderRadius: BorderRadius.circular(23.0))),
        focusNode: _submitFocusNode,
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          if (_firstNameController!.text != updatedFirstName ||
              _lastNameController!.text != updatedLastName ||
              _phoneNumber != updatedPhoneNumber ||
              isCountryCodeChanged ||
              userProfilePic != null) {
            if (_formKey.currentState!.validate()) {
              _firstNameFocusNode!.unfocus();
              _lastNameFocusNode!.unfocus();
              _countryCodeFocusNode!.unfocus();
              _phoneNumberFocusNode!.unfocus();
              _emailFocusNode!.unfocus();
              FocusScope.of(context).requestFocus(_submitFocusNode);
              _formKey.currentState!.save();
              String capitalize(String s) =>
                  s[0].toUpperCase() + s.substring(1);
              String firstName = capitalize(_firstNameController!.text);
              String lastName = capitalize(_lastNameController!.text);
              var userUpdatedDataEvent = UpdateProfileEvent(
                  firstName: firstName.trim(),
                  lastName: lastName.trim(),
                  email: _emailController!.text,
                  countryISOCode: _countryISOCode,
                  countryCode: _countryCode,
                  phoneNumber: _phoneNumber,
                  userProfilePhoto: userProfilePic,
                  status: UserDetailsDataStore.getUserStatus,
                  isAdmin: UserDetailsDataStore.getAdminFlag,
                  uid: UserDetailsDataStore.getCurrentFirebaseUserID,
                  organizations: UserDetailsDataStore.getUserOrganizations,
                  isActive: UserDetailsDataStore.getIsActive,
                  isDeleted: UserDetailsDataStore.getIsDeleted);
              userBloc!.add(userUpdatedDataEvent);
            }
          } else {
            showAlertSnackBar(
                context, translation(context).noUpdateChanges, AlertType.info);
          }
        },
        child: Text(translation(context).update,
            style: TextStyle(
                color: brightTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600)));
  }

  showCameraDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
              backgroundColor: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              content: SizedBox(
                  height: 55.h,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              getImageFromCamera();
                              Navigator.pop(context);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt_rounded,
                                      color: black),
                                  SizedBox(width: 5.w),
                                  Text(translation(context).camera,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500))
                                ])),
                        const Divider(),
                        InkWell(
                            onTap: () {
                              getImageFromGallery();
                              Navigator.pop(context);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined,
                                      color: black),
                                  SizedBox(width: 5.w),
                                  Text(translation(context).gallery,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500))
                                ]))
                      ])));
        });
  }
}
