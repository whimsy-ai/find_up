import 'dart:ui';

import 'package:flutter/material.dart';

class MaskData {
  final Offset center;
  final double radius;
  final Color color;

  MaskData({
    required this.center,
    required this.radius,
    required this.color,
  });

  static MaskData lerp(MaskData a, MaskData b, double t) {
    return MaskData(
      center: Offset(
        lerpDouble(a.center.dx, b.center.dx, t)!,
        lerpDouble(a.center.dy, b.center.dy, t)!,
      ),
      radius: lerpDouble(a.radius, b.radius, t)!,
      color: Color.lerp(a.color, b.color, t)!,
    );
  }
}

class Mask extends StatelessWidget {
  final MaskData data;
  final double scale;

  const Mask({
    super.key,
    required this.data,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: MaskPainter(
      data: data,
      scale: scale,
    ));
  }
}

class MaskPainter extends CustomPainter {
  final MaskData data;
  final double scale;

  MaskPainter({
    super.repaint,
    required this.data,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = data.color;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTRB(0, 0, size.width, size.height)),
        Path()
          ..addOval(Rect.fromCircle(
              center: data.center * scale, radius: data.radius * scale))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
