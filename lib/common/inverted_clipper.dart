import 'package:flutter/material.dart';

class InvertedClipper extends CustomClipper<Path> {
  late Paint paint2;
  double left;
  double top, width, height;
  BuildContext context;

  InvertedClipper(this.left, this.top, this.width, this.height, this.context);

  @override
  Path getClip(Size size) {
    Size size = MediaQuery.of(context).size;
    Path p = Path();
    p
      ..addRect(Rect.fromLTRB(left, top, left + width, top + height))
      ..addRect(Rect.fromLTRB(0, 0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
