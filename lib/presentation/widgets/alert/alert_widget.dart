import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';
import '../../routes/pages_name.dart';

enum AlertType { success, error, info }

showAlertSnackBar(
    BuildContext context, String content, AlertType alertType) async {
  if ((content == 'Token has expired.' || content == 'Unauthorized') &&
      alertType == AlertType.error) {
    return _doLogOut(context);
  }
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    backgroundColor: (alertType == AlertType.success)
        ? green
        : (alertType == AlertType.error)
            ? redTextColor
            : (alertType == AlertType.info)
                ? orange
                : black,
    margin: const EdgeInsets.only(
      // bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      right: 20,
      left: 20,
    ),
  ));
}

Future<dynamic> showAlert(BuildContext context, String content) {
  String alertContent = content;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Alert!!!'),
        content: Text(alertContent),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showAlertWithAction(
    {@required BuildContext? context,
    @required String? title,
    @required String? content,
    @required Function? onPress,
    String? possitiveBtnText = 'Yes',
    String? negativeBtnText = 'No',
    bool? visibleNegativeBtn = true}) {
  return showDialog(
    context: context!,
    barrierDismissible: false,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title ?? ''),
      content: Text(content ?? ''),
      actions: [
        if (visibleNegativeBtn!)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(negativeBtnText!, style: const TextStyle(color: black)),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onPress!();
          },
          child: Text(
            possitiveBtnText!,
            style: const TextStyle(color: black),
          ),
        ),
      ],
    ),
  );
}

void _doLogOut(context) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await FirebaseAuth.instance.signOut().then((value) {
    sharedPreferences.clear();
    Navigator.pushNamedAndRemoveUntil(
        context, PageName.loginScreen, (route) => false);
  });
}

// loading circle
Widget showLoadingWidget() {
  return Container(
    width: 200.0,
    height: 150.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: loadingOpacityBrightColor,
    ),
    child: _buildCircleLoadingWithText(),
  );
}

Widget _buildCircleLoadingWithText() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: primaryColor,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          'Loading...',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: loadingFGBrightColor),
        ),
      ],
    ),
  );
}
