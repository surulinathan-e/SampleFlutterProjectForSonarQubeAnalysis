part of 'project_bloc.dart';

class ProjectState {}

final class ProjectInitial extends ProjectState {}

class GetAllProjectsLoading extends ProjectState {
  GetAllProjectsLoading();
}

class GetAllProjectsSuccess extends ProjectState {
  List<ProjectDetails> projectDetails;
  GetAllProjectsSuccess(this.projectDetails);
}

class GetAllProjectsFailed extends ProjectState {
  final String errorMessage;
  GetAllProjectsFailed(this.errorMessage);
}

class CreateProjectLoading extends ProjectState {
  CreateProjectLoading();
}
 
class CreateProjectSuccess extends ProjectState {
  CreateProjectSuccess();
}
 
class CreateProjectFailed extends ProjectState {
  String errorMessage;
  CreateProjectFailed(this.errorMessage);
}

class UpdateProjectLoading extends ProjectState {
  UpdateProjectLoading();
}
 
class UpdateProjectSuccess extends ProjectState {
  UpdateProjectSuccess();
}
 
class UpdateProjectFailed extends ProjectState {
  String errorMessage;
  UpdateProjectFailed(this.errorMessage);
}
class DeleteProjectLoading extends ProjectState {
  DeleteProjectLoading();
}

class DeleteProjectSuccess extends ProjectState {
  DeleteProjectSuccess();
}

class DeleteProjectFailed extends ProjectState {
  final String errorMessage;
  DeleteProjectFailed(this.errorMessage);
}
