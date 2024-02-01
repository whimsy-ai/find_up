import 'package:flutter/material.dart';

class CompletedWidget extends StatelessWidget {
  final double height;

  const CompletedWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
    );
  }
}
