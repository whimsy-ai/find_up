import 'package:flutter/services.dart';
import 'package:game/game/level_controller.dart';
import 'package:get/get.dart';

/// for mobile
class MobileGameController extends LevelController {
  MobileGameController({
    required super.files,
    required super.mode,
    super.ilpIndex,
  });

  @override
  void exit() {
    Get.back();
  }

  @override
  Offset onScalePosition(Offset position) {
    return Offset((position.dx - 2) / 2, position.dy);
  }
}
