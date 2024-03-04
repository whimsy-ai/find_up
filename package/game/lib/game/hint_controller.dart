import 'package:get/get.dart';

import 'layer.dart';
import 'level.dart';

mixin HintController on GetxController {
  final divider = const Duration(seconds: 20);
  ILPCanvasLayer? hintLayer;

  int _times = 0;
  Duration _time = Duration.zero;

  Duration get nextHintTime => _time;

  bool showHint(Level? currentLevel) {
    if (_time > Duration.zero) return false;
    if (currentLevel != null) {
      hintLayer = currentLevel.hint();
      update(['game', 'ui']);
      if (hintLayer != null) {
        _times++;
        _setTimer();
        return true;
      }
    }
    return false;
  }

  void resetHint() {
    _times = 0;
    _time = Duration.zero;
    hintLayer = null;
    update(['game', 'ui']);
  }

  void _setTimer() {
    _time = divider * _times;
  }

  void countdown(Duration frame) {
    if (_time < Duration.zero) return;
    _time -= frame;
  }
}
