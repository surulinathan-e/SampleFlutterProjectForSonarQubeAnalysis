import 'package:flutter/material.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/post_comment.dart';
import 'package:tasko/data/model/project_details.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/subtask.dart';
import 'package:tasko/data/model/task_comment.dart';
import 'package:tasko/data/model/user_post.dart';
import 'package:tasko/data/model/user_profile.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/screens/screens.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PageName.splashScreen:
        return _buildMaterialPageRoute(settings, const SplashScreen());
      case PageName.loginScreen:
        return _buildMaterialPageRoute(settings, const LoginScreen());
      case PageName.signupScreen:
        return _buildMaterialPageRoute(settings, const SignUpScreen());
      case PageName.forgetPasswordScreen:
        return _buildMaterialPageRoute(settings, const ForgetPasswordScreen());
      case PageName.emailVerificationScreen:
        var arg = settings.arguments;
        return _buildMaterialPageRoute(
            settings, EmailVerificationScreen(userEmail: arg as String));
      case PageName.emailOTPVerificationScreen:
        // var arg = settings.arguments;
        return _buildMaterialPageRoute(
            settings,
            const EmailOTPVerifyScreen(
                // userDetail: arg == null ? null : arg as UserDetail
                ));
      case PageName.dashBoardScreen:
        var arg = settings.arguments;
        return _buildMaterialPageRoute(
            settings, DashboardScreen(position: arg == null ? 0 : arg as int));
      case PageName.changePasswordScreen:
        return _buildMaterialPageRoute(settings, const ChangePasswordScreen());
      case PageName.introScreen:
        return _buildMaterialPageRoute(settings, const IntroScreen());
      case PageName.loginEntryScreen:
        return _buildMaterialPageRoute(settings, const LoginEntryScreen());
      case PageName.projectListScreen:
        var arg = settings.arguments as Map;
        return _buildMaterialPageRoute(
            settings,
            ProjectListScreen(
              isCreateProject: arg['isCreateProject'] == null
                  ? null
                  : arg['isCreateProject'] as bool,
            ));
      case PageName.projectDetailScreen:
        var arg = settings.arguments;
        return _buildMaterialPageRoute(settings,
            ProjectDetailScreen(project: arg is ProjectDetails ? arg : null));
      case PageName.taskListScreen:
        return _buildMaterialPageRoute(settings, const TaskListScreen());
      case PageName.languageScreen:
        return _buildMaterialPageRoute(settings, const LanguageScreen());
      case PageName.projectTaskListScreen:
        var arg = settings.arguments as Map;
        return _buildMaterialPageRoute(
            settings,
            ProjectTaskListScreen(
                isProjectTask: arg['isProjectTask'] == null
                    ? null
                    : arg['isProjectTask'] as bool,
                project: arg['project'] == null
                    ? null
                    : arg['project'] as ProjectDetails));
      case PageName.updateTaskScreen:
        final args = settings.arguments as Map<String, String?>?;
        return _buildMaterialPageRoute(
            settings,
            UpdateTaskScreen(
                taskId: args?['taskId'],
                projectId: args?['projectId'],
                projectName: args?['projectName']));
      case PageName.updateSubTaskScreen:
        var arg = settings.arguments;
        return _buildMaterialPageRoute(settings,
            UpdateSubtaskScreen(subtasks: arg is SubTasks ? arg : null));
      case PageName.addComment:
        return _buildMaterialPageRoute(
            settings, FeedComments(postData: settings.arguments as Post));
      case PageName.addFeed:
        var arg = settings.arguments as Map;
        return _buildMaterialPageRoute(
            settings,
            AddFeed(
              isMyPostUpdate: arg['isMyPostUpdate'] == null
                  ? null
                  : arg['isMyPostUpdate'] as bool,
              post: arg['post'] == null ? null : arg['post'] as Post,
            ));
      case PageName.adminOrganizationScreen:
        return _buildMaterialPageRoute(
            settings, const AdminOrganizationScreen());
      case PageName.addOrganizationScreen:
        var arg = settings.arguments as Map;
        return _buildMaterialPageRoute(
            settings,
            AddOrganizationScreen(
              organization: arg['organization'] == null
                  ? null
                  : arg['organization'] as Organization,
              isSubOrganization: arg['isSubOrganization'] == null
                  ? null
                  : arg['isSubOrganization'] as bool,
            ));
      case PageName.shiftListScreen:
        return _buildMaterialPageRoute(settings, const ShiftListScreen());

      case PageName.createShiftScreen:
        var arg = settings.arguments;
        return _buildMaterialPageRoute(
            settings,
            CreateShiftScreen(
              shift: arg is Shift ? arg : null,
            ));
      case PageName.assignShiftUserScreen:
        var arg = settings.arguments as Map;
        return _buildMaterialPageRoute(
            settings,
            AssignShiftUserScreen(
              shift: arg['shift'] as Shift,
              organization: arg['organization'] as Organization,
            ));
      case PageName.assignOrganizationScreen:
        return _buildMaterialPageRoute(
            settings, const AssignOrganizationScreen());
      case PageName.adminViewRecords:
        return _buildMaterialPageRoute(
            settings, const AdminViewRecordsScreen());
      case PageName.updateProfile:
        return _buildMaterialPageRoute(settings, const UpdateProfileScreen());
      case PageName.userListScreen:
        return _buildMaterialPageRoute(settings, const UserListScreen());
      case PageName.createUserScreen:
        return _buildMaterialPageRoute(settings, const CreateUserScreen());
      case PageName.updateUserScreen:
        var arg = settings.arguments;
        return _buildMaterialPageRoute(
            settings, UpdateUserScreen(user: arg as UserProfile));
      case PageName.organizationSelectionScreen:
        return _buildMaterialPageRoute(
            settings, const OrganizationSelectionScreen());
      case PageName.addedOrganizationScreen:
        return _buildMaterialPageRoute(
            settings, const AddedOrganizationScreen());
      case PageName.viewRecords:
        return _buildMaterialPageRoute(settings, const ViewRecordScreen());
      case PageName.scheduledShiftUserScreen:
        return _buildMaterialPageRoute(
            settings, const ScheduledShiftUserScreen());
      case PageName.carouselScreen:
        var arg = settings.arguments as Map;
        return _buildMaterialPageRoute(
            settings,
            CarouselScreen(
                arg['post'] == null ? null : arg['post'] as Post,
                arg['postComment'] == null
                    ? null
                    : arg['postComment'] as PostComment,
                arg['taskComment'] == null
                    ? null
                    : arg['taskComment'] as TaskComment,
                selectedIndex: arg['selectedIndex'] as int));
      case PageName.unassignedProjectTaskScreen:
        final args = settings.arguments as Map<String, String?>?;
        return _buildMaterialPageRoute(
            settings,
            UnassignedProjectTaskScreen(
                projectId: args?['projectId'],
                projectName: args?['projectName']));
      default:
        return _buildMaterialPageRoute(settings, const ErrorScreen());
    }
  }

  PageRoute _buildMaterialPageRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        });
  }
}
