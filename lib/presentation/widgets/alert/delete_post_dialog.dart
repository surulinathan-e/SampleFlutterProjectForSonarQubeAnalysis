import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class DeletePostDialog extends StatefulWidget {
  final String postId;
  const DeletePostDialog({super.key, required this.postId});

  @override
  State<DeletePostDialog> createState() => _DeletePostDialogState();
}

class _DeletePostDialogState extends State<DeletePostDialog> {
  PostBloc? postBloc;

  @override
  void initState() {
    postBloc = BlocProvider.of<PostBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      bloc: postBloc,
      listener: (context, state) {
        if (state is DeletePostSuccess) {
          Navigator.pop(context);
          showAlertSnackBar(context, translation(context).postDeleteSuccess,
              AlertType.success);
          Navigator.of(context).pop(true);
        } else if (state is DeletePostFailed) {
          Navigator.pop(context);
          showAlertSnackBar(
              context, translation(context).postDeleteFailed, AlertType.error);
        }
      },
      child: AlertDialog(
        scrollable: true,
        title: Text(
          translation(context).deletePost,
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
              progress(context);
              postBloc!.add(DeletePost(widget.postId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenButtonColor,
            ),
            child: Text(translation(context).delete,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
