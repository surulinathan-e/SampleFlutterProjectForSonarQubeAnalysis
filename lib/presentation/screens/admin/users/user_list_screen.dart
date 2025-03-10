import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  AdminBloc? adminBloc;
  List<UserProfile>? userList;
  String? selectedOrganization;
  List<Organization>? organizations;
  List<Organization>? assignOrganizations;
  int page = 1, limit = 10;
  ScrollController? scrollController;
  bool isLastUser = false;

  @override
  void initState() {
    adminBloc = BlocProvider.of<AdminBloc>(context);
    scrollController = ScrollController();
    organizations = UserDetailsDataStore.getUserOrganizations!;
    selectedOrganization = UserDetailsDataStore.getSelectedOrganizationId;
    assignOrganizations = organizations!
        .where((element) => element.id != selectedOrganization)
        .toList();
    scrollController!.addListener(loadMore);
    readData();
    super.initState();
  }

  readData() {
    adminBloc!.add(GetUsersByOrganization(
        UserDetailsDataStore.getSelectedOrganizationId!, page, limit, ''));
  }

  getUsersOrganization() {
    adminBloc!
        .add(GetUsersByOrganization(selectedOrganization!, page, limit, ''));
  }

  loadMore() {
    double maxScroll = scrollController!.position.maxScrollExtent;
    double offset = scrollController!.offset;
    bool outOfRange = scrollController!.position.outOfRange;
    if (offset >= maxScroll && !outOfRange && !isLastUser) {
      page = page + 1;
      selectedOrganization == UserDetailsDataStore.getSelectedOrganizationId!
          ? readData()
          : getUsersOrganization();
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () {
              Navigator.pushNamed(context, PageName.createUserScreen);
            },
            child: const Icon(Icons.add, color: Colors.white)),
        body: Stack(children: [
          // bg
          bGMainMini(),
          Column(children: [
            SizedBox(height: 20.h),
            Align(
                alignment: Alignment.topLeft,
                child: goBack(() => {Navigator.of(context).pop()})),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                translation(context).users,
                style: const TextStyle(
                    color: brightTextColor,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
                child: BlocListener(
                    bloc: adminBloc,
                    listener: (context, state) {
                      if (state is GetUsersOrganizationSuccess) {
                        isLastUser =
                            state.users.isEmpty || state.users.length < 10;
                        if (page == 1) {
                          userList = state.users
                              .where((element) =>
                                  element.organizationUser!.isDeleted == false)
                              .toList();
                        } else {
                          userList!.addAll(state.users
                              .where((element) =>
                                  element.organizationUser!.isDeleted == false)
                              .toList());
                        }
                      } else if (state is GetUsersOrganizationFailed) {
                        showAlertSnackBar(
                            context, state.errorMessage, AlertType.error);
                      } else if (state is AddOrganizationUserSuccess) {
                        Navigator.pop(context);
                        showAlertSnackBar(
                            context,
                            translation(context).userAssignedSuccessfully,
                            AlertType.success);
                      } else if (state is AddOrganizationUserFailed) {
                        Navigator.pop(context);
                        showAlertSnackBar(
                            context, state.errorMessage, AlertType.error);
                      }
                    },
                    child: BlocBuilder(
                        bloc: adminBloc,
                        builder: (context, state) {
                          if (state is GetUsersOrganizationLoading ||
                              state is RemoveOrganizationUserLoading) {
                            return const Center(child: Loading());
                          } else {
                            return SingleChildScrollView(
                                controller: scrollController,
                                child: Column(children: [
                                  _buildOrganizationWidget(),
                                  _buildBodyContentWidget(),
                                  SizedBox(height: 50.h)
                                ]));
                          }
                        })))
          ])
        ]));
  }

  Widget _buildOrganizationWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: DropdownButtonFormField(
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
            fillColor: Colors.transparent,
          ),
          validator: (value) =>
              value == null ? translation(context).selectOrganisation : null,
          dropdownColor: Colors.white,
          value: selectedOrganization,
          onChanged: (String? newValue) {
            assignOrganizations = organizations!
                .where((element) => element.id != newValue)
                .toList();
            setState(() {
              selectedOrganization = newValue;
            });
            page = 1;
            getUsersOrganization();
          },
          items: organizations!
              .map((organization) => DropdownMenuItem(
                  value: '${organization.id}',
                  child: Text('${organization.name}')))
              .toList()),
    );
  }

  // show multiple organization
  Widget _buildBodyContentWidget() {
    return userList != null && userList!.isNotEmpty
        ? ListView.builder(
            itemCount: !isLastUser ? userList!.length + 1 : userList!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == userList!.length) {
                return isLastUser || userList!.length < limit
                    ? const SizedBox()
                    : Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 10.h),
                          height: 40,
                          width: 40,
                          child: const Loading(),
                        ),
                      );
              } else {
                UserProfile user = userList!.elementAt(index);
                return Card(
                    color: white,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: ListTile(
                        title: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: const TextStyle(
                                        color: darkTextColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(user.email!,
                                      style: const TextStyle(
                                          color: darkTextColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal))
                                ])),
                        trailing: PopupMenuButton(
                            color: white,
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(
                                    translation(context).edit,
                                    style: const TextStyle(fontSize: 13.0),
                                  ),
                                  onTap: () async {
                                    var result = await Navigator.pushNamed(
                                        context, PageName.updateUserScreen,
                                        arguments: user);
                                    if (result == true) {
                                      page = 1;
                                      getUsersOrganization();
                                    }
                                  },
                                ),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text(
                                    translation(context).remove,
                                    style: const TextStyle(fontSize: 13.0),
                                  ),
                                  onTap: () async {
                                    String userId = user.userId!;
                                    String userName =
                                        ConvertionUtil.convertSingleName(
                                            user.firstName ?? '',
                                            user.lastName ?? '');
                                    var result = await showDialog(
                                      context: context,
                                      builder: (context) => RemoveUserDialog(
                                        userId: userId,
                                        userName: userName,
                                        orgId: selectedOrganization!,
                                      ),
                                    );
                                    if (result != null) {
                                      page = 1;
                                      getUsersOrganization();
                                    }
                                  },
                                ),
                                PopupMenuItem(
                                    value: 'assign',
                                    child: DropdownButton(
                                        hint: Text(
                                            translation(context)
                                                .assignOrganisation,
                                            style: const TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.black)),
                                        onChanged: (value) {
                                          Navigator.pop(context);
                                          progress(context);
                                          adminBloc!.add(AddOrganizationUser(
                                              value!,
                                              // [user.userId!]
                                              [
                                                {
                                                  'userId': user.userId!,
                                                  'roleIds': [],
                                                }
                                              ]));
                                        },
                                        items: assignOrganizations!
                                            .map((organization) => DropdownMenuItem(
                                                value: '${organization.id}',
                                                child: Text(
                                                    '${translation(context).assignTo} ${organization.name}',
                                                    style: const TextStyle(
                                                        fontSize: 14.0))))
                                            .toList()))
                              ];
                            })));
              }
            })
        : _buildNoUsersWidget();
  }

  // no users widget
  Widget _buildNoUsersWidget() {
    return Container(
        width: 350.0,
        height: 300.0,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: loadingOpacityBrightColor,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(translation(context).userNotFound,
              style: const TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center)
        ]));
  }
}
