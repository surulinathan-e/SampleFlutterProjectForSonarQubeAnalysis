import 'package:flutter/material.dart';
import 'package:tasko/presentation/widgets/common/loading.dart';

void progress(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Loading(),
        );
      });
}