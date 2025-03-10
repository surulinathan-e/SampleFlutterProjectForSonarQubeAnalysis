//loading circle
import 'package:flutter/material.dart';
import 'package:tasko/utils/utils.dart';

Widget showCirclularLoading() {
  return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    CircularProgressIndicator(color: primaryColor)
    // SizedBox(height: 20.0),
    // Text("Loading..."),
  ]));
}
