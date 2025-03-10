import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class DeleteShiftDialog extends StatefulWidget {
  final String shiftId, shiftName;
  const DeleteShiftDialog(
      {super.key, required this.shiftId, required this.shiftName});

  @override
  State<DeleteShiftDialog> createState() => _DeleteShiftDialogState();
}

class _DeleteShiftDialogState extends State<DeleteShiftDialog> {
  AdminBloc? adminBloc;

  @override
  void initState() {
    adminBloc = BlocProvider.of<AdminBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      bloc: adminBloc,
      listener: (context, state) {
        if (state is DeleteShiftSuccess) {
          Navigator.pop(context);
          showAlertSnackBar(
              context, translation(context).shiftDeleteSuccess, AlertType.success);
          Navigator.of(context).pop(true);
        } else if (state is DeleteShiftFailed) {
          Navigator.pop(context);
          showAlertSnackBar(
              context,
              translation(context).shiftDeleteFailed,
              AlertType.error);
        }
      },
      child: AlertDialog(
        scrollable: true,
        title: Text(
          translation(context).deleteShift,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 16, color: blueTextColor, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          child: Form(
            child: Column(
              children: <Widget>[
                Text(
                  translation(context).wantToDelete,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.shiftName,
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
              backgroundColor: greyBgColor,
            ),
            child: Text(translation(context).cancel, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              progress(context);
              adminBloc!.add(DeleteShift(widget.shiftId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenButtonColor,
            ),
            child: Text(translation(context).delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
