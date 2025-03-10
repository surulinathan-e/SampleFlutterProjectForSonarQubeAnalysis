import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/owner_detail.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/subtask.dart';
import 'package:tasko/data/model/task_comment.dart';
import 'package:tasko/data/model/task_details.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class UpdateTaskScreen extends StatefulWidget {
  final String? taskId;
  final String? projectId;
  final String? projectName;
  const UpdateTaskScreen(
      {super.key,
      required this.taskId,
      required this.projectId,
      required this.projectName});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  TaskBloc? taskBloc;
  AdminBloc? adminBloc;

  final ImagePicker imagePicker = ImagePicker();
  List<File>? selectedPOCFiles = [],
      selectedFiles = [],
      selectedCommentImages = [];
  List<int> removedMediaPotisions = [],
      removedExistingImagePotision = [],
      removedSubtaskPOCImagePosition = [],
      removedSubtaskMediaPositions = [],
      removedSubtaskDocumentPositions = [],
      removedCommentFilePositions = [];
  List<ProjectDetails>? projectList = [];
  int page = 1, limit = 10;
  bool isLastUser = false, isLastProject = false, isCompletedClicked = false;
  List<UserProfile>? usersList = [];
  List<SubTasks>? subTasks = [];
  List<SubTasks>? updatedSubTasks = [];
  List<TaskComment>? taskComments = [];
  List<dynamic>? commentedFiles = [];
  List<String> priorityLevels = ['Low', 'Medium', 'High'];
  TaskComment? commentDetail;
  String? userId,
      firstName,
      lastName,
      taskId,
      taskName,
      taskDescription,
      taskDueDate,
      assignedUserId,
      creatorId,
      creatorName,
      assignedUserName,
      projectName,
      projectId,
      orgId,
      selectedDate,
      taskComment = '',
      commentId,
      updatedPriorityLevel,
      selectedPriority;
  bool? isSubCompleted = false, isPOCFiles = false, isCommentFiles = false;
  bool isSubTaskEqual = true,
      isCompleted = false,
      textClear = false,
      isProofOfCompletion = false,
      isCommentEditEnabled = false;

  String? selectedRepeatOption;

  List<String>? repeatSchedule = [];
  List<String>? updatedRepeatSchedule = [];

  List<TextEditingController>? _subTaskController;
  late TextEditingController? _taskNameController,
      _taskDescriptionController,
      _taskDueDateController,
      _taskAssignToController,
      _taskProjectController,
      _searchUserController,
      _taskCommentController,
      _searchProjectController;

  FocusNode? _taskNameFocusNode,
      _taskDescriptionFocusNode,
      _taskAssignToFocusNode,
      _taskProjectFocusNode,
      _taskCommentFocusNode,
      _searchFocusNode;
  TaskDetails? task;
  Timer? debounceTimer;

  List days = [
    {
      'isSelected': false,
      'value': 'EVERY_MONDAY',
      'day': 'Every Monday',
    },
    {
      'isSelected': false,
      'value': 'EVERY_TUESDAY',
      'day': 'Every Tuesday',
    },
    {
      'isSelected': false,
      'value': 'EVERY_WEDNESDAY',
      'day': 'Every Wednesday',
    },
    {
      'isSelected': false,
      'value': 'EVERY_THURSDAY',
      'day': 'Every Thursday',
    },
    {
      'isSelected': false,
      'value': 'EVERY_FRIDAY',
      'day': 'Every Friday',
    },
    {
      'isSelected': false,
      'value': 'EVERY_SATURDAY',
      'day': 'Every Saturday',
    },
    {
      'isSelected': false,
      'value': 'EVERY_SUNDAY',
      'day': 'Every Sunday',
    },
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    taskId = widget.taskId;
    taskBloc = BlocProvider.of<TaskBloc>(context);
    adminBloc = BlocProvider.of<AdminBloc>(context);
    orgId = UserDetailsDataStore.getSelectedOrganizationId;
    firstName = UserDetailsDataStore.getUserFirstName;
    lastName = UserDetailsDataStore.getUserLastName;
    _subTaskController = [];
    _taskNameController = TextEditingController();
    _taskDescriptionController = TextEditingController();
    _taskDueDateController = TextEditingController();
    _taskAssignToController = TextEditingController();
    _taskProjectController = TextEditingController();
    _searchUserController = TextEditingController();
    _searchProjectController = TextEditingController();
    _taskCommentController = TextEditingController();

    _taskNameFocusNode = FocusNode();
    _taskDescriptionFocusNode = FocusNode();
    _taskAssignToFocusNode = FocusNode();
    _taskProjectFocusNode = FocusNode();
    _searchFocusNode = FocusNode();
    _taskCommentFocusNode = FocusNode();
    userId = FirebaseAuth.instance.currentUser!.uid;

    if (userId != null) {
      assignedUserId = userId ?? '';
      assignedUserName = _taskAssignToController!.text =
          ConvertionUtil.convertSingleName(
              UserDetailsDataStore.getUserFirstName ?? '',
              UserDetailsDataStore.getUserLastName ?? '');
    }

    if (taskId != null) {
      getTaskByUserId();
    }

    if (widget.projectId != null && widget.projectName != null) {
      projectId = widget.projectId ?? '';
      projectName = _taskProjectController!.text = widget.projectName ?? '';
    }

    super.initState();
  }

  @override
  void dispose() {
    _taskNameController!.dispose();
    _taskDescriptionController!.dispose();
    _taskDueDateController!.dispose();
    _taskAssignToController!.dispose();
    _taskProjectController!.dispose();

    _taskNameFocusNode!.dispose();
    _taskDescriptionFocusNode!.dispose();
    _taskAssignToFocusNode!.dispose();
    _taskProjectFocusNode!.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _taskDueDateController!.text =
            DateFormat('dd-MM-yyyy').format(pickedDate);
        selectedDate =
            '${DateFormat('yyyy-MM-dd').format(pickedDate)}T00:00:00.00';
      });
    }
  }

  taskDetailDisplay() {
    if (task != null) {
      taskId = task!.taskId;
      isCompleted = task!.isCompleted ?? false;
      taskName = _taskNameController!.text = task!.taskName ?? '';
      taskDescription =
          _taskDescriptionController!.text = task!.taskDescription ?? '';
      selectedDate = task!.taskEndTime ?? '';
      taskDueDate = _taskDueDateController!.text = task!.taskEndTime != null
          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(task!.taskEndTime!))
          : '';
      assignedUserId = task?.taskOwner?.userId ?? '';
      assignedUserName = _taskAssignToController!.text =
          ConvertionUtil.convertSingleName(task?.taskOwner?.firstName ?? '',
              task?.taskOwner?.lastName ?? '');
      if (task!.taskCreator != null) {
        setState(() {
          creatorId = task!.taskCreator!.userId;
          creatorName = ConvertionUtil.convertSingleName(
              task?.taskCreator?.firstName ?? '',
              task?.taskCreator?.lastName ?? '');
        });
      }
      isCompleted = task!.isCompleted ?? false;
      projectId = task?.project?.projectId ?? '';
      projectName =
          _taskProjectController!.text = task?.project?.projectName ?? '';

      isProofOfCompletion = task!.proofOfCompletion ?? false;
      taskComments =
          task!.taskComments!.map((commentData) => commentData).toList();

      selectedPriority = updatedPriorityLevel = task!.priorityLevel;

      subTasks = task!.subTasks;
      if (subTasks != null) {
        for (var subtask in subTasks!) {
          _subTaskController!.add(TextEditingController());
          _subTaskController![subTasks!.indexOf(subtask)].text =
              subtask.subTaskName ?? '';
          updatedSubTasks!.add(subtask);
        }
      }
      if (task!.repeatShedule == null ||
          task!.repeatShedule!.isEmpty ||
          task!.repeatShedule!.first.isEmpty) {
        updatedRepeatSchedule = repeatSchedule = [];
      } else {
        repeatSchedule = task!.repeatShedule;
        if (task!.repeatShedule!.contains('DAILY')) {
          selectedRepeatOption = 'Daily';
          updatedRepeatSchedule!.add('DAILY');
        } else if (days
            .any((day) => task!.repeatShedule!.contains(day['value']))) {
          selectedRepeatOption = 'Weekly';
          for (var day in days) {
            if (task!.repeatShedule!.contains(day['value'])) {
              day['isSelected'] = true;
              updatedRepeatSchedule!.add(day['value']);
            } else {
              day['isSelected'] = false;
            }
          }
        } else {
          selectedRepeatOption = null;
        }
      }
    }
  }

  getTaskByUserId() {
    taskBloc!.add(GetTaskById(taskId!));
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

  Future getImageFromCamera(bool isPOCFiles, bool isCommentFiles) async {
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    await processPickedImage(pickedImage, isPOCFiles, isCommentFiles);
  }

  processPickedImage(pickedImage, isPOCFiles, isCommentFiles) async {
    var croppedFile = await cropImage(pickedImage);
    setState(() {
      if (croppedFile != null) {
        setState(() {
          isCommentFiles
              ? (selectedCommentImages!.add(File(croppedFile.path)))
              : isPOCFiles
                  ? (selectedPOCFiles!.add(File(croppedFile.path)))
                  : selectedFiles!.add(File(croppedFile.path));
          if (selectedPOCFiles!.isNotEmpty &&
              isCompletedClicked &&
              isPOCFiles) {
            isCompleted = true;
          }
        });
      }
    });
  }

  Future<void> getVideoFromCamera() async {
    final pickedVideo = await imagePicker.pickVideo(source: ImageSource.camera);
    if (pickedVideo != null) {
      setState(() {
        selectedPOCFiles!.add(File(pickedVideo.path));
      });
      if (selectedPOCFiles!.isNotEmpty && isCompletedClicked) {
        isCompleted = true;
      }
    }
  }

  Future getVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          final videoFile = File(file.path!);
          selectedFiles!.add(videoFile);
        }
      });
    }
  }

  Future getImageFromGallery(bool isCommentFiles) async {
    final pickedImage = await imagePicker.pickMultiImage();
    setState(() {
      if (pickedImage.isNotEmpty) {
        isCommentFiles
            ? selectedCommentImages!
                .addAll(pickedImage.map((image) => File(image.path)))
            : selectedFiles!
                .addAll(pickedImage.map((image) => File(image.path)));
      }
    });
  }

  Future getAttachmentFromGallery(context) async {
    try {
      FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );
      setState(() {
        if (pickedFiles != null) {
          selectedFiles!.add(File(pickedFiles.files.single.path!));
        }
      });
    } on PlatformException catch (e) {
      if (e.code == "read_external_storage_denied") {
        showAlertSnackBar(
            context, translation(context).appSettingConfirm, AlertType.info);
      }
    }
  }

  updateSubtaskList() {
    if (updatedSubTasks!.length == subTasks!.length) {
      for (var i = 0; i < subTasks!.length; i++) {
        if (subTasks![i].subTaskName != updatedSubTasks![i].subTaskName ||
            subTasks![i].subTaskOwner != updatedSubTasks![i].subTaskOwner ||
            subTasks![i].isCompleted != updatedSubTasks![i].isCompleted ||
            subTasks![i].subTaskProofOfCompletion !=
                updatedSubTasks![i].subTaskProofOfCompletion ||
            subTasks![i].subTaskDescription !=
                updatedSubTasks![i].subTaskDescription ||
            subTasks![i].subTaskProofOfCompletionImage !=
                updatedSubTasks![i].subTaskProofOfCompletionImage ||
            subTasks![i].subTaskPriorityLevel !=
                updatedSubTasks![i].subTaskPriorityLevel) {
          isSubTaskEqual = false;
          return;
        } else {
          isSubTaskEqual = true;
        }
      }
    } else {
      isSubTaskEqual = false;
    }
  }

  clearUpdateDetail() {
    commentId = '';
    commentedFiles = [];
    selectedCommentImages = [];
    isCommentEditEnabled = false;
    _taskCommentController!.clear();
    _taskCommentFocusNode!.unfocus();
    removedCommentFilePositions = [];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(false);
        return;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: bgColor,
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: const Icon(Icons.arrow_back_ios)),
            title: Text(taskId != null
                ? translation(context).updateTask
                : translation(context).createTask),
            actions: [
              (taskId != null && userId == creatorId)
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: redIconColor),
                      onPressed: () {
                        showAlertWithAction(
                            context: context,
                            title: translation(context).deleteTask,
                            content: translation(context).doYouWantToDeleteTask,
                            onPress: () {
                              taskBloc!.add(DeleteTask(taskId!));
                            });
                      })
                  : const SizedBox()
            ]),
        body: MultiBlocListener(
            listeners: [
              BlocListener<TaskBloc, TaskState>(
                  bloc: taskBloc,
                  listener: (context, state) {
                    if (state is GetTaskByIdSuccess) {
                      task = state.taskById;
                      taskDetailDisplay();
                    } else if (state is GetTaskByIdFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is UpdateTaskSuccess) {
                      Navigator.pop(context, true);
                      showAlertSnackBar(
                          context,
                          translation(context).taskUpdatedSuccessfully,
                          AlertType.success);
                    } else if (state is UpdateTaskFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is CreateTaskSuccess) {
                      Navigator.pop(context, true);
                      showAlertSnackBar(
                          context,
                          translation(context).taskCreatedSuccessfully,
                          AlertType.success);
                    } else if (state is CreateTaskFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is DeleteTaskSuccess) {
                      Navigator.pop(context, true);
                      showAlertSnackBar(
                          context,
                          translation(context).taskDeletedSuccessfully,
                          AlertType.success);
                    } else if (state is DeleteTaskFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is GetAllTasksByProjectSuccess) {
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
                    } else if (state is AddTaskCommentSuccess) {
                      taskComments!.insert(0, state.taskComment);
                      _taskCommentFocusNode!.unfocus();
                      taskComment = '';
                      _taskCommentController!.clear();
                      selectedCommentImages = [];
                      Navigator.pop(context);
                      getTaskByUserId();
                    } else if (state is AddTaskCommentFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is DeleteTaskCommentSuccess) {
                      showAlertSnackBar(
                          context,
                          translation(context).commentDeleteSuccess,
                          AlertType.success);
                      getTaskByUserId();
                    } else if (state is DeleteTaskCommentFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    } else if (state is UpdateTaskCommentSuccess) {
                      clearUpdateDetail();
                      Navigator.pop(context);
                      showAlertSnackBar(
                          context,
                          translation(context).commentUpdateSuccess,
                          AlertType.success);
                      getTaskByUserId();
                    } else if (state is UpdateTaskCommentFailed) {
                      showAlertSnackBar(
                          context, state.errorMessage, AlertType.error);
                    }
                  }),
              BlocListener(
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
                  })
            ],
            child: BlocBuilder<TaskBloc, TaskState>(
                bloc: taskBloc,
                builder: (context, state) {
                  if (state is CreateTaskLoading ||
                      state is UpdateTaskLoading ||
                      state is GetTaskByIdLoading) {
                    return const Loading();
                  } else {
                    return SingleChildScrollView(child: _buildBody());
                  }
                })),
        bottomNavigationBar: _buildBottomAppBar(),
      ),
    );
  }

  Widget _buildBody() {
    return Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 10.h),
              taskNameTextBox(),
              SizedBox(height: 10.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: buildHeading(translation(context).addSubTask)),
                InkWell(
                    onTap: () {
                      setState(() {
                        _subTaskController!.add(TextEditingController());
                        SubTasks subTask = SubTasks(
                            '',
                            '',
                            '',
                            Owner(userId: '', firstName: '', lastName: ''),
                            Owner(
                                userId: userId,
                                firstName: firstName,
                                lastName: lastName),
                            false,
                            false,
                            [],
                            [],
                            null);
                        updatedSubTasks!.add(subTask);
                      });
                    },
                    child: const Icon(Icons.add, color: primaryColor))
              ]),
              _buildSubTaskWidget(),
              taskDescriptionTextBox(),
              SizedBox(height: 10.h),
              taskDueDateTextBox(),
              SizedBox(height: 10.h),
              taskPriorityDropdown(),
              SizedBox(height: 10.h),
              taskRepeatDropdown(),
              SizedBox(height: 10.h),
              taskAssignToTextBox(),
              SizedBox(height: 10.h),
              taskProjectTextBox(),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: buildHeading(translation(context).addFile),
              ),
              _buildAddAttachmentField(),
              (creatorId == userId || taskId == null)
                  ? Row(children: [
                      Checkbox(
                          activeColor: primaryColor,
                          value: isProofOfCompletion,
                          onChanged: (bool? value) {
                            setState(() {
                              isProofOfCompletion = value ?? false;
                            });
                          }),
                      buildHeading(translation(context).proofOfCompletion),
                    ])
                  : const SizedBox(),
              isProofOfCompletion && taskId != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (creatorId == userId)
                                ? const SizedBox()
                                : buildHeading(
                                    '${translation(context).proofOfCompletion}*'),
                            _buildAddPOCImageField(),
                            Row(children: [
                              InkWell(
                                  onTap: () {
                                    isPOCFiles = true;
                                    isCommentFiles = false;
                                    getImageFromCamera(
                                        isPOCFiles!, isCommentFiles!);
                                  },
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: black)),
                              SizedBox(width: 5.w),
                              InkWell(
                                  onTap: () {
                                    getVideoFromCamera();
                                  },
                                  child: const Icon(Icons.video_camera_back,
                                      color: black)),
                              SizedBox(width: 5.w)
                            ])
                          ]))
                  : const SizedBox(),
              SizedBox(height: 10.h),
              buildHeading(translation(context).comments),
              SizedBox(height: 5.h),
              taskCommentTextBox(),
              SizedBox(height: 10.h),
              const Divider(),
              buildTaskComments(),
              if (creatorName != null)
                Text('${translation(context).createdBy} $creatorName')
            ])));
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: bgColor,
      child: InkWell(
        onTap: () {
          bool? isAnyDaySelected = false;
          updateSubtaskList();
          if (selectedRepeatOption == 'Weekly') {
            isAnyDaySelected = days.any((day) => day['isSelected'] == true);
            if (!isAnyDaySelected) {
              showAlertSnackBar(
                context,
                translation(context).pleaseSelectDay,
                AlertType.info,
              );
              return;
            }
          }

          if (_formKey.currentState!.validate()) {
            bool areRepeatSchedulesEqual =
                repeatSchedule!.length == updatedRepeatSchedule!.length &&
                    repeatSchedule!.every(
                        (element) => updatedRepeatSchedule!.contains(element));

            if (taskId != null) {
              if (isProofOfCompletion &&
                  isCompleted &&
                  (task!.proofOfCompletionImages!.length ==
                          removedMediaPotisions.length &&
                      selectedPOCFiles!.isEmpty)) {
                showAlertSnackBar(
                  context,
                  translation(context).attachProofofcompletion,
                  AlertType.info,
                );
              } else if (isProofOfCompletion != task!.proofOfCompletion ||
                  isCompleted != task!.isCompleted ||
                  taskName != _taskNameController!.text ||
                  taskDescription != _taskDescriptionController!.text ||
                  taskDueDate != _taskDueDateController!.text ||
                  assignedUserName != _taskAssignToController!.text ||
                  projectName != _taskProjectController!.text ||
                  !isSubTaskEqual ||
                  selectedPOCFiles!.isNotEmpty ||
                  selectedFiles!.isNotEmpty ||
                  removedMediaPotisions.isNotEmpty ||
                  removedExistingImagePotision.isNotEmpty ||
                  !areRepeatSchedulesEqual ||
                  updatedPriorityLevel != selectedPriority) {
                taskBloc!.add(UpdateTask(
                    taskId!,
                    _taskNameController!.text.trim(),
                    _taskDescriptionController!.text.trim(),
                    selectedDate ?? '',
                    projectId ?? '',
                    assignedUserId ?? '',
                    updatedSubTasks!,
                    selectedPOCFiles,
                    removedMediaPotisions,
                    isCompleted,
                    isProofOfCompletion,
                    selectedFiles,
                    removedExistingImagePotision,
                    removedSubtaskMediaPositions,
                    removedSubtaskDocumentPositions,
                    UserDetailsDataStore.getSelectedOrganizationId!,
                    selectedPriority ?? '',
                    updatedRepeatSchedule!));
              } else {
                showAlertSnackBar(
                  context,
                  translation(context).noChangesMade,
                  AlertType.info,
                );
              }
            } else {
              taskBloc!.add(CreateTask(
                  _taskNameController!.text.trim(),
                  _taskDescriptionController!.text.trim(),
                  selectedDate ?? '',
                  projectId ?? '',
                  assignedUserId ?? '',
                  updatedSubTasks!,
                  isProofOfCompletion,
                  selectedFiles,
                  UserDetailsDataStore.getSelectedOrganizationId!,
                  selectedPriority ?? '',
                  updatedRepeatSchedule!));
            }
          }
        },
        child: createOrUpdateTaskButton(),
      ),
    );
  }

  Widget buildHeading(title) {
    return Text(title,
        style: TextStyle(
            fontFamily: 'Poppins',
            color: greyTextColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500));
  }

  Widget taskNameTextBox() {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: _taskNameController,
        focusNode: _taskNameFocusNode,
        maxLines: null,
        decoration: taskId != null
            ? InputDecoration(
                prefixIcon: Checkbox(
                    activeColor: primaryColor,
                    value: isCompleted,
                    onChanged: (bool? value) async {
                      if (!isCompleted &&
                          isProofOfCompletion &&
                          ((selectedPOCFiles!.isEmpty ||
                                  selectedPOCFiles == null) &&
                              (task!.proofOfCompletionImages!.isEmpty ||
                                  task!.proofOfCompletionImages == null))) {
                        var result = await showCameraDialog();
                        if (result == true) {
                          setState(() {
                            isCompletedClicked = value ?? true;
                          });
                        }
                      } else {
                        setState(() {
                          isCompleted = value ?? false;
                        });
                      }
                    }),
                filled: true,
                fillColor: white,
                hintText: translation(context).taskName,
                hintStyle:
                    TextStyle(color: lightTextColor.withValues(alpha: .5)),
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
                    borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              )
            : InputDecoration(
                filled: true,
                fillColor: white,
                hintText: '${translation(context).taskName} *',
                hintStyle:
                    TextStyle(color: lightTextColor.withValues(alpha: .5)),
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
                    borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              ),
        style: const TextStyle(color: lightTextColor),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return translation(context).enterTaskName;
          }
          return null;
        });
  }

  Widget taskDescriptionTextBox() {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: 5,
      controller: _taskDescriptionController,
      focusNode: _taskDescriptionFocusNode,
      decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          filled: true,
          fillColor: white,
          hintText: translation(context).taskDescription,
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
    );
  }

  Widget taskDueDateTextBox() {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: _taskDueDateController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: white,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        hintText: translation(context).dueDate,
        hintStyle: TextStyle(color: lightTextColor.withValues(alpha: .5)),
        suffixIcon: _taskDueDateController!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: lightTextColor),
                onPressed: () {
                  setState(() {
                    _taskDueDateController!.clear();
                    selectedDate = '';
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
      style: const TextStyle(color: lightTextColor),
      onTap: () => _selectDueDate(context),
    );
  }

  Widget taskRepeatDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<String>(
        value: selectedRepeatOption,
        items: ['Daily', 'Weekly']
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ))
            .toList(),
        onChanged: (newValue) {
          setState(() {
            selectedRepeatOption = newValue;
            if (newValue == 'Daily') {
              updatedRepeatSchedule = [];
              updatedRepeatSchedule!.add('DAILY');
            } else {
              updatedRepeatSchedule = [];
              updatedRepeatSchedule!.addAll(repeatSchedule!);
              if (updatedRepeatSchedule!.contains('DAILY')) {
                updatedRepeatSchedule!.remove('DAILY');
              }
            }
          });
        },
        dropdownColor: white,
        icon: const SizedBox.shrink(),
        hint: Text(translation(context).repeat,
            style: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500)),
        decoration: InputDecoration(
            filled: true,
            fillColor: white,
            prefixIcon: const Icon(Icons.repeat),
            suffixIcon: selectedRepeatOption != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: lightTextColor),
                    onPressed: () {
                      setState(() {
                        selectedRepeatOption = null;
                        updatedRepeatSchedule = [];
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
                EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            floatingLabelBehavior: FloatingLabelBehavior.never),
        style: const TextStyle(color: lightTextColor),
      ),
      if (selectedRepeatOption == 'Weekly')
        Container(
            padding: EdgeInsets.all(10.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(translation(context).selectDays,
                  style: const TextStyle(fontSize: 16)),
              SizedBox(height: 10.h),
              Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List.generate(days.length, (index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            days[index]['isSelected'] =
                                !days[index]['isSelected'];
                            var selectedDay = days[index]['value'];

                            if (days[index]['isSelected']) {
                              updatedRepeatSchedule!.add(selectedDay);
                            } else {
                              updatedRepeatSchedule!.remove(selectedDay);
                            }
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              color: days[index]['isSelected']
                                  ? primaryColor
                                  : lightTextColor.withValues(alpha: 0.1),
                            ),
                            child: Text(days[index]['day'],
                                style: TextStyle(
                                    fontSize: 14,
                                    color: days[index]['isSelected']
                                        ? brightTextColor
                                        : black))));
                  }))
            ]))
    ]);
  }

  Widget taskAssignToTextBox() {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
      style: const TextStyle(color: lightTextColor),
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
                        focusNode: _searchFocusNode,
                        maxLines: 1,
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_searchUserController!.text.isNotEmpty) {
                                  _searchUserController!.clear();
                                  page = 1;
                                  usersList = [];
                                  textClear = false;
                                  getAllUsers();
                                }
                              });
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
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        white))),
                                                title: Text(userName),
                                                onTap: () {
                                                  setState(() {
                                                    _taskAssignToController!
                                                        .text = userName;
                                                    assignedUserId =
                                                        usersList![index]
                                                            .userId;
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
                  })
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
      style: const TextStyle(color: lightTextColor),
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
                          focusNode: _searchFocusNode,
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
                      BlocBuilder<TaskBloc, TaskState>(
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
                                                projectList![index].projectName;
                                            return ListTile(
                                                leading: Container(
                                                    width: 30.w,
                                                    height: 25.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          getAvatarColor(index),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3.r),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        getInitials(
                                                            projectName!),
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color: white))),
                                                title: Text(projectName),
                                                onTap: () {
                                                  setState(() {
                                                    _taskProjectController!
                                                        .text = projectName;
                                                    projectId =
                                                        projectList![index]
                                                            .projectId;
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
                          })
                    ])),
          );
        });
  }

  Widget _buildAddPOCImageField() {
    return Column(children: [
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (task != null &&
                    task!.proofOfCompletionImages != null &&
                    task!.proofOfCompletionImages!.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(children: [
                        StaggeredGrid.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children:
                                task!.proofOfCompletionImages!.map((item) {
                              int index =
                                  task!.proofOfCompletionImages!.indexOf(item);
                              bool isPOCDeleted =
                                  removedMediaPotisions.contains(index);
                              return item.toString().contains('.mp4') ||
                                      item.toString().contains('.MOV')
                                  ? StaggeredGridTile.count(
                                      crossAxisCellCount: 2,
                                      mainAxisCellCount: 1,
                                      child: _buildPOCChildWithRemoveIcon(
                                          VideoPlayerWidget(
                                              videoUrl: item,
                                              isListScreen: false),
                                          index,
                                          isPOCDeleted,
                                          item))
                                  : StaggeredGridTile.count(
                                      crossAxisCellCount: 1,
                                      mainAxisCellCount: 1,
                                      child: _buildPOCChildWithRemoveIcon(
                                          InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ZoomImage(
                                                                url: item)));
                                              },
                                              child: ThumbnailImage(
                                                  imageUrl: item,
                                                  userProfile: true)),
                                          index,
                                          isPOCDeleted,
                                          item));
                            }).toList())
                      ])),
                selectedPOCFiles != null && selectedPOCFiles!.isNotEmpty
                    ? Column(children: [
                        StaggeredGrid.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: selectedPOCFiles!.map((item) {
                              int index = task != null
                                  ? (task!.proofOfCompletionImages!.length) +
                                      selectedPOCFiles!.indexOf(item)
                                  : selectedPOCFiles!.indexOf(item);
                              bool isPOCDeleted =
                                  removedMediaPotisions.contains(index);
                              return item.path.toString().contains('.mp4') ||
                                      item.path.toString().contains('.MOV')
                                  ? StaggeredGridTile.count(
                                      crossAxisCellCount: 2,
                                      mainAxisCellCount: 1,
                                      child: _buildPOCChildWithRemoveIcon(
                                          VideoPlayerWidget(
                                              video: item, isListScreen: false),
                                          index,
                                          isPOCDeleted,
                                          item))
                                  : StaggeredGridTile.count(
                                      crossAxisCellCount: 1,
                                      mainAxisCellCount: 1,
                                      child: _buildPOCChildWithRemoveIcon(
                                          InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ZoomImage(
                                                                file: item)));
                                              },
                                              child: ThumbnailImage(
                                                  file: item,
                                                  userProfile: true)),
                                          index,
                                          isPOCDeleted,
                                          item));
                            }).toList())
                      ])
                    : const SizedBox()
              ]))
    ]);
  }

  Widget _buildPOCChildWithRemoveIcon(
      Widget child, int index, bool isPOCDeleted, item) {
    return Stack(children: [
      child,
      if (!isPOCDeleted)
        Align(
            alignment: Alignment.topRight,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        showAlertWithAction(
                            context: context,
                            title: translation(context).deleteFile,
                            content: translation(context).deleteThisFile,
                            onPress: () {
                              if (item is File) {
                                setState(() {
                                  selectedPOCFiles!.remove(item);
                                  if (selectedPOCFiles!.isEmpty) {
                                    isCompleted = false;
                                  }
                                });
                              } else if (!isPOCDeleted) {
                                setState(() {
                                  removedMediaPotisions.add(index);
                                  if (removedMediaPotisions.length ==
                                      task!.proofOfCompletionImages!.length) {
                                    isCompleted = false;
                                  }
                                });
                              }
                            });
                      },
                      child: CircleAvatar(
                          backgroundColor: redIconColor,
                          radius: 12.r,
                          child: Icon(Icons.delete, size: 16.h, color: white)))
                ])),
      if (isPOCDeleted)
        Align(
            alignment: Alignment.center,
            child: Container(
                padding: const EdgeInsets.all(8),
                color: white.withValues(alpha: 0.5),
                child: Text(translation(context).deleted,
                    style: const TextStyle(
                        color: redIconColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))))
    ]);
  }

  Widget _buildChildWithRemoveIcon(
      Widget child, int index, bool isDeleted, item) {
    return Stack(children: [
      child,
      if (!isDeleted)
        Align(
            alignment: Alignment.topRight,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        showAlertWithAction(
                            context: context,
                            title: translation(context).deleteFile,
                            content: translation(context).deleteThisFile,
                            onPress: () {
                              if (item is File) {
                                setState(() {
                                  selectedFiles!.remove(item);
                                });
                              } else if (!isDeleted) {
                                setState(() {
                                  removedExistingImagePotision.add(index);
                                });
                              }
                            });
                      },
                      child: CircleAvatar(
                          backgroundColor: redIconColor,
                          radius: 12.r,
                          child: Icon(Icons.delete, size: 16.h, color: white)))
                ])),
      if (isDeleted)
        Align(
            alignment: Alignment.center,
            child: Container(
                padding: const EdgeInsets.all(8),
                color: white.withValues(alpha: 0.5),
                child: Text(translation(context).deleted,
                    style: const TextStyle(
                        color: redIconColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))))
    ]);
  }

  Widget createOrUpdateTaskButton() {
    return BlocBuilder<TaskBloc, TaskState>(
      bloc: taskBloc,
      builder: (context, state) {
        if (state is CreateTaskLoading || state is UpdateTaskLoading) {
          return const SizedBox();
        } else {
          return Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                  height: 44.h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Center(
                      child: Text(
                          taskId != null
                              ? translation(context).updateTask
                              : translation(context).createTask,
                          style: TextStyle(
                              color: white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500)))));
        }
      },
    );
  }

  Widget _buildSubTaskWidget() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _subTaskController!.length,
        padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
        itemBuilder: (context, index) => updatedSubTasks!.isEmpty
            ? const SizedBox()
            : Padding(
                padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextFormField(
                              readOnly: true,
                              onTap: () async {
                                Object? result = await Navigator.pushNamed(
                                    context, PageName.updateSubTaskScreen,
                                    arguments: updatedSubTasks![index]);
                                if (result != null) {
                                  setState(() {
                                    List<Object?> resultList =
                                        result as List<Object?>;
                                    SubTasks subTaskDetail =
                                        resultList[0] as SubTasks;
                                    removedSubtaskMediaPositions =
                                        resultList[1] as List<int>;
                                    removedSubtaskDocumentPositions =
                                        resultList[2] as List<int>;
                                    updatedSubTasks![index] = subTaskDetail;
                                    _subTaskController![index].text =
                                        subTaskDetail.subTaskName ?? '';
                                  });
                                }
                              },
                              onChanged: (value) {
                                updatedSubTasks![index].subTaskName = value;
                              },
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              controller: _subTaskController![index],
                              maxLines: null,
                              decoration: taskId != null
                                  ? InputDecoration(
                                      prefixIcon: Checkbox(
                                          activeColor: primaryColor,
                                          value: updatedSubTasks![index]
                                              .isCompleted,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              updatedSubTasks![index]
                                                  .isCompleted = value ?? false;
                                            });
                                          }),
                                      filled: true,
                                      fillColor: white,
                                      hintText:
                                          translation(context).subtaskName,
                                      hintStyle: TextStyle(
                                          color: lightTextColor.withValues(
                                              alpha: .5)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          borderSide: BorderSide(width: 1.w)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          borderSide: BorderSide(
                                              color: greyBorderColor.withValues(
                                                  alpha: .2),
                                              width: 1.w)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          borderSide: BorderSide(
                                              color: greyBorderColor,
                                              width: 1.w)),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.h, horizontal: 10.w))
                                  : InputDecoration(
                                      filled: true,
                                      fillColor: white,
                                      hintText:
                                          translation(context).subtaskName,
                                      hintStyle: TextStyle(
                                          color: lightTextColor.withValues(alpha: .5)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide(width: 1.w)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide(color: greyBorderColor.withValues(alpha: .2), width: 1.w)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide(color: greyBorderColor, width: 1.w)),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w)),
                              style: const TextStyle(color: lightTextColor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translation(context)
                                      .pleaseEnterSubTaskName;
                                }
                                return null;
                              })),
                      SizedBox(width: 5.w),
                      InkWell(
                          onTap: () {
                            showAlertWithAction(
                                context: context,
                                title: translation(context).deleteSubtask,
                                content: translation(context).deleteThisSubtask,
                                onPress: () {
                                  setState(() {
                                    _subTaskController![index].clear();
                                    _subTaskController![index].dispose();
                                    _subTaskController!.removeAt(index);
                                    updatedSubTasks!.removeAt(index);
                                  });
                                });
                          },
                          child: const Icon(Icons.delete_forever_rounded,
                              color: redIconColor))
                    ])));
  }

  Widget _buildAddAttachmentField() {
    return Column(children: [
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (task != null &&
                    task!.documents != null &&
                    task!.documents!.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(children: [
                        StaggeredGrid.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: task!.documents!.map((item) {
                              int index = task!.documents!.indexOf(item);
                              bool isDeleted =
                                  removedExistingImagePotision.contains(index);
                              return item.toString().contains('.mp4') ||
                                      item.toString().contains('.MOV')
                                  ? StaggeredGridTile.count(
                                      crossAxisCellCount: 2,
                                      mainAxisCellCount: 1,
                                      child: _buildChildWithRemoveIcon(
                                          VideoPlayerWidget(
                                              videoUrl: item,
                                              isListScreen: false),
                                          index,
                                          isDeleted,
                                          item))
                                  : (item.toString().contains('.pdf') ||
                                          item.toString().contains('.txt'))
                                      ? StaggeredGridTile.count(
                                          crossAxisCellCount: 1,
                                          mainAxisCellCount: 1,
                                          child: _buildChildWithRemoveIcon(
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    item
                                                            .toString()
                                                            .contains('.pdf')
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              launchURL(item);
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/pdf_file_image.png',
                                                              fit: BoxFit.fill,
                                                              height: 90,
                                                            ),
                                                          )
                                                        : item
                                                                .toString()
                                                                .contains(
                                                                    '.txt')
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  launchURL(
                                                                      item);
                                                                },
                                                                child: Image.asset(
                                                                    'assets/images/text_file_image.png',
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    height: 90))
                                                            : ThumbnailImage(
                                                                imageUrl:
                                                                    '$item',
                                                                userProfile:
                                                                    false)
                                                  ]),
                                              index,
                                              isDeleted,
                                              item))
                                      : StaggeredGridTile.count(
                                          crossAxisCellCount: 1,
                                          mainAxisCellCount: 1,
                                          child: _buildChildWithRemoveIcon(
                                              InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ZoomImage(
                                                                    url:
                                                                        item)));
                                                  },
                                                  child: ThumbnailImage(
                                                      imageUrl: item,
                                                      userProfile: true)),
                                              index,
                                              isDeleted,
                                              item));
                            }).toList())
                      ])),
                selectedFiles != null && selectedFiles!.isNotEmpty
                    ? Column(children: [
                        StaggeredGrid.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: selectedFiles!.map((item) {
                              int index = task != null
                                  ? (task!.documents!.length) +
                                      selectedFiles!.indexOf(item)
                                  : selectedFiles!.indexOf(item);
                              bool isDeleted =
                                  removedExistingImagePotision.contains(index);
                              String fileExtension =
                                  item.path.split('.').last.toLowerCase();
                              if (fileExtension == 'pdf' ||
                                  fileExtension == 'txt') {
                                return StaggeredGridTile.count(
                                  crossAxisCellCount: 1,
                                  mainAxisCellCount: 1,
                                  child: _buildChildWithRemoveIcon(
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            item.toString().contains('.pdf')
                                                ? Image.asset(
                                                    'assets/images/pdf_file_image.png',
                                                  )
                                                : item
                                                        .toString()
                                                        .contains('.txt')
                                                    ? Image.asset(
                                                        'assets/images/text_file_image.png',
                                                      )
                                                    : ThumbnailImage(
                                                        imageUrl: '$item',
                                                        userProfile: false)
                                          ]),
                                      index,
                                      isDeleted,
                                      item),
                                );
                              } else if (item.path
                                      .toString()
                                      .contains('.mp4') ||
                                  item.path.toString().contains('.MOV')) {
                                return StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 1,
                                    child: _buildChildWithRemoveIcon(
                                        VideoPlayerWidget(
                                            video: item, isListScreen: false),
                                        index,
                                        isDeleted,
                                        item));
                              } else {
                                return StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: _buildChildWithRemoveIcon(
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ZoomImage(
                                                              file: item)));
                                            },
                                            child: ThumbnailImage(
                                                file: item, userProfile: true)),
                                        index,
                                        isDeleted,
                                        item));
                              }
                            }).toList())
                      ])
                    : const SizedBox(),
                Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () {
                                isCommentFiles = false;
                                getImageFromGallery(isCommentFiles!);
                              },
                              child: const Icon(Icons.image_outlined,
                                  color: black)),
                          SizedBox(width: 10.w),
                          InkWell(
                              onTap: () {
                                isPOCFiles = false;
                                isCommentFiles = false;
                                getImageFromCamera(
                                    isPOCFiles!, isCommentFiles!);
                              },
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: black)),
                          SizedBox(width: 10.w),
                          InkWell(
                              onTap: () {
                                getVideoFile();
                              },
                              child: const Icon(
                                  Icons.video_camera_back_outlined,
                                  color: black)),
                          SizedBox(width: 10.w),
                          InkWell(
                              onTap: () {
                                getAttachmentFromGallery(context);
                              },
                              child:
                                  const Icon(Icons.attach_file, color: black))
                        ]))
              ]))
    ]);
  }

  Widget _buildAddCommentImageField() {
    return Column(children: [
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (task != null &&
                    isCommentEditEnabled &&
                    commentedFiles!.isNotEmpty &&
                    commentedFiles != null)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(children: [
                        StaggeredGrid.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: commentedFiles!.map((item) {
                              int index = commentedFiles!.indexOf(item);
                              bool isImageDeleted =
                                  removedCommentFilePositions.contains(index);
                              return StaggeredGridTile.count(
                                  crossAxisCellCount: 1,
                                  mainAxisCellCount: 1,
                                  child: _buildCommentChildWithRemoveIcon(
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ZoomImage(
                                                      url: TaskComment
                                                          .getCommentImagePath(
                                                              taskId,
                                                              commentId,
                                                              commentedFiles![
                                                                  index]))));
                                        },
                                        child: Image.network(
                                            TaskComment.getCommentImagePath(
                                                taskId,
                                                commentId,
                                                commentedFiles![index]),
                                            fit: BoxFit.cover),
                                      ),
                                      index,
                                      isImageDeleted,
                                      item));
                            }).toList())
                      ])),
                selectedCommentImages != null &&
                        selectedCommentImages!.isNotEmpty
                    ? Column(children: [
                        StaggeredGrid.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: selectedCommentImages!.map((item) {
                              int index = commentedFiles != null
                                  ? (commentedFiles!.length) +
                                      selectedCommentImages!.indexOf(item)
                                  : selectedCommentImages!.indexOf(item);
                              bool isImageDeleted =
                                  removedCommentFilePositions.contains(index);
                              return StaggeredGridTile.count(
                                  crossAxisCellCount: 1,
                                  mainAxisCellCount: 1,
                                  child: _buildCommentChildWithRemoveIcon(
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ZoomImage(file: item)));
                                          },
                                          child: ThumbnailImage(
                                              file: item, userProfile: true)),
                                      index,
                                      isImageDeleted,
                                      item));
                            }).toList())
                      ])
                    : const SizedBox()
              ]))
    ]);
  }

  Widget _buildCommentChildWithRemoveIcon(
      Widget child, int index, bool isImageDeleted, item) {
    return Stack(children: [
      child,
      if (!isImageDeleted)
        Align(
            alignment: Alignment.topRight,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        showAlertWithAction(
                            context: context,
                            title: translation(context).deleteFile,
                            content: translation(context).deleteThisFile,
                            onPress: () {
                              if (item is File) {
                                setState(() {
                                  selectedCommentImages!.remove(item);
                                  if (selectedCommentImages!.isEmpty) {
                                    isCompleted = false;
                                  }
                                });
                              } else if (!isImageDeleted) {
                                setState(() {
                                  removedCommentFilePositions.add(index);
                                });
                              }
                            });
                      },
                      child: CircleAvatar(
                          backgroundColor: redIconColor,
                          radius: 12.r,
                          child: Icon(Icons.delete, size: 16.h, color: white)))
                ])),
      if (isImageDeleted)
        Align(
            alignment: Alignment.center,
            child: Container(
                padding: const EdgeInsets.all(8),
                color: white.withValues(alpha: 0.5),
                child: Text(translation(context).deleted,
                    style: const TextStyle(
                        color: redIconColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))))
    ]);
  }

  Widget taskCommentTextBox() {
    return Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(
                color: greyBorderColor.withValues(alpha: .4), width: 1.w),
            color: white),
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      taskComment = value;
                    });
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  controller: _taskCommentController,
                  focusNode: _taskCommentFocusNode,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                    filled: true,
                    fillColor: white,
                    hintText: translation(context).writeComment,
                    hintStyle:
                        TextStyle(color: lightTextColor.withValues(alpha: .5)),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: lightTextColor)),
              _buildAddCommentImageField(),
              Padding(
                  padding: EdgeInsets.only(
                      left: 5.w, top: 5.h, right: 5.w, bottom: 3.h),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                  onTap: () {
                                    isPOCFiles = false;
                                    isCommentFiles = true;
                                    getImageFromCamera(
                                        isPOCFiles!, isCommentFiles!);
                                  },
                                  child: const Icon(Icons.camera_alt_rounded)),
                              SizedBox(width: 10.w),
                              InkWell(
                                  onTap: () {
                                    isCommentFiles = true;
                                    getImageFromGallery(isCommentFiles!);
                                  },
                                  child: const Icon(Icons.image_outlined)),
                            ]),
                        InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (!isCommentEditEnabled &&
                                  (_taskCommentController!.text.isNotEmpty ||
                                      selectedCommentImages!.isNotEmpty) &&
                                  commentDetail == null) {
                                progress(context);
                                taskBloc!.add(AddTaskComment(
                                    taskComment!.trim(),
                                    taskId!,
                                    orgId!,
                                    selectedCommentImages!));
                              } else if (isCommentEditEnabled &&
                                  (_taskCommentController!.text.isNotEmpty ||
                                      (selectedCommentImages!.isNotEmpty &&
                                          selectedCommentImages != null)) &&
                                  (commentDetail!.content !=
                                          _taskCommentController!.text ||
                                      removedCommentFilePositions.isNotEmpty)) {
                                progress(context);
                                taskBloc!.add(UpdateTaskComment(
                                    commentId!,
                                    taskComment!.trim(),
                                    taskId!,
                                    selectedCommentImages!,
                                    removedCommentFilePositions));
                              } else {
                                showAlertSnackBar(
                                    context,
                                    translation(context).nothingToComment,
                                    AlertType.info);
                              }
                            },
                            child: Icon(Icons.send,
                                color:
                                    _taskCommentController!.text.isNotEmpty ||
                                            selectedCommentImages!.isNotEmpty
                                        ? primaryColor
                                        : black))
                      ])),
              isCommentEditEnabled
                  ? Container(
                      color: white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isCommentEditEnabled = false;
                                  selectedCommentImages = [];
                                  _taskCommentController!.clear();
                                  _taskCommentFocusNode!.unfocus();
                                  removedCommentFilePositions = [];
                                });
                              },
                              child: Text(translation(context).cancel,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: greyTextColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                            InkWell(
                                onTap: () {
                                  if (isCommentEditEnabled &&
                                      (_taskCommentController!
                                              .text.isNotEmpty ||
                                          (selectedCommentImages!.isNotEmpty &&
                                              selectedCommentImages != null)) &&
                                      (commentDetail!.content !=
                                              _taskCommentController!.text ||
                                          removedCommentFilePositions
                                              .isNotEmpty)) {
                                    progress(context);
                                    taskBloc!.add(UpdateTaskComment(
                                        commentId!,
                                        taskComment!,
                                        taskId!,
                                        selectedCommentImages!,
                                        removedCommentFilePositions));
                                  } else {
                                    showAlertSnackBar(
                                        context,
                                        translation(context).nothingToComment,
                                        AlertType.info);
                                  }
                                },
                                child: Text(translation(context).save,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color:
                                            primaryColor.withValues(alpha: .5),
                                        fontWeight: FontWeight.bold)))
                          ]))
                  : const SizedBox()
            ])));
  }

  Widget buildTaskComments() {
    return taskComments!.isNotEmpty
        ? Column(
            children: taskComments!
                .map((commentData) => _buildUserComments(
                    commentData, context, taskComments!.indexOf(commentData)))
                .toList())
        : const SizedBox();
  }

  Widget _buildUserComments(TaskComment commentData, context, index) {
    DateTime commentedTime = DateTime.parse(commentData.createdAt!);
    return Padding(
        padding: EdgeInsets.only(left: 16.w, bottom: 16.w),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Container(
                    padding: const EdgeInsets.all(2.0),
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        gradient: dartGreenToLightGreenVector),
                    child: UserDetailsDataStore.getUserProfilePic != null &&
                            commentData.userId ==
                                UserDetailsDataStore.getCurrentFirebaseUserID
                        ? UserAvatar(
                            radius: 20.r,
                            profileURL: UserDetailsDataStore.getUserProfilePic,
                          )
                        : userAvatarNoStatus())
              ]),
              Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0), color: white),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(commentData.userName ?? "Username",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600)),
                                        RichText(
                                            text: TextSpan(
                                                text: '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black87),
                                                children: [
                                              TextSpan(
                                                text: ConvertionUtil.timeAgo(
                                                    commentedTime.toString()),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: primaryColor),
                                              )
                                            ]))
                                      ]),
                                  if (commentData.userId ==
                                      UserDetailsDataStore
                                          .getCurrentFirebaseUserID)
                                    PopupMenuButton(
                                        color: white,
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              value: 'Edit',
                                              child: Text(
                                                translation(context).edit,
                                                style: const TextStyle(
                                                    fontSize: 13.0),
                                              ),
                                              onTap: () async {
                                                setState(() {
                                                  isCommentEditEnabled = true;
                                                  _taskCommentFocusNode!
                                                      .requestFocus();
                                                  taskComment =
                                                      _taskCommentController!
                                                              .text =
                                                          commentData.content ??
                                                              '';
                                                  commentId =
                                                      commentData.commentId;
                                                  commentDetail = commentData;
                                                  commentedFiles = commentData
                                                      .taskCommentImages!;
                                                });
                                              },
                                            ),
                                            PopupMenuItem(
                                                value: 'Delete',
                                                child: Text(
                                                  translation(context).delete,
                                                  style: const TextStyle(
                                                      fontSize: 13.0),
                                                ),
                                                onTap: () {
                                                  showAlertWithAction(
                                                      context: context,
                                                      title:
                                                          translation(context)
                                                              .delete,
                                                      content:
                                                          translation(context)
                                                              .wantToDelete,
                                                      onPress: () {
                                                        taskBloc!.add(
                                                            DeleteTaskComment(
                                                                commentData
                                                                    .commentId!));
                                                      });
                                                })
                                          ];
                                        },
                                        icon: const Icon(Icons.more_vert))
                                ])),
                        Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (commentData.content != null &&
                                      commentData.content!.isNotEmpty)
                                    Text(commentData.content ?? ''),
                                  if (commentData.taskCommentImages != null &&
                                      commentData.taskCommentImages!.isNotEmpty)
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                            child: SizedBox(
                                                height: 100,
                                                width: 150,
                                                child: _buildCarousel(
                                                    commentData
                                                        .taskCommentImages!,
                                                    index))))
                                ]))
                      ]))
            ]));
  }

  Widget _buildCarousel(List<dynamic> taskCommentData, index) {
    final CarouselSliderController commentCarouselController =
        CarouselSliderController();
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.zero,
        child: Stack(children: [
          CarouselSlider(
              carouselController: commentCarouselController,
              options: CarouselOptions(
                padEnds: false,
                autoPlay: false,
                enableInfiniteScroll:
                    taskComments![index].taskCommentImages!.length > 1,
                height: MediaQuery.of(context).size.height,
                aspectRatio: 1,
                viewportFraction: 1,
                enlargeCenterPage: false,
              ),
              items: commentImageSliders(index)),
          (taskComments![index].taskCommentImages!.length > 1)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      commentCarouselController.previousPage();
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: black),
                  ))
              : const SizedBox(),
          taskComments![index].taskCommentImages!.length > 1
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        commentCarouselController.nextPage();
                      },
                      icon: const Icon(Icons.arrow_forward_ios, color: black)))
              : const SizedBox()
        ]));
  }

  List<Widget> commentImageSliders(index) => taskComments![index]
      .taskCommentImages!
      .map((commentFile) => _buildCommentCarouselItem(
          TaskComment.getCommentImagePath(taskComments![index].taskId,
              taskComments![index].commentId, commentFile),
          index,
          taskComments![index].taskCommentImages!.indexOf(commentFile)))
      .toList();

  Widget _buildCommentCarouselItem(
      String fileName, int commentIndex, int selectedIndex) {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, PageName.carouselScreen, arguments: {
            'taskComment': taskComments![commentIndex],
            'selectedIndex': selectedIndex
          });
        },
        child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            color: greyBgColor.withValues(alpha: 0.4),
            child: widgetShowImages(fileName)));
  }

  Widget taskPriorityDropdown() {
    return DropdownButtonFormField<String>(
        value: selectedPriority,
        items: priorityLevels
            .map((priority) => DropdownMenuItem(
                value: priority,
                child: Text(priority, style: TextStyle(fontSize: 16.sp))))
            .toList(),
        onChanged: (newValue) {
          setState(() {
            selectedPriority = newValue!;
          });
        },
        hint: Text(translation(context).priority,
            style: TextStyle(
                color: lightTextColor.withValues(alpha: .5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp)),
        dropdownColor: white,
        icon: const SizedBox.shrink(),
        decoration: InputDecoration(
            filled: true,
            fillColor: white,
            prefixIcon: const Icon(Icons.leaderboard),
            suffixIcon: selectedPriority != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: lightTextColor),
                    onPressed: () {
                      setState(() {
                        selectedPriority = null;
                      });
                    })
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
        style: const TextStyle(color: lightTextColor));
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
              title: Text(translation(context).attachProofofcompletion,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.sp)),
              content: SizedBox(
                  height: 80.h,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                            onTap: () {
                              isPOCFiles = true;
                              isCommentFiles = false;
                              getImageFromCamera(isPOCFiles!, isCommentFiles!);
                              Navigator.pop(context, true);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt_rounded,
                                      color: black),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Text(translation(context).image,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500))
                                ])),
                        const Divider(),
                        InkWell(
                            onTap: () {
                              getVideoFromCamera();
                              Navigator.pop(context, true);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.video_camera_back,
                                      color: black),
                                  SizedBox(width: 5.w),
                                  Text(translation(context).video,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500))
                                ]))
                      ])));
        });
  }
}
