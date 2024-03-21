import 'dart:math';
import 'dart:ui';

extension RectExtensions on Rect {
  Rect rotateAroundCenter(int angleDegrees, [Offset center = Offset.zero]) {
    // 将角度转换为顺时针旋转
    final angleForClockwiseRotation = (360 - angleDegrees) % 360;
    final angleRadians = angleForClockwiseRotation * pi / 180;

    // 将各个顶点相对旋转中心进行平移
    final shiftedTopLeft = topLeft - center;
    final shiftedTopRight = topRight - center;
    final shiftedBottomLeft = bottomLeft - center;
    final shiftedBottomRight = bottomRight - center;

    // 以中心点为中心顺时针旋转每个顶点
    final rotatedTopLeft = _rotatePoint(shiftedTopLeft, angleRadians);
    final rotatedTopRight = _rotatePoint(shiftedTopRight, angleRadians);
    final rotatedBottomLeft = _rotatePoint(shiftedBottomLeft, angleRadians);
    final rotatedBottomRight = _rotatePoint(shiftedBottomRight, angleRadians);

    // 将旋转后的顶点加上旋转中心坐标，还原至全局坐标系
    final newTopLeft = rotatedTopLeft + center;
    final newTopRight = rotatedTopRight + center;
    final newBottomLeft = rotatedBottomLeft + center;
    final newBottomRight = rotatedBottomRight + center;

    // 找到旋转后的新边界
    final newLeft = min(newTopLeft.dx,
        min(newTopRight.dx, min(newBottomLeft.dx, newBottomRight.dx)));
    final newTop = min(newTopLeft.dy,
        min(newTopRight.dy, min(newBottomLeft.dy, newBottomRight.dy)));
    final newRight = max(newTopLeft.dx,
        max(newTopRight.dx, max(newBottomLeft.dx, newBottomRight.dx)));
    final newBottom = max(newTopLeft.dy,
        max(newTopRight.dy, max(newBottomLeft.dy, newBottomRight.dy)));

    // 构造并返回旋转后的新Rect
    return Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }

  Offset _rotatePoint(Offset point, double angleRadians) {
    final x = point.dx;
    final y = point.dy;

    final newX = x * cos(angleRadians) - y * sin(angleRadians);
    final newY = x * sin(angleRadians) + y * cos(angleRadians);

    return Offset(newX, newY);
  }
}
