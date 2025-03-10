import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class AddOrganizationScreen extends StatefulWidget {
  final Organization? organization;
  final bool? isSubOrganization;
  const AddOrganizationScreen(
      {super.key, this.organization, this.isSubOrganization});

  @override
  State<AddOrganizationScreen> createState() => _AddOrganizationScreenState();
}

class _AddOrganizationScreenState extends State<AddOrganizationScreen> {
  //controllers
  TextEditingController? _nameController,
      _emailController,
      _addressController,
      _latitudeController,
      _longitudeController,
      _geoRadiusController;

  //focusNode
  FocusNode? _nameFocusNode,
      _emailFocusNode,
      _addressFocusNode,
      _latitudeFocusNode,
      _longitudeFocusNode,
      _geoRadiusFocusNode,
      _submitFocusNode;

  bool isProfileUpdated = false, isParentOrganization = false;

  //formKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AdminBloc? adminBloc;
  String? selectedOrganization;
  List<Organization>? organizationList;

  String? updatedName,
      updatedEmail,
      updatedAddress,
      updatedLatitude,
      updatedLongitude,
      updatedGeoRadius;

  bool _geoLocationEnable = false, isSubOrganization = false;
  Organization? organization;
  bool isOrganizationUpdate = false;
  bool? existedGeoEnable, existedParentOrganization;

  @override
  void initState() {
    super.initState();
    adminBloc = BlocProvider.of<AdminBloc>(context);
    //controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _geoRadiusController = TextEditingController();
    //focusNodes
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _latitudeFocusNode = FocusNode();
    _longitudeFocusNode = FocusNode();
    _geoRadiusFocusNode = FocusNode();
    _submitFocusNode = FocusNode();
    organization = widget.organization;
    isSubOrganization = widget.isSubOrganization ?? false;
    isSubOrganization != false
        ? selectedOrganization = organization!.id
        : organization != null
            ? selectedOrganization = organization!.parentOrganizationId
            : null;

    organizationList = UserDetailsDataStore.getUserOrganizations!;
    if (!isSubOrganization) checkOrganization();
  }

  checkOrganization() {
    if (organization != null) {
      _nameController!.text = organization!.name!;
      _emailController!.text = organization!.email!;
      _addressController!.text = organization!.address!;
      _latitudeController!.text = organization!.latitude!;
      _longitudeController!.text = organization!.longitude!;
      _geoRadiusController!.text = organization!.radius!;
      _geoLocationEnable = organization!.geoLocationEnable!;
      isParentOrganization = organization!.isParentOrganization!;

      updatedName = _nameController!.text;
      updatedEmail = _emailController!.text;
      updatedAddress = _addressController!.text;
      updatedLatitude = _latitudeController!.text;
      updatedLongitude = _longitudeController!.text;
      updatedGeoRadius = _geoRadiusController!.text;
      existedGeoEnable = _geoLocationEnable;
      existedParentOrganization = isParentOrganization;
    }
  }

  @override
  void dispose() {
    super.dispose();
    //controllers
    _nameController!.dispose();
    _emailController!.dispose();
    _addressController!.dispose();
    _latitudeController!.dispose();
    _longitudeController!.dispose();
    _geoRadiusController!.dispose();

    //focusNodes
    _nameFocusNode!.dispose();
    _emailFocusNode!.dispose();
    _addressFocusNode!.dispose();
    _latitudeFocusNode!.dispose();
    _longitudeFocusNode!.dispose();
    _geoRadiusFocusNode!.dispose();
    _submitFocusNode!.dispose();
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
          Navigator.of(context).pop(isOrganizationUpdate);
          return Future.value();
        },
        child: Scaffold(
            backgroundColor: bgColor,
            resizeToAvoidBottomInset: false,
            body: BlocListener<AdminBloc, AdminState>(
                bloc: adminBloc,
                listener: (context, state) {
                  if (state is AddOrganizationFailed) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  } else if (state is AddOrganizationSuccess) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).addOrganisation,
                        AlertType.success);
                    _clearFormData();
                    Navigator.pop(context, true);
                  } else if (state is UpdateOrganizationFailed) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  } else if (state is UpdateOrganizationSuccess) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).updateOrganisation,
                        AlertType.success);
                    isOrganizationUpdate = true;
                  }
                },
                child: BlocBuilder<AdminBloc, AdminState>(
                    bloc: adminBloc,
                    builder: (context, state) {
                      return Stack(children: [
                        bGMainMini(),
                        SizedBox(
                            height: screenHeight - keyboardHeight,
                            child: _buildBodyContentWidget())
                      ]);
                    }))));
  }

  //login frm
  Widget _buildBodyContentWidget() {
    return Column(children: [
      SizedBox(height: 20.h),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: brightBackArrow(() {
                Navigator.of(context).pop(isOrganizationUpdate);
              }))),
      Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
              isSubOrganization
                  ? translation(context).addSubOrg
                  : organization == null
                      ? translation(context).addOrganisation
                      : translation(context).updateOrganisation,
              style: const TextStyle(
                  color: white,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500))),
      sizedBoxHeight_20(),
      Expanded(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                      key: _formKey,
                      child: Column(children: [
                        sizedBoxHeight_20(),
                        if (organization != null)
                          (organization!.isParentOrganization! &&
                                      organization!.parentOrganizationId !=
                                          null) ||
                                  isSubOrganization
                              ? Column(children: [
                                  _buildOrganizationWidget(),
                                  sizedBoxHeight_10()
                                ])
                              : const SizedBox(),
                        _buildNameWidget(),
                        sizedBoxHeight_10(),
                        _buildEmailWidget(),
                        sizedBoxHeight_10(),
                        _buildAddressWidget(),
                        sizedBoxHeight_10(),
                        _buildGeoLocation(),
                        if (_geoLocationEnable)
                          Column(children: [
                            sizedBoxHeight_10(),
                            _buildLatitudeWidget(),
                            sizedBoxHeight_10(),
                            _buildLongitudeWidget(),
                            sizedBoxHeight_10(),
                            _buildRadiusWidget()
                          ]),
                        sizedBoxHeight_20(),
                        _buildSubmitBtn()
                      ])))))
    ]);
  }

  Widget _buildOrganizationWidget() {
    return DropdownButtonFormField(
        hint: Text(translation(context).selectOrganisation),
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: grayBorderColor, width: 2),
                borderRadius: BorderRadius.circular(25.0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            filled: true,
            fillColor: transparent),
        validator: (value) =>
            value == null ? translation(context).selectOrganisation : null,
        dropdownColor: white,
        value: selectedOrganization,
        onChanged: (String? newValue) {
          setState(() {
            selectedOrganization = newValue;
          });
        },
        items: organizationList!
            .map((organization) => DropdownMenuItem(
                value: '${organization.id}',
                child: Text('${organization.name}')))
            .toList());
  }

  //first name txt bx
  Widget _buildNameWidget() {
    return TextFormField(
        autofocus: true,
        focusNode: _nameFocusNode,
        enabled: true,
        textInputAction: TextInputAction.next,
        controller: _nameController,
        keyboardType: TextInputType.name,
        enableSuggestions: true,
        autocorrect: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
            prefixIcon:
                const Icon(Icons.verified_user_outlined, color: darkTextColor),
            hintText: translation(context).organisationName,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterOrganisation;
          }
          updatedName = value.trim();
          return null;
        },
        onFieldSubmitted: (term) {
          _nameFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_emailFocusNode);
        });
  }

  //email txt bx
  Widget _buildEmailWidget() {
    return TextFormField(
        focusNode: _emailFocusNode,
        textInputAction: TextInputAction.next,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        enabled: organization != null && !isSubOrganization ? false : true,
        enableSuggestions: false,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
            prefixIcon: const Icon(Icons.mail_outlined, color: darkTextColor),
            hintText: translation(context).eMail,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
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
          updatedEmail = value.trim();
          return null;
        },
        onFieldSubmitted: (term) {
          _emailFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_addressFocusNode);
        });
  }

  //address txt bx
  Widget _buildAddressWidget() {
    return TextFormField(
        focusNode: _addressFocusNode,
        enabled: true,
        textInputAction: TextInputAction.next,
        controller: _addressController,
        keyboardType: TextInputType.name,
        enableSuggestions: true,
        autocorrect: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            prefixIcon: const Icon(Icons.local_post_office_outlined,
                color: darkTextColor),
            hintText: translation(context).address,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: black))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterOrganisationAddress;
          }
          updatedAddress = value.trim();
          return null;
        },
        onFieldSubmitted: (term) {
          _addressFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_latitudeFocusNode);
        });
  }

  Widget _buildGeoLocation() {
    return Column(children: [
      organization != null && !isSubOrganization
          ? CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: primaryColor,
              title: Text(translation(context).parentOrganization),
              value: isParentOrganization,
              onChanged: (value) {
                setState(() {
                  isParentOrganization = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading)
          : const SizedBox(),
      CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: primaryColor,
          title: Text(translation(context).enableLocation),
          value: _geoLocationEnable,
          onChanged: (value) {
            setState(() {
              _geoLocationEnable = value!;
            });
          },
          controlAffinity: ListTileControlAffinity.leading)
    ]);
  }

  //latitude txt bx
  Widget _buildLatitudeWidget() {
    return TextFormField(
        focusNode: _latitudeFocusNode,
        enabled: true,
        textInputAction: TextInputAction.next,
        controller: _latitudeController,
        keyboardType: TextInputType.number,
        enableSuggestions: true,
        autocorrect: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
            prefixIcon:
                const Icon(Icons.location_on_outlined, color: darkTextColor),
            hintText: translation(context).latitude,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: black))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterLatitudeValue;
          }
          updatedLatitude = value.trim();
          return null;
        },
        onFieldSubmitted: (term) {
          _addressFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_longitudeFocusNode);
        });
  }

  //longitude txt bx
  Widget _buildLongitudeWidget() {
    return TextFormField(
        focusNode: _longitudeFocusNode,
        enabled: true,
        textInputAction: TextInputAction.next,
        controller: _longitudeController,
        keyboardType: TextInputType.number,
        enableSuggestions: true,
        autocorrect: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
            prefixIcon:
                const Icon(Icons.location_on_outlined, color: darkTextColor),
            hintText: translation(context).longitude,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: black))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterLongitude;
          }
          updatedLongitude = value.trim();
          return null;
        },
        onFieldSubmitted: (term) {
          _addressFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_geoRadiusFocusNode);
        });
  }

  //radius txt bx
  Widget _buildRadiusWidget() {
    return TextFormField(
        focusNode: _geoRadiusFocusNode,
        enabled: true,
        textInputAction: TextInputAction.next,
        controller: _geoRadiusController,
        keyboardType: TextInputType.number,
        enableSuggestions: true,
        autocorrect: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
            prefixIcon: const Icon(Icons.radar_outlined, color: darkTextColor),
            hintText: translation(context).geoRadius,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: black))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterGeoRadius;
          }
          updatedGeoRadius = value.trim();
          return null;
        },
        onFieldSubmitted: (term) {
          _addressFocusNode!.unfocus();
          FocusScope.of(context).requestFocus(_submitFocusNode);
        });
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

  Widget buildHeading(title) {
    return Text(title,
        style: TextStyle(
            fontFamily: 'Poppins',
            color: greyTextColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500));
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
          if (organization != null && !isSubOrganization) {
            if (_nameController!.text != updatedName ||
                _emailController!.text != updatedEmail ||
                _addressController!.text != updatedAddress ||
                _latitudeController!.text != updatedLatitude ||
                _longitudeController!.text != updatedLongitude ||
                _geoRadiusController!.text != updatedGeoRadius ||
                _geoLocationEnable != existedGeoEnable ||
                isParentOrganization != existedParentOrganization) {
              if (_formKey.currentState!.validate()) {
                progress(context);
                _nameFocusNode!.unfocus();
                _emailFocusNode!.unfocus();
                _addressFocusNode!.unfocus();
                _latitudeFocusNode!.unfocus();
                _longitudeFocusNode!.unfocus();
                _geoRadiusFocusNode!.unfocus();
                FocusScope.of(context).requestFocus(_submitFocusNode);
                _formKey.currentState!.save();
                _geoLocationEnable
                    ? adminBloc!.add(UpdateOrganization(
                        organization!.id!,
                        selectedOrganization,
                        _nameController!.text.trim(),
                        _emailController!.text.trim(),
                        _addressController!.text.trim(),
                        true,
                        _latitudeController!.text.trim(),
                        _longitudeController!.text.trim(),
                        _geoRadiusController!.text.trim(),
                        isParentOrganization))
                    : adminBloc!.add(UpdateOrganization(
                        organization!.id!,
                        selectedOrganization,
                        _nameController!.text.trim(),
                        _emailController!.text.trim(),
                        _addressController!.text.trim(),
                        false,
                        _latitudeController!.text.trim(),
                        _longitudeController!.text.trim(),
                        _geoRadiusController!.text.trim(),
                        isParentOrganization));
                UserDetailsDataStore.setOrganizationName =
                    _nameController!.text;
                UserDetailsDataStore.setOrganizationGeoLocationEnable =
                    _geoLocationEnable;
                UserDetailsDataStore.setOrganizationLatitude =
                    _latitudeController!.text;
                UserDetailsDataStore.setOrganizationLongitude =
                    _latitudeController!.text;
                UserDetailsDataStore.setOrganizationRadius =
                    _geoRadiusController!.text;
              }
            } else {
              showAlertSnackBar(context, translation(context).noUpdateChanges,
                  AlertType.info);
            }
          } else {
            if (_formKey.currentState!.validate()) {
              progress(context);
              _nameFocusNode!.unfocus();
              _emailFocusNode!.unfocus();
              _addressFocusNode!.unfocus();
              _latitudeFocusNode!.unfocus();
              _longitudeFocusNode!.unfocus();
              _geoRadiusFocusNode!.unfocus();
              FocusScope.of(context).requestFocus(_submitFocusNode);
              _formKey.currentState!.save();
              _geoLocationEnable
                  ? adminBloc!.add(AddOrganization(
                      selectedOrganization,
                      _nameController!.text.trim(),
                      _emailController!.text.trim(),
                      _addressController!.text.trim(),
                      true,
                      _latitudeController!.text.trim(),
                      _longitudeController!.text.trim(),
                      _geoRadiusController!.text.trim()))
                  : adminBloc!.add(AddOrganization(
                      selectedOrganization,
                      _nameController!.text.trim(),
                      _emailController!.text.trim(),
                      _addressController!.text.trim(),
                      false,
                      '',
                      '',
                      ''));
            }
          }
        },
        child: Text(
            isSubOrganization
                ? translation(context).addSubOrg
                : organization == null
                    ? translation(context).addOrganisation
                    : translation(context).updateOrganisation,
            style: TextStyle(
                color: brightTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600)));
  }

  // clear txt
  void _clearFormData() {
    _nameController!.clear();
    _emailController!.clear();
    _addressController!.clear();
    _geoLocationEnable = false;
    _latitudeController!.clear();
    _longitudeController!.clear();
    _geoRadiusController!.clear();
  }
}
