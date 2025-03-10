import 'package:flutter/material.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ScheduledShiftScreen extends StatefulWidget {
  const ScheduledShiftScreen({super.key, required this.onBack});
  final Function onBack;

  @override
  State<ScheduledShiftScreen> createState() => _ScheduledShiftScreenState();
}

class _ScheduledShiftScreenState extends State<ScheduledShiftScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          bGMainMini(),
          Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: goBack(widget.onBack),
              ),
              headerWithButtons(context)
            ],
          )
        ],
      ),
    );
  }
}

Widget headerWithButtons(BuildContext context) {
  return Column(
    children: [
      Text(
        translation(context).scheduledShifts,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        translation(context).selectCategoty,
        style: const TextStyle(color: greyTextColor, fontSize: 14.0),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            enableButton("By Shift"),
            disableButton("By Month"),
            disableButton("By Date"),
            // DropdownButton(items: drpBtn1, onChanged: onChanged)
          ],
        ),
      ),
    ],
  );
}

Widget enableButton(
  String lable,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
    decoration: BoxDecoration(
      color: blueButtonColor,
      borderRadius: BorderRadius.circular(50.0),
    ),
    child: Text(
      lable,
      style: const TextStyle(
        color: brightTextColor,
      ),
    ),
  );
}

Widget disableButton(
  String lable,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: grayBorderColor),
      borderRadius: BorderRadius.circular(50.0),
    ),
    child: Text(
      lable,
      style: const TextStyle(
        color: greyTextColor,
      ),
    ),
  );
}
