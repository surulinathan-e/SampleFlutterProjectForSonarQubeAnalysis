part of 'task_bloc.dart';

class TaskState {}

final class TaskInitial extends TaskState {}

class CreateTaskLoading extends TaskState {
  CreateTaskLoading();
}

class CreateTaskSuccess extends TaskState {
  CreateTaskSuccess();
}

class CreateTaskFailed extends TaskState {
  String errorMessage;
  CreateTaskFailed(this.errorMessage);
}

class UpdateTaskLoading extends TaskState {
  UpdateTaskLoading();
}

class UpdateTaskSuccess extends TaskState {
  UpdateTaskSuccess();
}

class UpdateTaskFailed extends TaskState {
  String errorMessage;
  UpdateTaskFailed(this.errorMessage);
}

class DeleteTaskLoading extends TaskState {
  DeleteTaskLoading();
}

class DeleteTaskSuccess extends TaskState {
  DeleteTaskSuccess();
}

class DeleteTaskFailed extends TaskState {
  final String errorMessage;
  DeleteTaskFailed(this.errorMessage);
}

class GetTaskByIdLoading extends TaskState {
  GetTaskByIdLoading();
}

class GetTaskByIdSuccess extends TaskState {
  final TaskDetails taskById;
  GetTaskByIdSuccess(this.taskById);
}

class GetTaskByIdFailed extends TaskState {
  final String errorMessage;
  GetTaskByIdFailed(this.errorMessage);
}

class GetAllTasksByProjectLoading extends TaskState {
  GetAllTasksByProjectLoading();
}

class GetAllTasksByProjectSuccess extends TaskState {
  final List<ProjectDetails> getAllTaskByProject;
  GetAllTasksByProjectSuccess(this.getAllTaskByProject);
}

class GetAllTasksByProjectFailed extends TaskState {
  final String errorMessage;
  GetAllTasksByProjectFailed(this.errorMessage);
}

class GetTasksByProjectAndUserLoading extends TaskState {
  GetTasksByProjectAndUserLoading();
}

class GetTasksByProjectAndUserSuccess extends TaskState {
  final List<TaskDetails> getTasksByProjectAndUser;
  GetTasksByProjectAndUserSuccess(this.getTasksByProjectAndUser);
}

class GetTasksByProjectAndUserFailed extends TaskState {
  final String errorMessage;
  GetTasksByProjectAndUserFailed(this.errorMessage);
}

class GetTasksByProjectLoading extends TaskState {
  GetTasksByProjectLoading();
}

class GetTasksByProjectSuccess extends TaskState {
  final List<TaskDetails> getTasksByProject;
  GetTasksByProjectSuccess(this.getTasksByProject);
}

class GetTasksByProjectFailed extends TaskState {
  final String errorMessage;
  GetTasksByProjectFailed(this.errorMessage);
}

class AddTaskCommentLoading extends TaskState {}

class AddTaskCommentSuccess extends TaskState {
  TaskComment taskComment;
  AddTaskCommentSuccess(this.taskComment);
}

class AddTaskCommentFailed extends TaskState {
  String errorMessage;
  AddTaskCommentFailed(this.errorMessage);
}

class DeleteTaskCommentLoading extends TaskState {
  DeleteTaskCommentLoading();
}

class DeleteTaskCommentSuccess extends TaskState {
  DeleteTaskCommentSuccess();
}

class DeleteTaskCommentFailed extends TaskState {
  String errorMessage;
  DeleteTaskCommentFailed(this.errorMessage);
}

class UpdateTaskCommentLoading extends TaskState {}

class UpdateTaskCommentSuccess extends TaskState {
  UpdateTaskCommentSuccess();
}

class UpdateTaskCommentFailed extends TaskState {
  String errorMessage;
  UpdateTaskCommentFailed(this.errorMessage);
}

class GetUnassignedTaskLoading extends TaskState {
  GetUnassignedTaskLoading();
}

class GetUnassignedTaskSuccess extends TaskState {
  final List<TaskDetails> getUnassignedTask;
  GetUnassignedTaskSuccess(this.getUnassignedTask);
}

class GetUnassignedTaskFailed extends TaskState {
  final String errorMessage;
  GetUnassignedTaskFailed(this.errorMessage);
}

class AssignTaskToProjectLoading extends TaskState {}

class AssignTaskToProjectSuccess extends TaskState {
  AssignTaskToProjectSuccess();
}

class AssignTaskToProjectFailed extends TaskState {
  String errorMessage;
  AssignTaskToProjectFailed(this.errorMessage);
}

class GetSearchSuggestionLoading extends TaskState {}

class GetSearchSuggestionSuccess extends TaskState {
  final List<SearchSuggestion> getSearchSuggestion;
  GetSearchSuggestionSuccess(this.getSearchSuggestion);
}

class GetSearchSuggestionFailed extends TaskState {
  String errorMessage;
  GetSearchSuggestionFailed(this.errorMessage);
}

class GetTaskFiltersLoading extends TaskState {
  GetTaskFiltersLoading();
}

class GetTaskFiltersSuccess extends TaskState {
  final List<TaskDetails> tasks;
  GetTaskFiltersSuccess(this.tasks);
}

class GetTaskFiltersFailed extends TaskState {
  String errorMessage;
  GetTaskFiltersFailed(this.errorMessage);
}
