import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

mixin MouseController on GetxController {
  bool isLeft = true;
  Offset _position = Offset.zero;

  Offset get position => _position;

  set position(Offset v) {
    _position = v;
    update(['game']);
  }

  onHover(PointerHoverEvent e) {
    isLeft = e.position.dx < (Get.width - 2) / 2;
    position = e.localPosition;
  }
}
