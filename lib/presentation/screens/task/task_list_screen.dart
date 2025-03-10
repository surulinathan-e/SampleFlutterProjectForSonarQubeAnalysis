import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/search_suggestion.dart';
import 'package:tasko/data/model/task_details.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tasko/utils/utils.dart';

class TaskListScreen extends StatefulWidget {
  final Function? onBack;
  final bool? isCreateTask;
  const TaskListScreen({super.key, this.onBack, this.isCreateTask});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TextEditingController? _taskNameController,
      _searchController,
      _taskAssignToController,
      _searchUserController,
      _searchProjectController,
      _taskProjectController;
  FocusNode? _searchFocusNode;
  FocusNode? _searchProjectFocusNode;
  FocusNode? _searchUserFocusNode;
  ScrollController? scrollController;
  TaskBloc? taskBloc;
  UserBloc? userBloc;
  AdminBloc? adminBloc;
  String? orgId;
  String? userId;
  String? assignedUserId;
  String? projectId;
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int page = 1;
  int limit = 15;
  bool isLastTask = false;
  bool isLastProject = false;
  bool isProjectListDisplay = false, textClear = false;
  List<TaskDetails>? taskList;
  List<ProjectDetails>? projectList;
  String? _selectedFilter;
  String? projectName;
  bool isLoading = false, isCreateTaskEnabled = false;
  Timer? debounceTimer;
  List<UserProfile>? usersList = [];
  bool isLastUser = false, suggestionNotFound = false;
  List<String> filteredSuggestions = [];
  String? searchType = "GetAllTask";
  String? priorityKey;
  List<SearchSuggestion>? searchKeySuggestion;
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    taskBloc = BlocProvider.of<TaskBloc>(context);
    userBloc = BlocProvider.of<UserBloc>(context);
    adminBloc = BlocProvider.of<AdminBloc>(context);
    _taskNameController = TextEditingController();
    _searchController = TextEditingController();
    _taskAssignToController = TextEditingController();
    _taskProjectController = TextEditingController();
    scrollController = ScrollController();
    _searchProjectController = TextEditingController();
    _searchUserController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchProjectFocusNode = FocusNode();
    _searchUserFocusNode = FocusNode();
    userId = UserDetailsDataStore.getCurrentFirebaseUserID;
    orgId = UserDetailsDataStore.getSelectedOrganizationId;
    isCreateTaskEnabled = widget.isCreateTask ?? false;
    netWorkStatusCheck();
    scrollController!.addListener(loadMore);
    // if (isCreateTaskEnabled) {
    //   Future.delayed(Duration.zero, () async {
    //     _showCreateTaskForm();
    //   });
    // }
    super.initState();
  }

  netWorkStatusCheck() async {
    await connectivityCheck().then((internet) {
      if (!internet && mounted) {
        showModal(context, () {
          getTaskFilters();
        });
      } else {
        getTaskFilters();
      }
    });
  }

  searchKeySuggestionByOrd() {
    taskBloc!.add(GetSearchSuggestion(
        orgId!, _searchController!.text, searchType!, priorityKey ?? ''));
  }

  getTaskFilters() {
    taskBloc!.add(GetTaskFilters(orgId!, page, limit,
        _searchController!.text.trim(), searchType!, priorityKey ?? ''));
  }

  getAllTasksByProject() {
    taskBloc!.add(GetAllTasksByProject(orgId!, page, limit,
        _searchController!.text.trim(), 'GetAllProject', ''));
  }

  getAllUsers() {
    adminBloc!.add(GetUsersByOrganization(
        UserDetailsDataStore.getSelectedOrganizationId!,
        page,
        limit,
        _searchUserController!.text));
  }

  getAllProjects() {
    taskBloc!.add(GetAllTasksByProject(orgId!, page, limit,
        _searchProjectController!.text.trim(), 'GetAllProject', ''));
  }

  taskFilters(String filter) {
    page = 1;
    setState(() {
      _selectedFilter = filter;
    });
    if (_selectedFilter == null ||
        _selectedFilter == translation(context).allTasks) {
      isProjectListDisplay = false;
      searchType = "GetAllTask";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).assignToMe) {
      isProjectListDisplay = false;
      searchType = "AssignedToMe";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).createdByMe) {
      isProjectListDisplay = false;
      searchType = "CreatedByMe";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).overdueTasks) {
      isProjectListDisplay = false;
      searchType = "OverDue";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).completedTasks) {
      isProjectListDisplay = false;
      searchType = "Completed";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).groupByProject) {
      isProjectListDisplay = true;
      searchType = "GetAllProject";
      getAllTasksByProject();
    } else if (_selectedFilter == translation(context).high) {
      isProjectListDisplay = false;
      searchType = "Priority";
      priorityKey = "High";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).medium) {
      isProjectListDisplay = false;
      searchType = "Priority";
      priorityKey = "Medium";
      getTaskFilters();
    } else if (_selectedFilter == translation(context).low) {
      isProjectListDisplay = false;
      searchType = "Priority";
      priorityKey = "Low";
      getTaskFilters();
    }
  }

  Future<void> loadMore() async {
    if (isLoading && (isLastTask || isLastProject)) return;

    double maxScroll = scrollController!.position.maxScrollExtent;
    double offset = scrollController!.offset;

    if (offset >= maxScroll && !scrollController!.position.outOfRange) {
      isLoading = true;
      page = page + 1;

      try {
        if (_selectedFilter == null ||
            _selectedFilter == translation(context).allTasks ||
            _selectedFilter == translation(context).assignToMe ||
            _selectedFilter == translation(context).createdByMe ||
            _selectedFilter == translation(context).overdueTasks ||
            _selectedFilter == translation(context).completedTasks) {
          await getTaskFilters();
        } else if (_selectedFilter == translation(context).groupByProject) {
          await getAllTasksByProject();
        }
      } finally {
        isLoading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: bgColor,
        body: BlocListener<TaskBloc, TaskState>(
            bloc: taskBloc,
            listener: (context, state) {
              if (state is CreateTaskSuccess) {
                _taskNameController!.clear();
                _taskProjectController!.clear();
                _taskAssignToController!.clear();
                assignedUserId = '';
                projectId = '';
                Navigator.pop(context);
                taskFilters(translation(context).allTasks);
                Navigator.pushNamed(context, PageName.updateTaskScreen);
                showAlertSnackBar(
                    context,
                    translation(context).taskCreatedSuccessfully,
                    AlertType.success);
              } else if (state is CreateTaskFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is GetAllTasksByProjectSuccess) {
                if (page == 1) {
                  isLastProject = state.getAllTaskByProject.isEmpty;
                  projectList = state.getAllTaskByProject;
                } else {
                  isLastProject = state.getAllTaskByProject.isEmpty;
                  projectList!.addAll(state.getAllTaskByProject);
                }
              } else if (state is GetAllTasksByProjectFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is GetSearchSuggestionSuccess) {
                searchKeySuggestion = state.getSearchSuggestion;
                suggestionNotFound = true;
              } else if (state is GetSearchSuggestionFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is GetTaskFiltersSuccess) {
                if (page == 1) {
                  isLastTask = state.tasks.isEmpty;
                  taskList = state.tasks;
                } else {
                  isLastTask = state.tasks.isEmpty;
                  taskList!.addAll(state.tasks);
                }
              } else if (state is GetTaskFiltersFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<TaskBloc, TaskState>(
                bloc: taskBloc,
                builder: (context, state) {
                  if (state is CreateTaskLoading ||
                      state is GetAllTasksByProjectLoading ||
                      state is GetTaskFiltersLoading) {
                    return const Loading();
                  } else {
                    return RefreshIndicator(
                        backgroundColor: bgColor,
                        color: primaryColor,
                        onRefresh: () {
                          page = 1;
                          taskFilters(
                              _selectedFilter ?? translation(context).allTasks);
                          return Future.value();
                        },
                        child: _buildBody());
                  }
                })),
        bottomNavigationBar: _buildBottomAppBar());
  }

  AppBar _buildAppBar() {
    return AppBar(
        backgroundColor: bgColor,
        leading: GestureDetector(
            onTap: () {
              widget.onBack!();
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
        actions: [
          ElevatedButton(
              onPressed: () async {
                var result = await Navigator.pushNamed(
                    context, PageName.projectListScreen,
                    arguments: {'isCreateProject': false});
                if (result == true && mounted) {
                  taskFilters(translation(context).allTasks);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text(translation(context).projects,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500))),
          SizedBox(width: 5.w)
        ]);
  }

  Widget _buildBody() {
    return Stack(children: [
      Column(children: [
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 2.h),
          child: _buildSearchTextField(),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildHeadingText(_selectedFilter ?? translation(context).allTasks),
          _buildFilterText(translation(context).filter),
        ]),
        (taskList != null && taskList!.isNotEmpty)
            ? Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: isProjectListDisplay &&
                          projectList != null &&
                          projectList!.isNotEmpty
                      ? _buildProjectCard()
                      : _buildTaskCard(),
                ),
              )
            : Expanded(
                child: Center(
                    child: Text(
                        isProjectListDisplay
                            ? translation(context).noProjectsAvailabe
                            : translation(context).noTasksAvailable,
                        style:
                            TextStyle(fontSize: 16.sp, color: greyTextColor))))
      ]),
      (searchKeySuggestion != null && searchKeySuggestion!.isNotEmpty)
          ? Positioned(
              top: 50.h,
              left: 8.w,
              right: 8.w,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: white,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: searchKeySuggestion!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(searchKeySuggestion![index].name ?? ''),
                            onTap: () {
                              setState(() {
                                _searchController!.text =
                                    searchKeySuggestion![index].name!;
                                searchKeySuggestion = [];
                                suggestionNotFound = false;
                              });
                              taskFilters(_selectedFilter ??
                                  translation(context).allTasks);
                            });
                      })))
          : suggestionNotFound
              ? Positioned(
                  top: 50.h,
                  left: 8.w,
                  right: 8.w,
                  child: Material(
                      elevation: 4.0,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              searchType == "GetAllProject"
                                  ? translation(context).projectNotFound
                                  : translation(context).noTasksAvailable,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center))))
              : const SizedBox.shrink()
    ]);
  }

  Widget _buildSearchTextField() {
    return Column(
      children: [
        TextFormField(
          enabled: true,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onChanged: (value) {
            setState(() {
              textClear = value.isNotEmpty ? true : false;
              if (searchKeySuggestion != null) {
                filteredSuggestions = searchKeySuggestion!
                    .where((suggestion) =>
                        suggestion.name
                            ?.toLowerCase()
                            .contains(value.toLowerCase()) ??
                        false)
                    .map((suggestion) => suggestion.name!)
                    .toList();
              } else {
                filteredSuggestions = [];
              }
            });

            if (debounceTimer != null) debounceTimer!.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 500), () {
              if (value.isNotEmpty) {
                searchKeySuggestionByOrd();
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
                          projectList = [];
                          textClear = false;
                          filteredSuggestions = [];
                          searchKeySuggestion = [];
                          suggestionNotFound = false;
                        });
                        taskFilters(
                            _selectedFilter ?? translation(context).allTasks);
                      }
                    },
                    child: const Icon(Icons.clear, color: black),
                  )
                : const SizedBox(),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: white,
            hintText: isProjectListDisplay
                ? translation(context).searchProject
                : translation(context).searchTask,
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
        ),
      ],
    );
  }

  Widget _buildHeadingText(String text) {
    return Padding(
        padding: EdgeInsets.only(left: 8.h),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600)));
  }

  Widget _buildFilterText(String text) {
    return Padding(
        padding: EdgeInsets.only(right: 8.h),
        child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        backgroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r)),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                        title: Text(
                                            translation(context).assignToMe,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          _searchController!.clear();
                                          textClear = false;
                                          taskFilters(
                                              translation(context).assignToMe);
                                        }),
                                    ListTile(
                                        title: Text(
                                            translation(context).createdByMe,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          _searchController!.clear();
                                          textClear = false;
                                          taskFilters(
                                              translation(context).createdByMe);
                                        }),
                                    ListTile(
                                        title: Text(
                                            translation(context).allTasks,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          textClear = false;
                                          _searchController!.clear();
                                          taskFilters(
                                              translation(context).allTasks);
                                        }),
                                    ExpansionTile(
                                      title: Text(translation(context).priority,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500)),
                                      collapsedShape:
                                          const RoundedRectangleBorder(
                                        side: BorderSide.none,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        side: BorderSide.none,
                                      ),
                                      children: [
                                        ListTile(
                                            title: Text(
                                                translation(context).high,
                                                style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              textClear = false;
                                              _searchController!.clear();
                                              taskFilters(
                                                  translation(context).high);
                                            }),
                                        ListTile(
                                            title: Text(
                                                translation(context).medium,
                                                style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              textClear = false;
                                              _searchController!.clear();
                                              taskFilters(
                                                  translation(context).medium);
                                            }),
                                        ListTile(
                                            title: Text(
                                                translation(context).low,
                                                style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              textClear = false;
                                              _searchController!.clear();
                                              taskFilters(
                                                  translation(context).low);
                                            }),
                                      ],
                                    ),
                                    ListTile(
                                        title: Text(
                                            translation(context).overdueTasks,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          textClear = false;
                                          _searchController!.clear();
                                          taskFilters(translation(context)
                                              .overdueTasks);
                                        }),
                                    ListTile(
                                        title: Text(
                                            translation(context).completedTasks,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          textClear = false;
                                          _searchController!.clear();
                                          taskFilters(translation(context)
                                              .completedTasks);
                                        }),
                                    ListTile(
                                        title: Text(
                                            translation(context).groupByProject,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          textClear = false;
                                          _searchController!.clear();
                                          taskFilters(translation(context)
                                              .groupByProject);
                                        })
                                  ]));
                        }));
                  });
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.filter_list_rounded, size: 24, color: black),
              SizedBox(width: 5.w),
              Text(text,
                  style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600))
            ])));
  }

  Widget _buildTaskCard() {
    return Column(
      children: [
        ListView.builder(
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

                  if (result == true && context.mounted) {
                    taskFilters(translation(context).allTasks);
                  }
                },
                onCheckboxChanged: (value) {
                  // setState(() {
                  //   task.isCompleted = value ?? false;
                  // });
                },
              );
            }
          },
        ),
        SizedBox(height: 50.h)
      ],
    );
  }

  Widget _buildProjectCard() {
    return ListView.builder(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 5.h),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount:
            !isLastProject ? projectList!.length + 1 : projectList!.length,
        itemBuilder: (context, index) {
          if (index == projectList!.length) {
            return isLastProject || projectList!.length < limit
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Container(
                            margin: const EdgeInsets.only(top: 10),
                            height: 40,
                            width: 40,
                            child: const Loading())
                      ]);
          } else {
            final project = projectList![index];
            return Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: GestureDetector(
                    onTap: () {
                      final projectDetails = projectList![index];
                      Navigator.of(context).pushNamed(
                          PageName.projectTaskListScreen,
                          arguments: {
                            'isProjectTask': false,
                            'project': projectDetails
                          });
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                  color: boxShadowBlackColor,
                                  blurRadius: 1,
                                  offset: Offset(0, 2))
                            ]),
                        padding: EdgeInsets.only(
                            right: 5.w, left: 5.w, top: 4.h, bottom: 4.h),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Container(
                                            width: 40.w,
                                            height: 35.h,
                                            decoration: BoxDecoration(
                                                color: getAvatarColor(index),
                                                borderRadius:
                                                    BorderRadius.circular(3.r)),
                                            alignment: Alignment.center,
                                            child: Text(
                                                getInitials(
                                                    project.projectName ?? ''),
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        SizedBox(width: 10.w),
                                        Text(project.projectName ?? '',
                                            style:
                                                const TextStyle(fontSize: 16))
                                      ])
                                    ])
                              ])),
                          Row(children: [
                            (projectList![index].taskCount != null &&
                                    projectList![index].taskCount! > 0)
                                ? CircleAvatar(
                                    radius: 13.r,
                                    backgroundColor: primaryColor,
                                    child: Text(
                                        projectList![index]
                                            .taskCount
                                            .toString(),
                                        style: TextStyle(
                                            color: white, fontSize: 12.sp)))
                                : const SizedBox()
                          ])
                        ]))));
          }
        });
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
        height: 70, color: bgColor, child: _buildCreateTaskButton());
  }

  Widget _buildCreateTaskButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, minimumSize: Size.fromHeight(40.h)),
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, PageName.updateTaskScreen);
          if (mounted) {
            if (result == true) {
              taskFilters(translation(context).allTasks);
            }
          }
        },
        child: Text(translation(context).createTask,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                color: white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500)));
  }

  // Future<void> _showCreateTaskForm() {
  //   return showModalBottomSheet(
  //       isDismissible: false,
  //       shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
  //       backgroundColor: white,
  //       context: context,
  //       isScrollControlled: true,
  //       elevation: 0,
  //       builder: (BuildContext context) {
  //         return Form(
  //             key: _formKey,
  //             child: Padding(
  //                 padding: EdgeInsets.only(
  //                     bottom: MediaQuery.of(context).viewInsets.bottom),
  //                 child: Container(
  //                     padding: EdgeInsets.all(10.h),
  //                     child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Center(
  //                               child: Text(translation(context).createTask,
  //                                   style: const TextStyle(fontSize: 18))),
  //                           const SizedBox(height: 10.0),
  //                           TextFormField(
  //                               onTapOutside: (event) {
  //                                 FocusManager.instance.primaryFocus?.unfocus();
  //                               },
  //                               controller: _taskNameController,
  //                               cursorColor: lightTextColor,
  //                               keyboardType: TextInputType.name,
  //                               style: TextStyle(
  //                                   fontSize: 12.sp,
  //                                   color: lightTextColor,
  //                                   fontFamily: 'Poppins',
  //                                   fontWeight: FontWeight.w600),
  //                               decoration: InputDecoration(
  //                                   border: OutlineInputBorder(
  //                                       borderRadius:
  //                                           BorderRadius.circular(15.r),
  //                                       borderSide: BorderSide(width: 2.w)),
  //                                   enabledBorder: OutlineInputBorder(
  //                                       borderRadius:
  //                                           BorderRadius.circular(15.r),
  //                                       borderSide: BorderSide(
  //                                           color:
  //                                               greyBorderColor.withValues(alpha:.2),
  //                                           width: 2.w)),
  //                                   focusedBorder: OutlineInputBorder(
  //                                       borderRadius:
  //                                           BorderRadius.circular(15.r),
  //                                       borderSide: BorderSide(
  //                                           color: greyBorderColor,
  //                                           width: 2.w)),
  //                                   filled: true,
  //                                   fillColor: white,
  //                                   contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 20.w, vertical: 10.h),
  //                                   hintText: translation(context).taskName,
  //                                   hintStyle: TextStyle(
  //                                       fontSize: 12.sp,
  //                                       color: lightTextColor.withValues(alpha:.5),
  //                                       fontFamily: 'Poppins',
  //                                       fontWeight: FontWeight.w500)),
  //                               validator: (value) {
  //                                 if (value!.isEmpty) {
  //                                   return translation(context)
  //                                       .pleaseEnterTaskName;
  //                                 }
  //                                 return null;
  //                               }),
  //                           const SizedBox(height: 10.0),
  //                           taskAssignToTextBox(),
  //                           const SizedBox(height: 10.0),
  //                           taskProjectTextBox(),
  //                           const SizedBox(height: 10.0),
  //                           Row(
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 TextButton(
  //                                     onPressed: () {
  //                                       _taskNameController!.clear();
  //                                       _taskAssignToController!.clear();
  //                                       _taskProjectController!.clear();
  //                                       projectId = '';
  //                                       assignedUserId = '';
  //                                       Navigator.pop(context);
  //                                     },
  //                                     child: Text(translation(context).cancel,
  //                                         style: const TextStyle(
  //                                             color: greyTextColor))),
  //                                 ElevatedButton(
  //                                     onPressed: () {
  // if (_formKey.currentState!.validate()) {
  //   taskBloc!.add(CreateTask(
  //       _taskNameController!.text.trim(),
  //       userId!,
  //       orgId!,
  //       projectId,
  //       assignedUserId));
  // }
  //                                     },
  //                                     style: ElevatedButton.styleFrom(
  //                                         backgroundColor: primaryColor),
  //                                     child: Text(translation(context).create,
  //                                         style: const TextStyle(color: white)))
  //                               ])
  //                         ]))));
  //       });
  // }

  Widget taskAssignToTextBox() {
    return TextFormField(
      controller: _taskAssignToController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: white,
        prefixIcon: const Icon(Icons.people_alt_rounded),
        hintText: translation(context).assignTo,
        hintStyle: TextStyle(color: lightTextColor.withValues(alpha: .5)),
        suffixIcon: _taskAssignToController!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: lightTextColor),
                onPressed: () {
                  setState(() {
                    _taskAssignToController!.clear();
                    assignedUserId = '';
                  });
                },
              )
            : const SizedBox(),
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
        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      ),
      style: TextStyle(
          fontSize: 12.sp,
          color: lightTextColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600),
      onTap: () {
        getAllUsers();
        _showAssignToBottomSheet();
      },
    );
  }

  void _showAssignToBottomSheet() {
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
                          child: Text(translation(context).assignTo,
                              style: const TextStyle(fontSize: 18))),
                      const SizedBox(height: 10),
                      Text(translation(context).membersList,
                          style: const TextStyle(
                              fontSize: 12, color: greyTextColor),
                          textAlign: TextAlign.left),
                      const SizedBox(height: 10),
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
                        controller: _searchUserController,
                        focusNode: _searchUserFocusNode,
                        maxLines: 1,
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () {
                              if (_searchUserController!.text.isNotEmpty &&
                                  _searchUserController != null) {
                                setState(() {
                                  _searchUserController!.clear();
                                  page = 1;
                                  usersList = [];
                                  textClear = false;
                                });
                                getAllUsers();
                              }
                            },
                            child: const Icon(Icons.clear, color: black),
                          ),
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
                                  color: greyBorderColor.withValues(alpha: .2),
                                  width: 1.w)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(
                                  color: greyBorderColor, width: 1.w)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 10.w),
                        ),
                        style: const TextStyle(color: lightTextColor),
                      ),
                      const SizedBox(height: 10),
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
                        },
                        child: BlocBuilder<AdminBloc, AdminState>(
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
                                                  leading: (usersList![index]
                                                                  .profileUrl !=
                                                              null &&
                                                          usersList![index]
                                                              .profileUrl!
                                                              .isNotEmpty)
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
                                                              style: const TextStyle(
                                                                  color:
                                                                      white))),
                                                  title: Text(userName),
                                                  onTap: () {
                                                    setState(() {
                                                      _taskAssignToController!
                                                          .text = userName;
                                                      assignedUserId =
                                                          usersList![index]
                                                              .userId!;
                                                      _searchUserController!
                                                          .clear();
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
                      ),
                    ])),
          );
        });
  }

  Widget taskProjectTextBox() {
    return TextFormField(
      controller: _taskProjectController,
      readOnly: true,
      decoration: InputDecoration(
          filled: true,
          fillColor: white,
          prefixIcon: const Icon(Icons.work_history_rounded),
          hintText: translation(context).projects,
          hintStyle: TextStyle(color: lightTextColor.withValues(alpha: .5)),
          suffixIcon: _taskProjectController!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: lightTextColor),
                  onPressed: () {
                    setState(() {
                      _taskProjectController!.clear();
                      projectId = '';
                    });
                  },
                )
              : const SizedBox(),
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
      style: TextStyle(
          fontSize: 12.sp,
          color: lightTextColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600),
      onTap: () {
        getAllProjects();
        _showProjectBottomSheet();
      },
    );
  }

  void _showProjectBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: white,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 400,
                color: white,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                          child: Text(translation(context).projects,
                              style: const TextStyle(fontSize: 18))),
                      const SizedBox(height: 10),
                      Text(translation(context).projectList,
                          style: const TextStyle(
                              fontSize: 12, color: greyTextColor),
                          textAlign: TextAlign.left),
                      const SizedBox(height: 10),
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
                                getAllProjects();
                              }
                            });
                          },
                          controller: _searchProjectController,
                          focusNode: _searchProjectFocusNode,
                          maxLines: 1,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    if (_searchProjectController!
                                            .text.isNotEmpty &&
                                        _searchProjectController != null) {
                                      setState(() {
                                        _searchProjectController!.clear();
                                        page = 1;
                                        projectList = [];
                                        textClear = false;
                                      });
                                      getAllProjects();
                                    }
                                  },
                                  child: const Icon(Icons.clear, color: black)),
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: white,
                              hintText: translation(context).searchProject,
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
                                  vertical: 10.h, horizontal: 10.w)),
                          style: const TextStyle(color: lightTextColor)),
                      const SizedBox(height: 10),
                      BlocListener<TaskBloc, TaskState>(
                        bloc: taskBloc,
                        listener: (context, state) {
                          if (state is GetAllTasksByProjectSuccess) {
                            if (page == 1) {
                              isLastProject = state.getAllTaskByProject.isEmpty;
                              projectList = state.getAllTaskByProject;
                            } else {
                              isLastProject = state.getAllTaskByProject.isEmpty;
                              projectList!.addAll(state.getAllTaskByProject);
                            }
                          } else if (state is GetAllTasksByProjectFailed) {
                            showAlertSnackBar(
                                context, state.errorMessage, AlertType.error);
                          }
                        },
                        child: BlocBuilder<TaskBloc, TaskState>(
                            bloc: taskBloc,
                            builder: (context, state) {
                              if (state is GetAllTasksByProjectLoading) {
                                return const Loading();
                              } else {
                                return Expanded(
                                    child: projectList != null &&
                                            projectList!.isNotEmpty
                                        ? ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: projectList!.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String? projectName =
                                                  projectList![index]
                                                      .projectName;
                                              return ListTile(
                                                  leading: Container(
                                                      width: 30.w,
                                                      height: 25.h,
                                                      decoration: BoxDecoration(
                                                        color: getAvatarColor(
                                                            index),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.r),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                          getInitials(
                                                              projectName!),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      white))),
                                                  title: Text(projectName),
                                                  onTap: () {
                                                    setState(() {
                                                      _taskProjectController!
                                                          .text = projectName;
                                                      projectId =
                                                          projectList![index]
                                                              .projectId!;
                                                      _searchProjectController!
                                                          .clear();
                                                    });
                                                    Navigator.pop(context);
                                                  });
                                            })
                                        : Center(
                                            child: Text(
                                              translation(context)
                                                  .projectNotFound,
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: greyTextColor),
                                            ),
                                          ));
                              }
                            }),
                      )
                    ])),
          );
        });
  }
}
