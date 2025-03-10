part of 'task_bloc.dart';

class TaskEvent {}

class CreateTask extends TaskEvent {
  String taskName;
  String taskDescription;
  String taskEndTime;
  String projectId;
  String taskOwnerId;
  List<SubTasks> subTasks;
  bool proofOfCompletion;
  List<File>? documents;
  String orgId;
  String selectedPriority;
  List<String> repeatSchedule;
  CreateTask(
      this.taskName,
      this.taskDescription,
      this.taskEndTime,
      this.projectId,
      this.taskOwnerId,
      this.subTasks,
      this.proofOfCompletion,
      this.documents,
      this.orgId,
      this.selectedPriority,
      this.repeatSchedule);
}

class UpdateTask extends TaskEvent {
  String taskId;
  String taskName;
  String taskDescription;
  String taskEndTime;
  String projectId;
  String taskOwnerId;
  List<SubTasks> subTasks;
  List<File>? pocFiles;
  List<int> removedMediaPotision;
  bool isCompleted;
  bool proofOfCompletion;
  List<File>? documents;
  List<int> removedDocumentPosition;
  List<int> removedSubtaskMediaPositions;
  List<int> removedSubtaskDocumentPositions;
  String orgId;
  String selectedPriority;
  List<String> repeatSchedule;
  UpdateTask(
      this.taskId,
      this.taskName,
      this.taskDescription,
      this.taskEndTime,
      this.projectId,
      this.taskOwnerId,
      this.subTasks,
      this.pocFiles,
      this.removedMediaPotision,
      this.isCompleted,
      this.proofOfCompletion,
      this.documents,
      this.removedDocumentPosition,
      this.removedSubtaskMediaPositions,
      this.removedSubtaskDocumentPositions,
      this.orgId,
      this.selectedPriority,
      this.repeatSchedule);
}

class DeleteTask extends TaskEvent {
  String taskId;
  DeleteTask(this.taskId);
}

class GetTaskById extends TaskEvent {
  String taskId;
  GetTaskById(this.taskId);
}

class GetAllTasksByProject extends TaskEvent {
  String organizationId;
  int page;
  int limit;
  String searchKeyword;
  String searchType;
  String priorityKey;
  GetAllTasksByProject(this.organizationId, this.page, this.limit,
      this.searchKeyword, this.searchType, this.priorityKey);
}

class GetTasksByProjectAndUser extends TaskEvent {
  String userId;
  String projectId;
  int page;
  int limit;
  String searchTask;
  GetTasksByProjectAndUser(
      this.userId, this.projectId, this.page, this.limit, this.searchTask);
}

class GetTasksByProject extends TaskEvent {
  String projectId;
  int page;
  int limit;
  String searchTask;
  GetTasksByProject(this.projectId, this.page, this.limit, this.searchTask);
}

class AddTaskComment extends TaskEvent {
  String taskComment;
  String taskId;
  String organizationId;
  List<File> filesUrls;
  AddTaskComment(
      this.taskComment, this.taskId, this.organizationId, this.filesUrls);
}

class DeleteTaskComment extends TaskEvent {
  String taskCommentId;
  DeleteTaskComment(this.taskCommentId);
}

class UpdateTaskComment extends TaskEvent {
  String commentId;
  String userComment;
  String postId;
  List<File> files;
  List<int> removedFilePotisions;
  UpdateTaskComment(this.commentId, this.userComment, this.postId, this.files,
      this.removedFilePotisions);
}

class GetUnassignedTask extends TaskEvent {
  String orgId;
  int page;
  int limit;
  String searchTask;
  GetUnassignedTask(this.orgId, this.page, this.limit, this.searchTask);
}

class AssignTaskToProject extends TaskEvent {
  String projectId;
  List<String> taskId;
  AssignTaskToProject(this.projectId, this.taskId);
}

class GetSearchSuggestion extends TaskEvent {
  String organizationId;
  String searchKeyword;
  String searchType;
  String priorityKey;
  GetSearchSuggestion(this.organizationId, this.searchKeyword, this.searchType,
      this.priorityKey);
}

class GetTaskFilters extends TaskEvent {
  String organizationId;
  int page;
  int limit;
  String searchKeyword;
  String searchType;
  String priorityKey;
  GetTaskFilters(this.organizationId, this.page, this.limit, this.searchKeyword,
      this.searchType, this.priorityKey);
}
