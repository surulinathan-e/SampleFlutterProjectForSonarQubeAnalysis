import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/repo/project_repo.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepo projectRepo = ProjectRepo();
  ProjectBloc() : super(ProjectInitial()) {
    on<ProjectEvent>((event, emit) async {
      if (event is GetAllProjects) {
        if (event.page == 1) {
          emit(GetAllProjectsLoading());
        }
        try {
          List<ProjectDetails> response = await projectRepo.getAllProjects(
              event.orgId, event.page, event.limit, event.searchProject);
          emit(GetAllProjectsSuccess(response));
        } catch (error) {
          emit(GetAllProjectsFailed(error.toString()));
        }
      } else if (event is CreateProject) {
        try {
          emit(CreateProjectLoading());
          await projectRepo.createProject(
              event.orgId, event.projectName, event.projectDescription, event.projectMembers);
          emit(CreateProjectSuccess());
        } catch (error) {
          emit(CreateProjectFailed(error.toString()));
        }
      } else if (event is DeleteProject) {
        emit(DeleteProjectLoading());
        try {
          await projectRepo.deleteProject(event.projectId);
          emit(DeleteProjectSuccess());
        } catch (error) {
          emit(DeleteProjectFailed(error.toString()));
        }
      } else if (event is UpdateProject) {
        try {
          emit(UpdateProjectLoading());
          await projectRepo.updateProject(event.projectId, event.projectName,
              event.projectDescription, event.projectMembers);
          emit(UpdateProjectSuccess());
        } catch (error) {
          emit(UpdateProjectFailed(error.toString()));
        }
      }
    });
  }
}
