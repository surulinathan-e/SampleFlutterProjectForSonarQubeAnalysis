import 'package:flutter/material.dart';

import '../../../utils/colors/colors.dart';

Widget buildNotificationBellWidget(
    BuildContext context, int? notificationCount, Function onPress,
    {String? toolTipMessage = 'Notification'}) {
  return Tooltip(
    message: toolTipMessage,
    child: InkWell(
      onTap: () {
        onPress();
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.notifications_none_sharp,
                size: 30,
              ),
            ),
            if (notificationCount! > 0)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.topRight,
                margin: const EdgeInsets.only(left: 6, top: 5),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: redIconColor,
                      border: Border.all(color: Colors.white, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Center(
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(fontSize: 10, color: white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
