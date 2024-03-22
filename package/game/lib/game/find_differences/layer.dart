import 'package:flutter/material.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../level.dart';

enum LayerLayout {
  all,
  left,
  right,
}

class ILPCanvasLayer extends Tapped {
  final LayerLayout layout;
  LayerLayout? tappedSide;

  @override
  bool get isTarget => true;

  @override
  bool get tapped => tappedSide != null;
  final bool isBackground;
  final String name;
  final ILPLayer? left, right;

  bool highlight = false;

  Rect? get leftRect => _rect(left);

  Rect? get rightRect => _rect(right);

  bool get isAll => layout == LayerLayout.all;

  bool get isLeft => layout == LayerLayout.left;

  Rect rect(layout) {
    final isLeftCanvas = layout == LayerLayout.left;
    Rect? rect = isLeftCanvas ? leftRect : rightRect;
    if (tapped) {
      if (isLeftCanvas) {
        rect = rightRect ?? leftRect;
      } else {
        rect = leftRect ?? rightRect;
      }
    } else {
      rect ??= leftRect ?? rightRect;
    }
    return rect!;
  }

  bool get isNotEmpty => left != null || right != null;

  ILPCanvasLayer({
    required this.name,
    required this.layout,
    this.tappedSide,
    this.left,
    this.right,
  })  : isBackground = layout == LayerLayout.all,
        assert(left != null || right != null);
}

Rect? _rect(ILPLayer? layer) {
  return layer == null
      ? null
      : Rect.fromLTWH(
          layer.x.toDouble(),
          layer.y.toDouble(),
          layer.width.toDouble(),
          layer.height.toDouble(),
        );
}
