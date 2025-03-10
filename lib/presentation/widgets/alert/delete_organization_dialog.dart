import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/bloc/admin/admin_bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class DeleteOrganizationDialog extends StatefulWidget {
  final String orgId, orgName;
  const DeleteOrganizationDialog(
      {super.key, required this.orgId, required this.orgName});

  @override
  State<DeleteOrganizationDialog> createState() =>
      _DeleteOrganizationDialogState();
}

class _DeleteOrganizationDialogState extends State<DeleteOrganizationDialog> {
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
        if (state is DeleteOrganizationSuccess) {
          Navigator.pop(context);
          showAlertSnackBar(context, translation(context).deleteOrganisationSuccess,
              AlertType.success);
          Navigator.of(context).pop(true);
        } else if (state is DeleteOrganizationFailed) {
          Navigator.pop(context);
          showAlertSnackBar(
              context,
              translation(context).deleteOrganisationFailed,
              AlertType.error);
        }
      },
      child: AlertDialog(
        backgroundColor: white,
        scrollable: true,
        title: Text(
          translation(context).deleteOrganisation,
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
                  widget.orgName,
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
              adminBloc!.add(DeleteOrganization(widget.orgId));
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
