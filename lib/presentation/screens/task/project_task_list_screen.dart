import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/task_details.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/colors/colors.dart';

class ProjectTaskListScreen extends StatefulWidget {
  final bool? isProjectTask;
  final ProjectDetails? project;

  const ProjectTaskListScreen({super.key, this.isProjectTask, this.project});

  @override
  State<ProjectTaskListScreen> createState() => _ProjectTaskListScreenState();
}

class _ProjectTaskListScreenState extends State<ProjectTaskListScreen> {
  ProjectDetails? project;
  TaskBloc? taskBloc;
  String? userId;
  String? projectId;
  int page = 1;
  int limit = 13;
  bool isLastTask = false, textClear = false;
  bool? isProjectTask, isProjectUpdate = false;
  List<TaskDetails>? taskList;

  TextEditingController? _searchController;
  FocusNode? _searchFocusNode;
  ScrollController? scrollController;
  Timer? debounceTimer;

  @override
  void initState() {
    project = widget.project;
    isProjectTask = widget.isProjectTask;
    taskBloc = BlocProvider.of<TaskBloc>(context);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    scrollController = ScrollController();
    userId = FirebaseAuth.instance.currentUser!.uid;
    projectId = project!.projectId!;
    isProjectTask! ? getTasksByProject() : getTasksByProjectAndUser();
    scrollController!.addListener(loadMore);
    super.initState();
  }

  loadMore() {
    double maxScroll = scrollController!.position.maxScrollExtent;
    double offset = scrollController!.offset;
    bool outOfRange = scrollController!.position.outOfRange;
    if (offset >= maxScroll && !outOfRange && !isLastTask) {
      page = page + 1;
      isProjectTask! ? getTasksByProject() : getTasksByProjectAndUser();
    }
  }

  getTasksByProjectAndUser() {
    taskBloc!.add(GetTasksByProjectAndUser(
        userId!, projectId!, page, limit, _searchController!.text));
  }

  getTasksByProject() {
    taskBloc!.add(
        GetTasksByProject(projectId!, page, limit, _searchController!.text));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(isProjectUpdate);
        return Future.value();
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(180)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                            leading: const Icon(Icons.task_alt),
                            title: Text(translation(context).createNewTask,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500)),
                            onTap: () async {
                              Navigator.pop(context);
                              final result = await Navigator.pushNamed(
                                context,
                                PageName.updateTaskScreen,
                                arguments: {
                                  'taskId': null,
                                  'projectId': projectId,
                                  'projectName': project!.projectName!
                                },
                              );
                              if (result == true) {
                                isProjectUpdate = true;
                                getTasksByProject();
                              }
                            }),
                        ListTile(
                          leading: const Icon(Icons.add_box),
                          title: Text(translation(context).addExistingTasks,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500)),
                          onTap: () async {
                            Navigator.pop(context);
                            final result = await Navigator.pushNamed(
                                context, PageName.unassignedProjectTaskScreen,
                                arguments: {
                                  'projectId': projectId,
                                  'projectName': project!.projectName!
                                });
                            if (mounted) {
                              if (result == true) {
                                isProjectUpdate = true;
                                getTasksByProject();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add, color: white)),
        backgroundColor: bgColor,
        appBar: buildAppBar(),
        body: BlocListener<TaskBloc, TaskState>(
            bloc: taskBloc,
            listener: (context, state) {
              if (state is GetTasksByProjectAndUserSuccess) {
                if (page == 1) {
                  isLastTask = state.getTasksByProjectAndUser.isEmpty;
                  taskList = state.getTasksByProjectAndUser;
                } else {
                  isLastTask = state.getTasksByProjectAndUser.isEmpty;
                  taskList!.addAll(state.getTasksByProjectAndUser);
                }
              } else if (state is GetTasksByProjectAndUserFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is GetTasksByProjectSuccess) {
                if (page == 1) {
                  isLastTask = state.getTasksByProject.isEmpty;
                  taskList = state.getTasksByProject;
                } else {
                  isLastTask = state.getTasksByProject.isEmpty;
                  taskList!.addAll(state.getTasksByProject);
                }
              } else if (state is GetTasksByProjectFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<TaskBloc, TaskState>(
                bloc: taskBloc,
                builder: (context, state) {
                  if (state is GetTasksByProjectAndUserLoading ||
                      state is GetTasksByProjectLoading) {
                    return const Loading();
                  } else {
                    return RefreshIndicator(
                        backgroundColor: bgColor,
                        color: primaryColor,
                        onRefresh: () {
                          page = 1;
                          isProjectTask!
                              ? getTasksByProject()
                              : getTasksByProjectAndUser();
                          return Future.value();
                        },
                        child: _buildBody());
                  }
                })),
        // bottomNavigationBar: _buildBottomAppBar()
      ),
    );
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
        // onEditingComplete: () {
        //   if (_searchController!.text.isNotEmpty && _searchController != null) {
        //     page = 1;
        //     isProjectTask! ?getTasksByProject() : getTasksByProjectAndUser();
        //   }
        // },
        // onChanged: (value) {
        //   setState(() {
        //     textClear = value.isEmpty ? false : true;
        //   });
        // },
        onChanged: (value) {
          setState(() {
            textClear = value.isEmpty ? false : true;
          });
          if (debounceTimer != null) debounceTimer!.cancel();
          debounceTimer = Timer(const Duration(milliseconds: 1000), () {
            if (value.isNotEmpty) {
              page = 1;
              isProjectTask! ? getTasksByProject() : getTasksByProjectAndUser();
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
                        isProjectTask!
                            ? getTasksByProject()
                            : getTasksByProjectAndUser();
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
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: !isLastTask ? taskList!.length + 1 : taskList!.length,
        itemBuilder: (context, index) {
          if (index == taskList!.length) {
            return isLastTask || taskList!.length < limit
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
            final task = taskList![index];
            return TaskListWidget(
              task: task,
              index: index,
              onTaskTap: (taskId) async {
                final result = await Navigator.of(context).pushNamed(
                  PageName.updateTaskScreen,
                  arguments: {
                    'taskId': taskId,
                    'projectId': null,
                    'projectName': null
                  },
                );

                if (context.mounted) {
                  if (result == true) {
                    isProjectUpdate = true;
                    isProjectTask!
                        ? getTasksByProject()
                        : getTasksByProjectAndUser();
                  }
                }
              },
              onCheckboxChanged: (value) {
                // setState(() {
                //   task.isCompleted = value ?? false;
                // });
              },
            );
          }
        });
  }

  AppBar buildAppBar() {
    return AppBar(
        backgroundColor: bgColor,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context, isProjectUpdate),
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
          project!.projectName!,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
        ));
  }

  // Widget _buildBottomAppBar() {
  //   return BottomAppBar(
  //       height: 70, color: bgColor, child: _buildCreateTaskButton());
  // }

  // Widget _buildCreateTaskButton() {
  //   return ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //           backgroundColor: primaryColor, minimumSize: Size.fromHeight(40.h)),
  //       onPressed: () async {
  //         final result = await Navigator.pushNamed(
  //           context,
  //           PageName.updateTaskScreen,
  //           arguments: {
  //             'taskId': null,
  //             'projectId': projectId,
  //             'projectName': project!.projectName!
  //           },
  //         );
  //         if (mounted) {
  //           if (result == true) {
  //             getTasksByProject();
  //           }
  //         }
  //       },
  //       child: Text(translation(context).createTask,
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //               fontFamily: 'Poppins',
  //               color: white,
  //               fontSize: 14.sp,
  //               fontWeight: FontWeight.w500)));
  // }
}
