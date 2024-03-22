import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CircleAnimateWidget extends StatelessWidget {
  final double radius;
  final Color color;
  final double borderWidth;

  const CircleAnimateWidget({
    super.key,
    required this.radius,
    required this.color,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: [5, 5],
      color: color,
      borderType: BorderType.Circle,
      strokeWidth: borderWidth,
      strokeCap: StrokeCap.round,
      child: SizedBox(
        width: radius,
        height: radius,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scaleXY(
          duration: Duration(milliseconds: 500),
          begin: 0.8,
          end: 1.2,
        );
  }
}
