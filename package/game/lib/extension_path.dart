import 'dart:math' as math;
import 'dart:ui';

enum PuzzleEdgeType {
  knob, // 凸
  hole // 凹
  ;

  static PuzzleEdgeType random(math.Random random) =>
      PuzzleEdgeType.values[random.nextInt(PuzzleEdgeType.values.length)];
}

extension PathExtension on Path {
  void puzzle({
    required double width,
    required double height,
    PuzzleEdgeType? top,
    PuzzleEdgeType? right,
    PuzzleEdgeType? bottom,
    PuzzleEdgeType? left,
    double minSize = 20,
  }) {
    final min = math.min(width, height);
    final lockingSize = math.max(min / 3, minSize);
    final openingSize = math.max(min / 4, minSize);
    final deep = (lockingSize - lockingSize / 2) * 2;
    moveTo(0, 0);
    if (top == null) {
      lineTo(width, 0);
    } else {
      final y = (top == PuzzleEdgeType.knob ? -1 : 1) * deep;
      this
        ..lineTo((width - openingSize) / 2, 0)
        ..cubicTo(
          (width - lockingSize * 3) / 2,
          y,
          width - (width - lockingSize * 3) / 2,
          y,
          width - (width - openingSize) / 2,
          0,
        )
        ..lineTo(width, 0);
    }

    if (right == null) {
      lineTo(width, height);
    } else {
      final x = (right == PuzzleEdgeType.knob ? 1 : -1) * deep;
      this
        ..lineTo(width, (height - openingSize) / 2)
        ..cubicTo(
          width + x,
          (height - lockingSize * 3) / 2,
          width + x,
          height - (height - lockingSize * 3) / 2,
          width,
          height - (height - openingSize) / 2,
        )
        ..lineTo(width, height);
    }

    if (bottom == null) {
      lineTo(0, height);
    } else {
      final y = (bottom == PuzzleEdgeType.knob ? 1 : -1) * deep;
      this
        ..lineTo(width - (width - openingSize) / 2, height)
        ..cubicTo(
          width - (width - lockingSize * 3) / 2,
          height + y,
          (width - lockingSize * 3) / 2,
          height + y,
          (width - openingSize) / 2,
          height,
        )
        ..lineTo(0, height);
    }

    if (left == null) {
      lineTo(0, 0);
    } else {
      final x = (left == PuzzleEdgeType.knob ? -1 : 1) * deep;
      this
        ..lineTo(0, height - (height - openingSize) / 2)
        ..cubicTo(
          x,
          height - (height - lockingSize * 3) / 2,
          x,
          (height - lockingSize * 3) / 2,
          0,
          (height - openingSize) / 2,
        )
        ..lineTo(0, 0);
    }
    close();
  }
}
