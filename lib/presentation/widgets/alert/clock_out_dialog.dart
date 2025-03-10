import 'package:flutter/material.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ClockOutAlertDialog extends StatefulWidget {
  final Function onTap;
  final Function(String) onReasonSelected;

  const ClockOutAlertDialog({
    super.key,
    required this.onTap,
    required this.onReasonSelected,
  });

  @override
  State<ClockOutAlertDialog> createState() => _ClockOutAlertDialogState();
}

class _ClockOutAlertDialogState extends State<ClockOutAlertDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController clockOutController = TextEditingController();

  List reasons = [
    {"value": false, "reason": "Emergency"},
    {"value": false, "reason": "Sickness"},
    {"value": false, "reason": "Others"}
  ];

  String getSelectedReason() {
    var selectedReasonData =
        reasons.firstWhere((element) => element["value"] == true);
    String selectedReason = selectedReasonData["reason"];

    if (["Emergency", "Sickness", "Others"].contains(selectedReason)) {
      String enteredText = clockOutController.text.trim();
      return "$selectedReason - $enteredText";
    }

    return selectedReason;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
        scrollable: true,
        title: Text(
          translation(context).clockoutReason,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: blueTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
            height: height * 0.35,
            width: width,
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Column(
                      children: List.generate(
                          reasons.length,
                          (index) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CheckboxListTile(
                                      activeColor: primaryColor,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Text(
                                        reasons[index]["reason"],
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                      value: reasons[index]["value"],
                                      onChanged: (value) {
                                        setState(() {
                                          for (var element in reasons) {
                                            element["value"] = false;
                                          }
                                          reasons[index]["value"] = value;
                                        });
                                      },
                                    ),
                                    if (reasons[index]["value"] &&
                                        (reasons[index]["reason"] ==
                                                "Emergency" ||
                                            reasons[index]["reason"] ==
                                                "Sickness" ||
                                            reasons[index]["reason"] ==
                                                "Others"))
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: TextFormField(
                                              controller: clockOutController,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              decoration: InputDecoration(
                                                hintText: translation(context)
                                                    .enterReason,
                                                hintStyle: const TextStyle(
                                                    fontSize: 14),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: 2),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  borderSide: const BorderSide(
                                                      color: darkBorderColor),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  borderSide: const BorderSide(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return translation(context)
                                                      .pleaseEnterReason;
                                                }
                                                return null;
                                              }))
                                  ])))
                ]))),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greyBgColor,
            ),
            child: Text(
              translation(context).cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (reasons.any((element) => element['value'] == true)) {
                    String selectedReason = getSelectedReason();
                    widget.onReasonSelected(selectedReason);
                    widget.onTap();
                    clockOutController.text = '';
                    Navigator.pop(context);
                  } else {
                    showAlertSnackBar(
                      context,
                      translation(context).chooseToSubmit,
                      AlertType.info,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenButtonColor,
              ),
              child: Text(translation(context).submit,
                  style: const TextStyle(color: Colors.white)))
        ]);
  }
}
