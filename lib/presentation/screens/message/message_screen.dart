import 'package:flutter/material.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/utils/utils.dart';

class MessageScreen extends StatefulWidget {
  final Function? onBack;
  const MessageScreen({super.key, this.onBack});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: bgColor, body: _buildBody());
  }

  Widget _buildBody() {
    return Center(
        child: Text(translation(context).chatWindow,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: black)));
  }
}
