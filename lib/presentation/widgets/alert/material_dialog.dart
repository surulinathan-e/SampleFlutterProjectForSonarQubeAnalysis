import 'package:flutter/material.dart';

import '../../../utils/utils.dart';

class MaterialAlertDialog extends StatefulWidget {
  final String? title, subtitle, description;
  final Function? onPossitivePress;
  final String? possitiveBtnText;
  final String? negativeBtnText;
  final bool? visibleNegativeBtn;

  const MaterialAlertDialog(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.description,
      required this.onPossitivePress,
      this.possitiveBtnText = 'Yes',
      this.negativeBtnText = 'No',
      this.visibleNegativeBtn = true});

  @override
  State<MaterialAlertDialog> createState() => _DeleteProductAlertDialogState();
}

class _DeleteProductAlertDialogState extends State<MaterialAlertDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text(
        widget.title ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 16, color: black, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        child: Form(
          child: Column(
            children: <Widget>[
              Text(
                widget.subtitle ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              Text(
                widget.description ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: greyBorderColor,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(widget.negativeBtnText ?? '',
              style: const TextStyle(color: white)),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.onPossitivePress != null) {
              widget.onPossitivePress!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(widget.possitiveBtnText ?? '',
              style: const TextStyle(color: white)),
        ),
      ],
    );
  }
}
