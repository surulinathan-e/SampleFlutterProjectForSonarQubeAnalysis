import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/search_suggestion.dart';
import 'package:tasko/data/model/subtask.dart';
import 'package:tasko/data/model/task_comment.dart';
import 'package:tasko/data/model/task_details.dart';
import 'package:tasko/data/repo/task_repo.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepo taskRepo = TaskRepo();
  TaskBloc() : super(TaskInitial()) {
    on<TaskEvent>((event, emit) async {
      if (event is CreateTask) {
        try {
          emit(CreateTaskLoading());
          await taskRepo.createTask(
              event.taskName,
              event.taskDescription,
              event.taskEndTime,
              event.projectId,
              event.taskOwnerId,
              event.subTasks,
              event.proofOfCompletion,
              event.documents,
              event.orgId,
              event.selectedPriority,
              event.repeatSchedule);
          emit(CreateTaskSuccess());
        } catch (error) {
          emit(CreateTaskFailed(error.toString()));
        }
      } else if (event is UpdateTask) {
        try {
          emit(UpdateTaskLoading());
          await taskRepo.updateTask(
              event.taskId,
              event.taskName,
              event.taskDescription,
              event.taskEndTime,
              event.projectId,
              event.taskOwnerId,
              event.subTasks,
              event.pocFiles,
              event.removedMediaPotision,
              event.isCompleted,
              event.proofOfCompletion,
              event.documents,
              event.removedDocumentPosition,
              event.removedSubtaskMediaPositions,
              event.removedSubtaskDocumentPositions,
              event.orgId,
              event.selectedPriority,
              event.repeatSchedule);
          emit(UpdateTaskSuccess());
        } catch (error) {
          emit(UpdateTaskFailed(error.toString()));
        }
      } else if (event is DeleteTask) {
        emit(DeleteTaskLoading());
        try {
          await taskRepo.deleteTask(event.taskId);
          emit(DeleteTaskSuccess());
        } catch (error) {
          emit(DeleteTaskFailed(error.toString()));
        }
      } else if (event is GetTaskById) {
        try {
          emit(GetTaskByIdLoading());
          TaskDetails taskById = await taskRepo.getTaskById(event.taskId);
          emit(GetTaskByIdSuccess(taskById));
        } catch (error) {
          emit(GetTaskByIdFailed(error.toString()));
        }
      } else if (event is GetAllTasksByProject) {
        if (event.page == 1) {
          emit(GetAllTasksByProjectLoading());
        }
        try {
          List<ProjectDetails> response = await taskRepo.getAllTasksByProject(
              event.organizationId,
              event.page,
              event.limit,
              event.searchKeyword,
              event.searchType,
              event.priorityKey);
          emit(GetAllTasksByProjectSuccess(response));
        } catch (error) {
          emit(GetAllTasksByProjectFailed(error.toString()));
        }
      } else if (event is GetTasksByProjectAndUser) {
        if (event.page == 1) {
          emit(GetTasksByProjectAndUserLoading());
        }
        try {
          List<TaskDetails> response = await taskRepo.getTasksByProjectAndUser(
              event.userId,
              event.projectId,
              event.page,
              event.limit,
              event.searchTask);
          emit(GetTasksByProjectAndUserSuccess(response));
        } catch (error) {
          emit(GetTasksByProjectAndUserFailed(error.toString()));
        }
      } else if (event is GetTasksByProject) {
        if (event.page == 1) {
          emit(GetTasksByProjectLoading());
        }
        try {
          List<TaskDetails> response = await taskRepo.getTasksByProject(
              event.projectId, event.page, event.limit, event.searchTask);
          emit(GetTasksByProjectSuccess(response));
        } catch (error) {
          emit(GetTasksByProjectFailed(error.toString()));
        }
      } else if (event is AddTaskComment) {
        try {
          emit(AddTaskCommentLoading());
          TaskComment response = await taskRepo.addTaskComment(
              event.taskComment,
              event.taskId,
              event.organizationId,
              event.filesUrls);
          emit(AddTaskCommentSuccess(response));
        } catch (error) {
          emit(AddTaskCommentFailed(error.toString()));
        }
      } else if (event is DeleteTaskComment) {
        emit(DeleteTaskCommentLoading());
        try {
          await taskRepo.deleteTaskComment(event.taskCommentId);
          emit(DeleteTaskCommentSuccess());
        } catch (error) {
          emit(DeleteTaskCommentFailed(error.toString()));
        }
      } else if (event is UpdateTaskComment) {
        try {
          emit(UpdateTaskCommentLoading());
          await taskRepo.updateTaskComment(event.commentId, event.userComment,
              event.postId, event.files, event.removedFilePotisions);
          emit(UpdateTaskCommentSuccess());
        } catch (error) {
          emit(UpdateTaskCommentFailed(error.toString()));
        }
      } else if (event is GetUnassignedTask) {
        if (event.page == 1) {
          emit(GetUnassignedTaskLoading());
        }
        try {
          List<TaskDetails> response = await taskRepo.getUnassignedTask(
              event.orgId, event.page, event.limit, event.searchTask);
          emit(GetUnassignedTaskSuccess(response));
        } catch (error) {
          emit(GetUnassignedTaskFailed(error.toString()));
        }
      } else if (event is AssignTaskToProject) {
        try {
          emit(AssignTaskToProjectLoading());
          await taskRepo.assignTaskToProject(event.projectId, event.taskId);
          emit(AssignTaskToProjectSuccess());
        } catch (error) {
          emit(AssignTaskToProjectFailed(error.toString()));
        }
      } else if (event is GetSearchSuggestion) {
        try {
          emit(GetSearchSuggestionLoading());
          List<SearchSuggestion> response = await taskRepo.getSearchSuggestion(
              event.organizationId,
              event.searchKeyword,
              event.searchType,
              event.priorityKey);
          emit(GetSearchSuggestionSuccess(response));
        } catch (error) {
          emit(GetSearchSuggestionFailed(error.toString()));
        }
      } else if (event is GetTaskFilters) {
        try {
          if (event.page == 1) {
            emit(GetTaskFiltersLoading());
          }
          List<TaskDetails> response = await taskRepo.getTaskFilters(
              event.organizationId,
              event.page,
              event.limit,
              event.searchKeyword,
              event.searchType,
              event.priorityKey);
          emit(GetTaskFiltersSuccess(response));
        } catch (error) {
          emit(GetTaskFiltersFailed(error.toString()));
        }
      }
    });
  }
}
