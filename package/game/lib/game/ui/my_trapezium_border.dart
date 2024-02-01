import 'dart:math' as math;

import 'package:borders/borders.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyTrapeziumBorder extends OutlinedBorder {
  const MyTrapeziumBorder({
    this.borderOffset = const BorderOffset(),
    this.borderRadius = BorderRadius.zero,
    this.w = 1,
    super.side,
  });

  final double w;
  final BorderOffset borderOffset;
  final BorderRadiusGeometry borderRadius;

  @override
  TrapeziumBorder copyWith({BorderSide? side, BorderOffset? borderOffset}) =>
      TrapeziumBorder(
        borderOffset: borderOffset ?? this.borderOffset,
        side: side ?? this.side,
      );

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final br = borderRadius.resolve(textDirection);
    final tlRadius = br.topLeft.clamp(minimum: Radius.zero);
    final trRadius = br.topRight.clamp(minimum: Radius.zero);
    final brRadius = br.bottomRight.clamp(minimum: Radius.zero);
    final blRadius = br.bottomLeft.clamp(minimum: Radius.zero);

    final topLeft = Offset(
      rect.left - borderOffset.topLeft.dx,
      rect.top - borderOffset.topLeft.dy,
    );
    final topRight = Offset(
      rect.right + borderOffset.topRight.dx,
      rect.top - borderOffset.topRight.dy,
    );
    final bottomRight = Offset(
      rect.right + borderOffset.bottomRight.dx,
      rect.bottom + borderOffset.bottomRight.dy,
    );
    final bottomLeft = Offset(
      rect.left - borderOffset.bottomLeft.dx,
      rect.bottom + borderOffset.bottomLeft.dy,
    );

    final topAngle = topRight.dx == topLeft.dx
        ? 0
        : math.atan((topRight.dy - topLeft.dy) / (topRight.dx - topLeft.dx));
    final rightAngle = bottomRight.dy == topRight.dy
        ? 0
        : math.atan(
            (bottomRight.dx - topRight.dx) / (bottomRight.dy - topRight.dy),
          );
    final bottomAngle = bottomRight.dx == bottomLeft.dx
        ? 0
        : math.atan(
            (bottomRight.dy - bottomLeft.dy) / (bottomRight.dx - bottomLeft.dx),
          );
    final leftAngle = topLeft.dy == bottomLeft.dy
        ? 0
        : math
            .atan((topLeft.dx - bottomLeft.dx) / (topLeft.dy - bottomLeft.dy));

    final path = Path();

    if (tlRadius == Radius.zero) {
      path.moveTo(topLeft.dx, topLeft.dy);
    } else {
      path.moveTo(
        topLeft.dx + tlRadius.x * math.sin(leftAngle),
        topLeft.dy + tlRadius.y * math.cos(leftAngle),
      );
      path.conicTo(
        topLeft.dx,
        topLeft.dy,
        topLeft.dx + tlRadius.x * math.cos(topAngle),
        topLeft.dy + tlRadius.y * math.sin(topAngle),
        w,
      );
      // path.arcToPoint(
      //   Offset(
      //     topLeft.dx + tlRadius.x * math.cos(topAngle),
      //     topLeft.dy + tlRadius.y * math.sin(topAngle),
      //   ),
      //   radius: tlRadius,
      // );
    }

    if (trRadius == Radius.zero) {
      path.lineTo(topRight.dx, topRight.dy);
    } else {
      path.lineTo(
        topRight.dx - trRadius.x * math.cos(topAngle),
        topRight.dy + trRadius.y * math.sin(topAngle),
      );
      path.conicTo(
        topRight.dx,
        topRight.dy,
        topRight.dx + trRadius.x * math.sin(rightAngle),
        topRight.dy + trRadius.y * math.cos(rightAngle),
        w,
      );
    }

    if (brRadius == Radius.zero) {
      path.lineTo(bottomRight.dx, bottomRight.dy);
    } else {
      path.lineTo(
        bottomRight.dx - brRadius.x * math.sin(rightAngle),
        bottomRight.dy - brRadius.y * math.cos(rightAngle),
      );
      path.conicTo(
        bottomRight.dx,
        bottomRight.dy,
        bottomRight.dx - brRadius.x * math.cos(bottomAngle),
        bottomRight.dy - brRadius.y * math.sin(bottomAngle),
        w,
      );
    }

    if (blRadius == Radius.zero) {
      path.lineTo(bottomLeft.dx, bottomLeft.dy);
    } else {
      path.lineTo(
        bottomLeft.dx + blRadius.x * math.cos(bottomAngle),
        bottomLeft.dy - blRadius.y * math.sin(bottomAngle),
      );
      path.conicTo(
        bottomLeft.dx,
        bottomLeft.dy,
        bottomLeft.dx - blRadius.x * math.sin(leftAngle),
        bottomLeft.dy - blRadius.y * math.cos(leftAngle),
        w,
      );
    }

    path.close();

    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final trans = Matrix4.identity()..translate(side.strokeInset);
    final path = _getPath(rect, textDirection: textDirection)
      ..transform(trans.storage);

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final trans = Matrix4.identity()..translate(side.strokeOutset);
    final path = _getPath(rect, textDirection: textDirection)
      ..transform(trans.storage);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) {
      return;
    }
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        canvas.drawPath(
          getOuterPath(rect, textDirection: textDirection),
          side.toPaint(),
        );
    }
  }

  @override
  TrapeziumBorder scale(double t) => TrapeziumBorder(
        side: side.scale(t),
        borderOffset: borderOffset.scale(t),
        borderRadius: borderRadius * t,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is TrapeziumBorder) {
      return TrapeziumBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          a.borderRadius,
          borderRadius,
          t,
        )!,
        borderOffset: BorderOffset.lerp(a.borderOffset, borderOffset, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is TrapeziumBorder) {
      return TrapeziumBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          borderRadius,
          b.borderRadius,
          t,
        )!,
        borderOffset: BorderOffset.lerp(borderOffset, b.borderOffset, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TrapeziumBorder &&
        other.side == side &&
        other.borderOffset == borderOffset &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, borderOffset);

  @override
  String toString() => '${objectRuntimeType(this, 'TrapeziumBorder')}'
      '($side, $borderRadius, $borderOffset)';
}
