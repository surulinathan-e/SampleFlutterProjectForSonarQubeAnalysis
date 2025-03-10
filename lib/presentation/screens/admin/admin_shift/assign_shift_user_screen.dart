import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/organization_user.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class AssignShiftUserScreen extends StatefulWidget {
  final Shift? shift;
  final Organization? organization;
  const AssignShiftUserScreen({super.key, this.shift, this.organization});

  @override
  State<AssignShiftUserScreen> createState() => _AssignShiftUserScreenState();
}

class _AssignShiftUserScreenState extends State<AssignShiftUserScreen> {
  AdminBloc? adminBloc;
  List<OrganizationUser>? userList;
  String? selectedOrganization;
  String? shiftId;
  OrganizationUser? selectedOrganizationUser;
  List<String>? selectedUsers;
  final _dropdownFormKey = GlobalKey<FormState>();
  TextEditingController? searchController;
  ScrollController? scrollController;
  FocusNode? _submitFocusNode, searchFocusNode;

  @override
  void initState() {
    adminBloc = BlocProvider.of<AdminBloc>(context);
    selectedOrganization = widget.organization!.id;
    shiftId = widget.shift!.id!;
    searchController = TextEditingController();
    scrollController = ScrollController();
    _submitFocusNode = FocusNode();
    searchFocusNode = FocusNode();
    readDate();
    super.initState();
  }

  readDate() {
    adminBloc!.add(GetUnassignedShiftUser(
        selectedOrganization!, shiftId!, searchController!.text.trim()));
  }

  @override
  void dispose() {
    super.dispose();
    searchController!.dispose();
    _submitFocusNode!.dispose();
    searchFocusNode!.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // bg
          bGMainMini(),
          Column(
            children: [
              SizedBox(height: 20.h),
              Align(
                  alignment: Alignment.topLeft,
                  child: goBack(() => {Navigator.of(context).pop()})),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  translation(context).assignShiftUser,
                  style: const TextStyle(
                      color: brightTextColor,
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                  child: BlocListener(
                bloc: adminBloc,
                listener: (context, state) {
                  if (state is GetUnassignedShiftUserSuccess) {
                    userList = state.unAssignedUserList
                        .where((element) => element.user!.isDeleted == false)
                        .toList();
                  } else if (state is GetUnassignedShiftUserFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  } else if (state is AssignShiftUserSuccess) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).userAssignedSuccessfully,
                        AlertType.success);
                    Navigator.pop(context);
                  } else if (state is AssignShiftUserFailed) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  }
                },
                child: BlocBuilder(
                  bloc: adminBloc,
                  builder: (context, state) {
                    if (state is GetUnassignedShiftUserLoading) {
                      return const Center(child: Loading());
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            _buildShiftDetailsWidget(),
                            sizedBoxHeight_10(),
                            _buildformWidget(),
                            Expanded(
                              child: SingleChildScrollView(
                                  child: _buildBodyContentWidget()),
                            ),
                            sizedBoxHeight_20(),
                            userList != null && userList!.isNotEmpty
                                ? _buildSubmitBtn()
                                : const SizedBox(),
                            sizedBoxHeight_10()
                          ],
                        ),
                      );
                    }
                  },
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildformWidget() {
    return Form(
      key: _dropdownFormKey,
      child: Column(
        children: [
          _buildUserSearchWithButton(),
        ],
      ),
    );
  }

  Widget _buildUserSearchWithButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Row(
        children: [
          Expanded(
            child: _buildUserSearchTextFormField(),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              focusNode: _submitFocusNode,
              onPressed: () {
                if (_dropdownFormKey.currentState!.validate()) {
                  FocusScope.of(context).requestFocus(_submitFocusNode);
                  _dropdownFormKey.currentState!.save();
                  readDate();
                }
              },
              child: Text(
                translation(context).search,
                style: TextStyle(
                  color: brightTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearchTextFormField() {
    return TextFormField(
      controller: searchController,
      focusNode: searchFocusNode,
      decoration: InputDecoration(
        hintText: translation(context).searchUser,
        suffixIcon: searchController!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: lightTextColor),
                onPressed: () {
                  setState(() {
                    searchController!.clear();
                    readDate();
                  });
                },
              )
            : const SizedBox(),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: grayBorderColor, width: 2),
          borderRadius: BorderRadius.circular(2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        filled: true,
        fillColor: transparent,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter user name';
        }
        return null;
      },
    );
  }

  Widget _buildShiftDetailsWidget() {
    return Card(
      color: white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.organization!.name}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '${widget.shift!.shiftName}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  ConvertionUtil.convertLocalTimeFromString(
                      ConvertionUtil.convertToUTCWithZ(
                          widget.shift!.shiftStartTiming)),
                  style: const TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                const Text(' - ',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                Text(
                  ConvertionUtil.convertLocalTimeFromString(
                      ConvertionUtil.convertToUTCWithZ(
                          widget.shift!.shiftEndTiming)),
                  style: const TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContentWidget() {
    return SingleChildScrollView(
      child: userList != null && userList!.isNotEmpty
          ? Column(
              children: List.generate(
                userList!.length,
                (index) => CheckboxListTile(
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: RichText(
                    text: TextSpan(
                        text:
                            '${userList![index].user!.firstName} ${userList![index].user!.lastName}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        children: [
                          TextSpan(
                            text: ' (${userList![index].user!.email})',
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 121, 120, 120)),
                          )
                        ]),
                  ),
                  value: userList![index].isDeleted,
                  onChanged: (value) {
                    setState(() {
                      userList![index].isDeleted = value;
                      if (value == true) {
                        selectedUsers ??= [];
                        if (!selectedUsers!
                            .contains(userList![index].user!.userId)) {
                          selectedUsers!.add(userList![index].user!.userId!);
                        }
                      } else {
                        selectedUsers?.remove(userList![index].user!.userId);
                      }
                    });
                  },
                ),
              ),
            )
          : _buildNoUsersWidget(),
    );
  }

  Widget _buildSubmitBtn() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.0),
          )),
      onPressed: () {
        if (selectedUsers != null) {
          progress(context);
          adminBloc!.add(AssignShiftUser(
              selectedOrganization!, selectedUsers!, widget.shift!.id!));
        } else {
          showAlertSnackBar(
              context, translation(context).selectUserToAssign, AlertType.info);
        }
      },
      child: Text(
        translation(context).assign,
        style: TextStyle(
            color: brightTextColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildNoUsersWidget() {
    return Container(
      width: 350.0,
      height: 300.0,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: loadingOpacityBrightColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            translation(context).userNotFound,
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
