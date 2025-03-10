import 'package:tasko/flavor_config/constants/flavors.dart';
import 'package:tasko/flavor_config/flavor_app_config.dart';

class Endpoints {
  Endpoints._();

  // dev base url
  static const String devBaseUrl =
      'https://tasko-webapp-aqe0fhazapbhgsdy.uksouth-01.azurewebsites.net/api';

  // base url
  static const String prodBaseUrl =
      'https://tasko-webapp-aqe0fhazapbhgsdy.uksouth-01.azurewebsites.net/api';

  // base url
  static String baseUrl = FlavorAppConfig.appFlavor == Flavor.dev
      ? devBaseUrl
      : FlavorAppConfig.appFlavor == Flavor.prod
          ? prodBaseUrl
          : devBaseUrl;

  // image dev base url
  static const String imageDevBaseUrl = 'https://taskost.blob.core.windows.net';

  // image prod base url
  static const String imageProdBaseUrl =
      'https://taskost.blob.core.windows.net';

  // image base url
  static String imageBaseUrl = FlavorAppConfig.appFlavor == Flavor.dev
      ? imageDevBaseUrl
      : FlavorAppConfig.appFlavor == Flavor.prod
          ? imageProdBaseUrl
          : imageDevBaseUrl;

  // receiveTimeout
  static const Duration receiveTimeout = Duration(seconds: 20);

  // connectTimeout
  static const Duration connectionTimeout = Duration(seconds: 20);

  static const String createUser = '/User/CreateUser';

  static const String getToken = '/Auth/Access';

  static const String getRefreshToken = '/Auth/Refresh';

  static const String resendEmail = '/User/ResendEmailConfirmation';

  static const String validateOTP = '/TwoFactorAuth/verify-otp';

  static const String resendOTP = '/TwoFactorAuth/resend-otp';

  static const String addUserDetails = '/User/CreateUserProfile';

  static const String getUserDetails = '/user/GetUserDetails';

  static const String updateUserDetails = '/user/UpdateUserProfile';

  static const String deleteUser = '/User/DeleteUser';

  static const String getAppConfig = '/AppConfig/GetAppConfig';

  static const String createTask = '/Task/CreateTask';

  static const String updateTask = '/Task/UpdateTask';

  static const String getAllTasks = '/Task/GetAllTasks';

  static const String deleteTask = '/Task/DeleteTask';

  static const String getTaskById = '/Task/GetTaskById';

  static const String getAllUsers = '/User/GetAllUsers';

  static const String getCompletedTasks = '/Task/GetAllCompletedTasks';

  static const String getOverdueTasks = '/Task/GetAllOverDueTaskById';

  static const String getCreatedByMeTasks = '/Task/GetAllCreatedByIdTasks';

  static const String getAssignToMeTasks = '/Task/GetAllAssignedByIdTasks';

  static const String getAllTasksByUserId = '/Task/GetAllTasksByUserId';

  static const String getAllTasksByPriority = '/Task/GetTasksByPriority';

  static const String getAllProjects = '/Project/GetAllProjects';

  static const String createProject = '/Project/CreateProject';

  static const String updateProject = '/Project/UpdateProject';

  static const String deleteProject = '/Project/DeleteProject';

  static const String getAllTasksByProject = '/Task/GetAllProjectById';

  static const String getTasksByProjectAndUser =
      '/Task/GetTasksByProjectAndUser';

  static const String getTasksByProject = '/Task/GetTasksByProject';

  static const String getAllOrganizationFeed = '/Post/GetAllFeedPost';

  static const String createPost = '/Post/CreatePost';

  static const String likeOrUnlikeFeedPost = '/Post/LikeOrUnlikePost';

  static const String createPostComment = '/PostComment/CreatePostComment';

  static const String getOrganization = '/getOrganization';

  static const String createOrganization =
      '/Organization/CreateNewOrganization';

  static const String updateOrganization = '/Organization/UpdateOrganization';

  static const String deleteOrganization = '/Organization/DeleteOrganization';

  static const String getUserListByOrganizationId =
      '/User/GetUsersByOrganizationId';

  static const String getOrganizationsShifts = '/Shift/GetOrganizationShift';

  static const String createNewShift = '/Shift/CreateNewShift';

  static const String updateExistingShift = '/Shift/UpdateShift';

  static const String deleteShift = '/Shift/DeleteShift';

  static const String assignShiftUser = '/UserShift/CreateNewUserShift';

  static const String getUserScheduledShifts =
      '/UserShift/GetUserScheduledShifts';

  static const String getUnassignedShiftUsersByOrganization =
      '/UserShift/GetUnassignedShiftUsersByOrganization';

  static const String userShiftScheduledStatusUpdate =
      '/UserShift/UserShiftScheduledStatusUpdate';

  static const String clockInOrOut = '/Clock/UserClockInOrOut';

  static const String getUserAttendanceRecordId =
      '/Clock/GetUserAttendanceRecordId';

  static const String getUserPendingScheduledShift =
      '/UserShift/GetUserPendingScheduledShift';

  static const String getAssignedOrganizations =
      '/Organization/GetUserOrganizations';

  static const String getOrganizationAttendanceRecord =
      '/Clock/GetAttendanceHistoryByOrganizationId';

  static const String getUserAttendanceRecord =
      '/Clock/GetUserAttendanceHistoryByUserId';

  static const String getUserById = '/User/GetUserById';

  static const String updateDbUser = '/User/UpdateUser';

  static const String createDbUser = '/createDbUser';

  static const String deleteDbUser = '/User/DeleteUser';

  static const String addOrganizationUser =
      '/OrganizationMapping/AddOrganizationUser';

  static const String removeOrganizationUser =
      '/OrganizationMapping/DeleteOrganizationUser';

  static const String getUnassignedOrganizationUsers =
      '/User/GetUnassignedOrganizationUsers';

  static const String deleteComment = '/PostComment/DeleteComment';

  static const String updateComment = '/PostComment/UpdateComment';

  static const String deletePost = '/Post/DeletePost';

  static const String updatePost = '/Post/UpdatePost';

  static const String createTaskComment = '/TaskComment/CreateTaskComment';

  static const String deleteTaskComment = '/TaskComment/DeleteComment';

  static const String updateTaskComment = '/TaskComment/UpdateTaskComment';

  static const String acceptAllPendingUserShifts =
      '/UserShift/AcceptPendingUserShifts';

  static const String getUnassignedUsers =
      '/User/GetUnassignedUsersByOrganizationId';

  static const String getUnassignedTask = '/Task/GetUnassignedTask';

  static const String assignTaskToProject = '/Project/AssignTasksToProject';

  static const String getSearchSuggestion = '/Suggestion/GetSearchSuggestion';

  static const String getTaskFilters = '/Task/Getfilters';

  static const String getTodayScheduledShift = '/Shift/GetTodayScheduledShifts';
}
