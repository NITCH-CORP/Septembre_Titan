import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  double height;

  double width;

  var color;

  MyDivider(
      {super.key,
      required this.width,
      required this.height,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
      ),
    );
  }
}