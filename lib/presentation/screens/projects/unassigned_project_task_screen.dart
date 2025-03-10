import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/task/task_bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/task_details.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/colors/colors.dart';
import 'package:tasko/utils/conversion_util.dart';

class UnassignedProjectTaskScreen extends StatefulWidget {
  final String? projectId;
  final String? projectName;

  const UnassignedProjectTaskScreen(
      {super.key, required this.projectId, required this.projectName});

  @override
  State<UnassignedProjectTaskScreen> createState() =>
      _UnassignedProjectTaskScreenState();
}

class _UnassignedProjectTaskScreenState
    extends State<UnassignedProjectTaskScreen> {
  String? projectId;
  String? projectName;
  TaskBloc? taskBloc;
  String? userId;
  int page = 1;
  int limit = 11;
  List<TaskDetails>? taskList;
  bool isLastTask = false, textClear = false;

  TextEditingController? _searchController;
  FocusNode? _searchFocusNode;
  ScrollController? scrollController;
  Timer? debounceTimer;
  List<String>? selectedTask;
  String? orgId;

  @override
  void initState() {
    projectId = widget.projectId;
    projectName = widget.projectName;
    orgId = UserDetailsDataStore.getSelectedOrganizationId;
    taskBloc = BlocProvider.of<TaskBloc>(context);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    scrollController = ScrollController();
    userId = FirebaseAuth.instance.currentUser!.uid;
    getTasksByProject();
    scrollController!.addListener(loadMore);
    super.initState();
  }

  loadMore() {
    double maxScroll = scrollController!.position.maxScrollExtent;
    double offset = scrollController!.offset;
    bool outOfRange = scrollController!.position.outOfRange;
    if (offset >= maxScroll && !outOfRange && !isLastTask) {
      page = page + 1;
      getTasksByProject();
    }
  }

  getTasksByProject() {
    taskBloc!
        .add(GetUnassignedTask(orgId!, page, limit, _searchController!.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        appBar: buildAppBar(),
        body: BlocListener<TaskBloc, TaskState>(
            bloc: taskBloc,
            listener: (context, state) {
              if (state is GetUnassignedTaskSuccess) {
                if (page == 1) {
                  isLastTask = state.getUnassignedTask.isEmpty;
                  taskList = state.getUnassignedTask;
                } else {
                  isLastTask = state.getUnassignedTask.isEmpty;
                  taskList!.addAll(state.getUnassignedTask);
                }
              } else if (state is GetUnassignedTaskFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is AssignTaskToProjectSuccess) {
                Navigator.pop(context);
                taskList = [];
                getTasksByProject();
                showAlertSnackBar(
                    context,
                    translation(context).taskUpdatedSuccessfully,
                    AlertType.success);
              } else if (state is AssignTaskToProjectFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<TaskBloc, TaskState>(
                bloc: taskBloc,
                builder: (context, state) {
                  if (state is GetUnassignedTaskLoading) {
                    return const Loading();
                  } else {
                    return RefreshIndicator(
                        backgroundColor: bgColor,
                        color: primaryColor,
                        onRefresh: () {
                          page = 1;
                          getTasksByProject();
                          return Future.value();
                        },
                        child: _buildBody());
                  }
                })),
        bottomNavigationBar: _buildBottomAppBar());
  }

  Widget _buildBody() {
    return Column(children: [
      SizedBox(height: 5.h),
      Padding(
        padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 2.h),
        child: _buildSearchTextField(),
      ),
      (taskList != null && taskList!.isNotEmpty)
          ? Expanded(
              child: SingleChildScrollView(
                  controller: scrollController, child: _buildTaskCard()))
          : Expanded(
              child: Center(
                  child: Text(translation(context).noTasksAvailable,
                      style: TextStyle(fontSize: 16.sp, color: greyTextColor))))
    ]);
  }

  Widget _buildSearchTextField() {
    return TextFormField(
        enabled: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onChanged: (value) {
          setState(() {
            textClear = value.isEmpty ? false : true;
          });
          if (debounceTimer != null) debounceTimer!.cancel();
          debounceTimer = Timer(const Duration(milliseconds: 1000), () {
            if (value.isNotEmpty) {
              page = 1;
              getTasksByProject();
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
            suffixIcon: textClear
                ? GestureDetector(
                    onTap: () {
                      if (_searchController!.text.isNotEmpty &&
                          _searchController != null) {
                        setState(() {
                          _searchController!.clear();
                          page = 1;
                          taskList = [];
                          textClear = false;
                        });
                        getTasksByProject();
                      }
                    },
                    child: const Icon(Icons.clear, color: black))
                : const SizedBox(),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: white,
            hintText: translation(context).searchTask,
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
                EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w)),
        style: const TextStyle(color: lightTextColor));
  }

  Widget _buildTaskCard() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 5.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: !isLastTask ? taskList!.length + 1 : taskList!.length,
      itemBuilder: (context, index) {
        if (index == taskList!.length) {
          return isLastTask || taskList!.length < limit
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 40,
                      width: 40,
                      child: const Loading(),
                    ),
                  ],
                );
        } else {
          final task = taskList![index];
          final taskName = task.taskName ?? '';
          final taskOwnerName = ConvertionUtil.convertSingleName(
            task.taskOwner?.firstName ?? '',
            task.taskOwner?.lastName ?? '',
          );
          final taskEndTime = task.taskEndTime;
          final projectName = task.project?.projectName;
          final userProfilePic = task.taskOwner?.profileUrl;

          return Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: GestureDetector(
              onTap: () async {
                var result = await Navigator.of(context).pushNamed(
                  PageName.updateTaskScreen,
                  arguments: {
                    'taskId': task.taskId,
                    'projectId': null,
                    'projectName': null
                  },
                );
                if (result != null && result is bool && result && mounted) {
                  getTasksByProject();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 12.w),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: primaryColor,
                      value: selectedTask?.contains(task.taskId) ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedTask ??= [];
                            if (!selectedTask!.contains(task.taskId)) {
                              selectedTask?.add(task.taskId!);
                            }
                          } else {
                            selectedTask?.remove(task.taskId!);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  taskName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: task.isCompleted == true
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (userProfilePic != null &&
                                  userProfilePic.isNotEmpty)
                                UserAvatar(
                                  radius: 10.r,
                                  profileURL: userProfilePic,
                                )
                              else if (taskOwnerName.isNotEmpty)
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: getAvatarColor(index),
                                  child: Text(
                                    getInitials(taskOwnerName),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (taskEndTime != null && taskEndTime.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    "${translation(context).dueDate}: ${ConvertionUtil.convertLocalDateMonthFromString(taskEndTime)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: greyTextColor,
                                    ),
                                  ),
                                ),
                              if (projectName != null && projectName.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    projectName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: greyTextColor,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(height: 70, color: bgColor, child: _buildSubmitBtn());
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
        if (selectedTask != null) {
          progress(context);
          taskBloc!.add(AssignTaskToProject(projectId!, selectedTask!));
        } else {
          showAlertSnackBar(
              context, 'Select any task to assign', AlertType.info);
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

  AppBar buildAppBar() {
    return AppBar(
        backgroundColor: bgColor,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 3.h),
                child: CircleAvatar(
                    radius: 25.r,
                    backgroundColor: lightGreyColor,
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: const Icon(Icons.arrow_back_ios,
                            color: greyIconColor))))),
        centerTitle: true,
        title: Text(
          projectName!,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
        ));
  }
}
