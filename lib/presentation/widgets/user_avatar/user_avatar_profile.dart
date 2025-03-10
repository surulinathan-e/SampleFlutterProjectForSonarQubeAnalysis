import 'package:flutter/material.dart';
import 'package:tasko/utils/utils.dart';

Color getAvatarColor(int index) {
  List<Color> colors = [
    blueAvatarColor,
    redAvatarColor,
    greenAvatarColor,
    purpleAvatarColor,
    tealAvatarColor
  ];
  return colors[index % colors.length];
}

String getInitials(String name) {
  name = name.trim();
  List<String> names = name.split(' ');
  String initials = '';
  if (names.length > 1) {
    initials = names.first[0] + names.last[0];
  } else if (names.isNotEmpty) {
    initials = names.first.substring(0, names.first.length.clamp(0, 2));
  }
  return initials.toUpperCase();
}
