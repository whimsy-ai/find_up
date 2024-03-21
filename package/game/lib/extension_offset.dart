import 'dart:math' as math;
import 'dart:ui';

extension OffsetExtensions on Offset {
  Offset rotateClockwise(int angleDegrees) {
    // 将角度转换为顺时针旋转
    final angleForClockwiseRotation = (360 - angleDegrees) % 360;

    // 角度转弧度
    final angleRadians = angleForClockwiseRotation * math.pi / 180;

    // 根据旋转角度计算新的坐标值（顺时针旋转）
    final newX = dx * math.cos(angleRadians) - dy * math.sin(angleRadians);
    final newY = dx * math.sin(angleRadians) + dy * math.cos(angleRadians);

    return Offset(newX, newY);
  }

  Offset rotateCounterClockwise(int angleDegrees) {
    // 角度转弧度
    final angleRadians = angleDegrees * math.pi / 180;

    // 根据旋转角度计算新的坐标值（逆时针旋转）
    final newX = dx * math.cos(angleRadians) - dy * math.sin(angleRadians);
    final newY = dx * math.sin(angleRadians) + dy * math.cos(angleRadians);

    return Offset(newX, newY);
  }
}
