import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin OffsetScaleController on GetxController {
  static const double padding = 50;
  double _offsetX = 0, _offsetY = 0, _scale = 1;
  late double width, height;

  double get scale => _scale;

  set scale(double v) {
    _scale = v;
    update(['game']);
  }

  double get offsetX => _offsetX;

  set offsetX(v) {
    _offsetX = v;
    update(['game']);
  }

  double get offsetY => _offsetY;

  set offsetY(v) {
    _offsetY = v;
    update(['game']);
  }

  double minScale = 1;

  double maxScale = 1;

  void resetScaleAndOffset();

  Offset onScalePosition(Offset position);
}
