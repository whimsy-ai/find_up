import 'package:get/get.dart';

import 'level.dart';

mixin HintController on GetxController {
  final divider = const Duration(seconds: 20);

  int _times = 0;
  Duration _time = Duration.zero;

  Duration get nextHintTime => _time;

  bool showHint(Level? level) {
    if (_time > Duration.zero) return false;
    if (level != null) {
      final res = level.hint();
      update(['game', 'ui']);
      if (res) {
        _times++;
        _setTimer();
        return true;
      }
    }
    return false;
  }

  void resetHint(Level? level) {
    if (level != null) {
      level.hintTarget = null;
    }
    _times = 0;
    _time = Duration.zero;
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
