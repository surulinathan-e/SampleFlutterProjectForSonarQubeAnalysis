import 'package:flutter/material.dart';

getCircle(String value, Color selectedColor) {
  return Container(
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border(
            top: BorderSide(width: 3, color: selectedColor),
            left: BorderSide(width: 3, color: selectedColor),
            right: BorderSide(width: 3, color: selectedColor),
            bottom: BorderSide(width: 3, color: selectedColor))),
    child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 12,
        child: Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedColor,
                fontSize: 15))),
  );
}

getLine(Color selectedColor) {
  return Expanded(child: Divider(color: selectedColor, thickness: 3));
}
