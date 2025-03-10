import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class RemoveUserDialog extends StatefulWidget {
  final String userId, userName, orgId;
  const RemoveUserDialog(
      {super.key,
      required this.userId,
      required this.userName,
      required this.orgId});

  @override
  State<RemoveUserDialog> createState() => _RemoveUserDialogState();
}

class _RemoveUserDialogState extends State<RemoveUserDialog> {
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
        if (state is RemoveOrganizationUserSuccess) {
          Navigator.of(context).pop(true);
          showAlertSnackBar(context, translation(context).removeUserSuccess,
              AlertType.success);
        } else if (state is RemoveOrganizationUserFailed) {
          Navigator.pop(context);
          showAlertSnackBar(
              context, translation(context).removeUserFailed, AlertType.error);
        }
      },
      child: AlertDialog(
        scrollable: true,
        title: Text(
          translation(context).removeUser,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 16, color: blueTextColor, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          child: Form(
            child: Column(
              children: <Widget>[
                Text(
                  translation(context).confirmUserRemove,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.userName,
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
            child: Text(translation(context).cancel,
                style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              const Loading();
              adminBloc!
                  .add(RemoveOrganizationUser(widget.orgId, widget.userId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenButtonColor,
            ),
            child: Text(translation(context).remove,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
