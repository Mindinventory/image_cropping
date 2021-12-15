import 'package:flutter/material.dart';

Widget appIconButton(
    {required IconData icon,
    required Color background,
    required void Function() onPress,
    double margin = 20,
    double size = 17,
    Color iconColor = Colors.white}) {
  return InkWell(
    onTap: onPress,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      child: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
    ),
  );
}
