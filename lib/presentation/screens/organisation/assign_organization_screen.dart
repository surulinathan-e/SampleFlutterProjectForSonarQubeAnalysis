import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/admin/admin_bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/colors/colors.dart';

class AssignOrganizationScreen extends StatefulWidget {
  const AssignOrganizationScreen({super.key});

  @override
  State<AssignOrganizationScreen> createState() =>
      _AssignOrganizationScreenState();
}

class _AssignOrganizationScreenState extends State<AssignOrganizationScreen> {
  //focusNode
  TextEditingController? searchController;
  ScrollController? scrollController;
  FocusNode? _submitFocusNode, searchFocusNode;

  //formKey
  final _dropdownFormKey = GlobalKey<FormState>();
  AdminBloc? adminBloc;

  String? selectedOrganization;
  // String? selectedUser;
  List<Organization>? organizations;
  List<UserProfile>? userList = [];
  int page = 1, limit = 10;
  List<String>? selectedUsers;
  bool showUserCard = false;
  bool isLastUser = false;

  @override
  void initState() {
    super.initState();
    adminBloc = BlocProvider.of<AdminBloc>(context);
    organizations = UserDetailsDataStore.getUserOrganizations!;
    searchController = TextEditingController();
    scrollController = ScrollController();
    _submitFocusNode = FocusNode();
    searchFocusNode = FocusNode();
    scrollController!.addListener(loadMore);
  }

  loadMore() {
    double maxScroll = scrollController!.position.maxScrollExtent;
    double offset = scrollController!.offset;
    bool outOfRange = scrollController!.position.outOfRange;
    if (offset >= maxScroll && !outOfRange && !isLastUser) {
      page = page + 1;
      readData();
    }
  }

  readData() {
    adminBloc!.add(GetUnassignedUsers(
        selectedOrganization!, searchController!.text, page, limit));
  }

  @override
  void dispose() {
    super.dispose();
    searchController!.dispose();
    _submitFocusNode!.dispose();
    searchFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          bGMainMini(),
          Column(
            children: [
              SizedBox(height: 20.h),
              Align(
                  alignment: Alignment.topLeft,
                  child: goBack(() => {Navigator.of(context).pop()})),
              Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(translation(context).assignOrganisation,
                      style: const TextStyle(
                          color: white,
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600))),
              const SizedBox(height: 30),
              Expanded(
                  child: BlocListener(
                bloc: adminBloc,
                listener: (context, state) {
                  if (state is GetUnassignedUsersSuccess) {
                    Navigator.pop(context);
                    // userList = state.users
                    //     .where(
                    //         (element) => element.organizationUser!.isDeleted == true)
                    //     .toList();
                    // userList = state.users;
                    isLastUser = state.users.isEmpty || state.users.length < 10;
                    if (page == 1) {
                      userList = state.users;
                    } else {
                      userList!.addAll(state.users);
                    }
                    setState(() {
                      showUserCard = true;
                    });
                  } else if (state is GetUnassignedUsersFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  } else if (state is AddOrganizationUserSuccess) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context,
                        translation(context).assignedOrganisationSuccess,
                        AlertType.success);
                    Navigator.pop(context);
                  } else if (state is AddOrganizationUserFailed) {
                    Navigator.pop(context);
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  }
                },
                child: BlocBuilder(
                    bloc: adminBloc,
                    builder: (context, state) {
                      if (state is GetUsersOrganizationLoading) {
                        return const Center(child: Loading());
                      } else {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(children: [
                              _buildformWidget(),
                              sizedBoxHeight_10(),
                              if (showUserCard)
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _buildUserListWidget(),
                                  ),
                                ),
                            ]));
                      }
                    }),
              ))
            ],
          )
        ],
      ),
      bottomNavigationBar:
          (showUserCard && userList != null && userList!.isNotEmpty)
              ? _buildBottomAppBar()
              : const SizedBox(),
    );
  }

  Widget _buildformWidget() {
    return Form(
      key: _dropdownFormKey,
      child: Column(
        children: [
          sizedBoxHeight_20(),
          _buildOrganizationWidget(),
          sizedBoxHeight_10(),
          _buildUserSearchWithButton(),
        ],
      ),
    );
  }

  //select organisation drop down
  Widget _buildOrganizationWidget() {
    return DropdownButtonFormField(
        hint: Text(translation(context).selectOrganisation),
        decoration: InputDecoration(
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
          fillColor: transparent,
        ),
        validator: (value) =>
            value == null ? translation(context).selectOrganisation : null,
        dropdownColor: white,
        value: selectedOrganization,
        onChanged: (String? newValue) {
          // adminBloc!.add(GetUnassignedOrganizationUsers(newValue!));
          setState(() {
            selectedOrganization = newValue;
            showUserCard = false;
            userList = [];
            searchController!.clear();
          });
        },
        items: organizations!
            .map((organization) => DropdownMenuItem(
                value: '${organization.id}',
                child: Text('${organization.name}')))
            .toList());
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
                  progress(context);
                  readData();
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
    );
  }

  Widget _buildUserListWidget() {
    return SingleChildScrollView(
      controller: scrollController,
      child: userList?.isNotEmpty == true
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userList!.length,
              itemBuilder: (context, index) {
                final user = userList![index];
                final isSelected =
                    selectedUsers?.contains(user.userId) ?? false;

                return CheckboxListTile(
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: RichText(
                    text: TextSpan(
                      text: '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color.fromARGB(255, 121, 120, 120)),
                      children: [
                        TextSpan(
                          text: ' (${user.email})',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 121, 120, 120)),
                        ),
                      ],
                    ),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedUsers ??= [];
                        selectedUsers!.add(user.userId!);
                      } else {
                        selectedUsers?.remove(user.userId);
                      }
                    });
                  },
                );
              },
            )
          : _buildNoUsersWidget(),
    );
  }

  // Widget _buildUserWidget() {
  //   return DropdownButtonFormField(
  //       isExpanded: true,
  //       hint: userList != null && userList!.isNotEmpty
  //           ? Text(translation(context).selectUser)
  //           : Text(translation(context).noUsersSelect),
  //       decoration: InputDecoration(
  //           border: OutlineInputBorder(
  //             borderSide: const BorderSide(color: grayBorderColor, width: 2),
  //             borderRadius: BorderRadius.circular(25.0),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(25.0),
  //             borderSide: const BorderSide(color: darkBorderColor),
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(25.0),
  //             borderSide: const BorderSide(color: darkBorderColor),
  //           ),
  //           filled: true,
  //           fillColor: transparent),
  //       validator: (value) =>
  //           value == null ? translation(context).selectUser : null,
  //       dropdownColor: white,
  //       value: selectedUser,
  //       onChanged: (String? newValue) {
  //         setState(() {
  //           selectedUser = newValue!;
  //         });
  //       },
  //       items: userList!
  //           .map((user) => DropdownMenuItem(
  //                 value: '${user.userId}',
  //                 child: RichText(
  //                   text: TextSpan(
  //                       text: '${user.firstName} ${user.lastName}',
  //                       style: const TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w400,
  //                           color: black),
  //                       children: [
  //                         TextSpan(
  //                           text: ' (${user.email})',
  //                           style: const TextStyle(
  //                               fontWeight: FontWeight.w400,
  //                               color: greyTextColor),
  //                         )
  //                       ]),
  //                   overflow: TextOverflow.visible,
  //                 ),
  //               ))
  //           .toList());
  // }

  Widget _buildBottomAppBar() {
    return BottomAppBar(height: 70, color: bgColor, child: _buildSubmitBtn());
  }

  Widget _buildSubmitBtn() {
    return BlocBuilder(
        bloc: adminBloc,
        builder: (context, state) {
          if (state is GetUsersOrganizationLoading) {
            return showCirclularLoading();
          } else {
            return showSubmitBtn();
          }
        });
  }

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
        if (_dropdownFormKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(_submitFocusNode);
          _dropdownFormKey.currentState!.save();
          if (selectedUsers != null) {
            progress(context);
            adminBloc!.add(AddOrganizationUser(
              selectedOrganization!,
              selectedUsers!
                  .map((userId) => {
                        'userId': userId,
                        'roleIds': [],
                      })
                  .toList(),
            ));
          } else {
            showAlertSnackBar(context, translation(context).selectUserToAssign,
                AlertType.info);
          }
        }
      },
      child: Text(
        translation(context).submit,
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
