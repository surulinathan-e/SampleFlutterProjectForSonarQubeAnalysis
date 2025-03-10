import 'package:flutter/material.dart';

import './network_widgets.dart';

showModal(BuildContext context, Function reload) {
  showModalBottomSheet(
    shape: Border.all(),
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (BuildContext context) {
      return Scaffold(
          body: Center(child: NetworkWidgets.netWorkStatus(context, reload)));
    },
  );
}
