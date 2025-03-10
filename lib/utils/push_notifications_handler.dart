import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tasko/presentation/routes/pages_name.dart';

void handlePushNotificationClick(BuildContext context, bool mounted) async {
  // Get any messages which caused the application to open from
  // a terminated state.
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  // Navigate to a respective screen If the message also contains a data with navigate to key
  if (initialMessage != null && mounted && context.mounted) {
    handleMessage(context, initialMessage.data);
  }
}

void handleMessage(BuildContext context, Map<String, dynamic>? body,
    {String? description}) {
  if (body != null) {
    if (body['NavigateTo'] != null) {
      if (body['NavigateTo'] == 'OrganizationDetailsPage') {
        Navigator.pushReplacementNamed(
            context, PageName.organizationSelectionScreen);
        Navigator.pushNamedAndRemoveUntil(
            context, PageName.dashBoardScreen, arguments: 3, (route) => false);
        Navigator.pushNamed(context, PageName.addedOrganizationScreen);
      } else if (body['NavigateTo'] == 'SubTaskDetailsPage' ||
          body['NavigateTo'] == 'TaskDetailsPage') {
        Navigator.pushReplacementNamed(
            context, PageName.organizationSelectionScreen);
        Navigator.pushNamedAndRemoveUntil(
            context, PageName.dashBoardScreen, arguments: 2, (route) => false);
        Navigator.pushNamed(context, PageName.updateTaskScreen,
            arguments: body['TaskId']);
      }
    }
  }
}
