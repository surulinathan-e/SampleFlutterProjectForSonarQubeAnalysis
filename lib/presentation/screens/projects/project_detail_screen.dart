import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/member.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectDetails? project;
  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  AdminBloc? adminBloc;
  ProjectBloc? projectBloc;
  String searchUser = '';
  int page = 1, limit = 10;
  bool isLastUser = false;
  List<UserProfile>? usersList = [];
  List<Member>? membersList = [];
  List<String>? updatedMembersList = [];
  bool isTeamMemberEqual = true, textClear = false, isProjectUpdated = false;
  ScrollController? scrollController;
  String? projectName,
      projectCreatorName,
      projectCreatorId,
      projectDescription,
      projectId,
      selectedUserId,
      orgId,
      userId;
  int? activeFieldIndex;
  final _formKey = GlobalKey<FormState>();
  TextEditingController? projectNameController,
      projectDescriptionController,
      _searchController;

  List<TextEditingController>? teamMembersController;

  FocusNode? projectNameFocusNode,
      projectDescriptionFocusNode,
      _searchFocusNode,
      teamMembersControlleFocusNode;

  ProjectDetails? project;
  Timer? debounceTimer;

  @override
  void initState() {
    adminBloc = BlocProvider.of<AdminBloc>(context);
    projectBloc = BlocProvider.of<ProjectBloc>(context);
    project = widget.project;
    orgId = UserDetailsDataStore.getSelectedOrganizationId;
    teamMembersController = [];
    scrollController = ScrollController();
    projectNameController = TextEditingController();
    projectDescriptionController = TextEditingController();
    _searchController = TextEditingController();
    userId = UserDetailsDataStore.getCurrentFirebaseUserID;
    projectNameFocusNode = FocusNode();
    projectDescriptionFocusNode = FocusNode();
    _searchFocusNode = FocusNode();
    teamMembersControlleFocusNode = FocusNode();

    if (project != null) {
      projectId = project!.projectId;
      projectName = projectNameController!.text = project!.projectName ?? '';
      projectDescription = projectDescriptionController!.text =
          project!.projectDescription ?? '';
      membersList = project!.projectMembers;
      if (project!.createdBy != null) {
        projectCreatorName = ConvertionUtil.convertSingleName(
            project!.createdBy!.firstName ?? '',
            project!.createdBy!.lastName ?? '');
        projectCreatorId = project!.createdBy!.userId ?? '';
      }
      if (membersList != null) {
        for (var i = 0; i < membersList!.length; i++) {
          teamMembersController!.add(TextEditingController());

          teamMembersController![i].text = ConvertionUtil.convertSingleName(
              membersList![i].firstName ?? '', membersList![i].lastName ?? '');
          updatedMembersList!.add(membersList![i].userId!);
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    scrollController!.dispose();
    projectNameController!.dispose();
    projectDescriptionController!.dispose();
    super.dispose();
  }

  getAllUsers() {
    adminBloc!.add(GetUsersByOrganization(
        UserDetailsDataStore.getSelectedOrganizationId!,
        page,
        limit,
        _searchController!.text));
  }

  updateTeamMemberList() {
    if (updatedMembersList!.length == membersList!.length) {
      for (var i = 0; i < membersList!.length; i++) {
        if (membersList![i].userId != updatedMembersList![i]) {
          isTeamMemberEqual = false;
          return;
        } else {
          isTeamMemberEqual = true;
        }
      }
    } else {
      isTeamMemberEqual = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(isProjectUpdated);
        return;
      },
      child: Scaffold(
        appBar: buildAppBar(),
        backgroundColor: bgColor,
        body: MultiBlocListener(
          listeners: [
            BlocListener<AdminBloc, AdminState>(
                bloc: adminBloc,
                listener: (context, state) {
                  if (state is GetUsersOrganizationSuccess) {
                    if (page == 1) {
                      isLastUser = state.users.isEmpty;
                      usersList = state.users;
                    } else {
                      isLastUser = state.users.isEmpty;
                      usersList!.addAll(state.users);
                    }
                  } else if (state is GetUsersOrganizationFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  }
                }),
            BlocListener<ProjectBloc, ProjectState>(
              bloc: projectBloc,
              listener: (context, state) {
                if (state is UpdateProjectSuccess) {
                  isProjectUpdated = true;
                  Navigator.pop(context, isProjectUpdated);
                  showAlertSnackBar(
                      context,
                      translation(context).projectUpdatedSuccessfully,
                      AlertType.success);
                } else if (state is UpdateProjectFailed) {
                  showAlertSnackBar(
                      context, state.errorMessage, AlertType.error);
                } else if (state is DeleteProjectSuccess) {
                  Navigator.pop(context, true);
                  showAlertSnackBar(
                      context,
                      translation(context).projectDeletedSuccessfully,
                      AlertType.success);
                } else if (state is DeleteProjectFailed) {
                  showAlertSnackBar(
                      context, state.errorMessage, AlertType.error);
                } else if (state is CreateProjectSuccess) {
                  Navigator.pop(context, true);
                  showAlertSnackBar(
                      context,
                      translation(context).projectCreatedSuccessfully,
                      AlertType.success);
                } else if (state is CreateProjectFailed) {
                  showAlertSnackBar(
                      context, state.errorMessage, AlertType.error);
                }
              },
            ),
          ],
          child: BlocBuilder<AdminBloc, AdminState>(
            bloc: adminBloc,
            builder: (context, state) {
              return BlocBuilder<ProjectBloc, ProjectState>(
                bloc: projectBloc,
                builder: (context, state) {
                  if (state is UpdateProjectLoading ||
                      state is CreateProjectLoading) {
                    return const Loading();
                  } else {
                    return SingleChildScrollView(
                        controller: scrollController, child: _buildBody());
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
        backgroundColor: bgColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, false);
            },
            child: Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 3.h),
                child: CircleAvatar(
                    radius: 25.r,
                    backgroundColor: lightGreyColor,
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: const Icon(Icons.arrow_back_ios,
                            color: greyIconColor))))),
        title: Center(
            child: Text(
                projectId != null
                    ? translation(context).updateProject
                    : translation(context).createProject,
                style: const TextStyle(fontWeight: FontWeight.w500))),
        actions: [
          projectId != null && userId == projectCreatorId
              ? IconButton(
                  icon: const Icon(Icons.delete, color: redIconColor),
                  onPressed: () {
                    showAlertWithAction(
                        context: context,
                        title: translation(context).deleteProject,
                        content: translation(context).doYouWantToDeleteProject,
                        onPress: () {
                          projectBloc!.add(DeleteProject(project!.projectId!));
                        });
                  })
              : const SizedBox()
        ]);
  }

  Widget _buildBody() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.only(left: 8.h, right: 8.h),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 10.h),
              projectNameTextBox(),
              SizedBox(height: 10.h),
              projectDescriptionTextBox(),
              SizedBox(height: 10.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                buildHeading(translation(context).addProjectMember),
                InkWell(
                    onTap: () {
                      setState(() {
                        teamMembersController!.add(TextEditingController());
                      });
                    },
                    child: const Icon(Icons.add, color: primaryColor)),
              ]),
              _buildMemberListWidget(),
              if (projectCreatorName != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      '${translation(context).createdBy} $projectCreatorName'),
                ),
              SizedBox(height: 10.h),
              updateProjectButton(),
              SizedBox(height: 10.h)
            ])));
  }

  Widget buildHeading(title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title,
          style: TextStyle(
              fontFamily: 'Poppins',
              color: greyTextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget projectNameTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: projectNameController,
        focusNode: projectNameFocusNode,
        maxLines: null,
        decoration: InputDecoration(
          filled: true,
          fillColor: white,
          hintText: translation(context).projectName,
          hintStyle: TextStyle(color: lightTextColor.withValues(alpha: .5)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(width: 1.w)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                  color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        ),
        style: const TextStyle(color: lightTextColor),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return translation(context).pleaseEnterProjectName;
          }
          return null;
        });
  }

  Widget projectDescriptionTextBox() {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: 5,
      controller: projectDescriptionController,
      focusNode: projectDescriptionFocusNode,
      decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          filled: true,
          fillColor: white,
          hintText: translation(context).projectDescription,
          hintStyle: TextStyle(color: lightTextColor.withValues(alpha: .5)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(width: 1.w)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                  color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(color: greyBorderColor, width: 1.w))),
      style: const TextStyle(color: lightTextColor),
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return translation(context).pleaseEnterProjectDescription;
      //   }
      //   return null;
      // }
    );
  }

  Widget _buildMemberListWidget() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: teamMembersController!.length,
        padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
        itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  child: TextFormField(
                      readOnly: true,
                      onChanged: (value) {
                        membersList![index].firstName = value;
                      },
                      controller: teamMembersController![index],
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: white,
                          hintText: translation(context).selectMember,
                          hintStyle: TextStyle(
                              color: lightTextColor.withValues(alpha: .5)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(width: 1.w)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(
                                  color: greyBorderColor.withValues(alpha: .2),
                                  width: 1.w)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(
                                  color: greyBorderColor, width: 1.w)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 10.w)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translation(context).pleaseSelectMember;
                        }
                        return null;
                      },
                      onTap: () {
                        setState(() {
                          activeFieldIndex = index;
                          getAllUsers();
                          showAddMemberBottomSheet();
                        });
                      })),
              SizedBox(width: 5.w),
              InkWell(
                  onTap: () {
                    if (teamMembersController!.length > 1) {
                      showAlertWithAction(
                          context: context,
                          title: translation(context).removeMember,
                          content: translation(context).removeThisMember,
                          onPress: () {
                            setState(() {
                              teamMembersController![index].clear();
                              teamMembersController![index].dispose();
                              teamMembersController!.removeAt(index);

                              if (index < updatedMembersList!.length) {
                                updatedMembersList!.removeAt(index);
                              }
                            });
                          });
                    } else {
                      showAlertSnackBar(
                          context,
                          translation(context).projectMemberAlert,
                          AlertType.info);
                    }
                  },
                  child: (membersList != null &&
                          index >= 0 &&
                          index < membersList!.length &&
                          teamMembersController!.isNotEmpty)
                      ? (projectCreatorId != membersList![index].userId)
                          ? const Icon(Icons.delete_forever_rounded,
                              color: redIconColor)
                          : const SizedBox()
                      : const Icon(Icons.delete_forever_rounded,
                          color: redIconColor))
            ])));
  }

  void showAddMemberBottomSheet() {
    showModalBottomSheet(
        backgroundColor: white,
        isScrollControlled: true,
        elevation: 0,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 250.h,
                color: white,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                          child: Text(translation(context).addProjectMember,
                              style: const TextStyle(fontSize: 18))),
                      const SizedBox(height: 10),
                      Text(translation(context).membersList,
                          style: const TextStyle(
                              fontSize: 12, color: greyTextColor),
                          textAlign: TextAlign.left),
                      TextFormField(
                          enabled: true,
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              textClear = value.isEmpty ? false : true;
                            });
                            if (debounceTimer != null) debounceTimer!.cancel();
                            debounceTimer =
                                Timer(const Duration(milliseconds: 1000), () {
                              if (value.isNotEmpty) {
                                page = 1;
                                getAllUsers();
                              }
                            });
                          },
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          maxLines: 1,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_searchController!.text.isNotEmpty) {
                                      _searchController!.clear();
                                      page = 1;
                                      usersList = [];
                                      textClear = false;
                                      getAllUsers();
                                    }
                                  });
                                },
                                child: const Icon(Icons.clear, color: black)),
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: white,
                            hintText: translation(context).searchUser,
                            hintStyle: TextStyle(
                                color: lightTextColor.withValues(alpha: .5)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(width: 1.w)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(
                                    color:
                                        greyBorderColor.withValues(alpha: .2),
                                    width: 1.w)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(
                                    color: greyBorderColor, width: 1.w)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 10.w),
                          ),
                          style: const TextStyle(color: lightTextColor)),
                      const SizedBox(height: 10),
                      BlocBuilder<AdminBloc, AdminState>(
                          bloc: adminBloc,
                          builder: (context, state) {
                            if (state is GetUsersOrganizationLoading) {
                              return const Loading();
                            } else {
                              return Expanded(
                                  child: usersList != null &&
                                          usersList!.isNotEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: usersList!.length,
                                          itemBuilder: (context, index) {
                                            String? userName = ConvertionUtil
                                                .convertSingleName(
                                                    usersList![index]
                                                            .firstName ??
                                                        '',
                                                    usersList![index]
                                                            .lastName ??
                                                        '');
                                            Color avatarColor =
                                                getAvatarColor(index);
                                            return ListTile(
                                                leading: usersList![index]
                                                                .profileUrl !=
                                                            null &&
                                                        usersList![index]
                                                            .profileUrl!
                                                            .isNotEmpty
                                                    ? UserAvatar(
                                                        radius: 16.r,
                                                        profileURL:
                                                            usersList![index]
                                                                .profileUrl)
                                                    : CircleAvatar(
                                                        backgroundColor:
                                                            avatarColor,
                                                        child: Text(
                                                            getInitials(
                                                                userName),
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        white))),
                                                title: Text(userName),
                                                onTap: () {
                                                  final selectedUserId =
                                                      usersList![index].userId;
                                                  final selectedUserName =
                                                      ConvertionUtil
                                                          .convertSingleName(
                                                              usersList![index]
                                                                  .firstName!,
                                                              usersList![index]
                                                                  .lastName!);
                                                  setState(() {
                                                    if (updatedMembersList!
                                                        .contains(
                                                            selectedUserId)) {
                                                      showAlertSnackBar(
                                                        context,
                                                        translation(context)
                                                            .memberAlreadyInTeam,
                                                        AlertType.info,
                                                      );
                                                    } else {
                                                      if (activeFieldIndex! <
                                                          updatedMembersList!
                                                              .length) {
                                                        updatedMembersList![
                                                                activeFieldIndex!] =
                                                            selectedUserId!;
                                                        teamMembersController![
                                                                    activeFieldIndex!]
                                                                .text =
                                                            selectedUserName;
                                                      } else {
                                                        teamMembersController![
                                                                    activeFieldIndex!]
                                                                .text =
                                                            selectedUserName;
                                                        updatedMembersList!.add(
                                                            selectedUserId!);
                                                      }
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                });
                                          })
                                      : Center(
                                          child: Text(
                                            translation(context).userNotFound,
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color: greyTextColor),
                                          ),
                                        ));
                            }
                          }),
                    ])),
          );
        });
  }

  Widget updateMembersButton() {
    return InkWell(
        onTap: () {},
        child: Padding(
            padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
            child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                    child: Text(translation(context).addMember,
                        style: TextStyle(
                            color: white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500))))));
  }

  Widget updateProjectButton() {
    return Padding(
        padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
        child: InkWell(
            onTap: () {
              updateTeamMemberList();
              if (_formKey.currentState!.validate()) {
                if (projectId != null) {
                  if (projectName != projectNameController!.text ||
                      projectDescription !=
                          projectDescriptionController!.text ||
                      !isTeamMemberEqual) {
                    projectBloc!.add(UpdateProject(
                        projectId!,
                        projectNameController!.text.trim(),
                        projectDescriptionController!.text.trim(),
                        updatedMembersList!));
                  } else {
                    showAlertSnackBar(context,
                        translation(context).noChangesMade, AlertType.info);
                  }
                } else {
                  projectBloc!.add(CreateProject(
                      orgId!,
                      projectNameController!.text.trim(),
                      projectDescriptionController!.text.trim(),
                      updatedMembersList!));
                }
              }
            },
            child: Container(
                height: 44.h,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30.r)),
                child: Center(
                    child: Text(
                        projectId != null
                            ? translation(context).updateProject
                            : translation(context).createProject,
                        style: TextStyle(
                            color: white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500))))));
  }
}
