import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'controller.dart';

class PageGameEntry {
  static Future play(
    ILP ilp, {
    int? index = 0,
    bool? allowDebug = false,
    bool allowPause = false,
    timeMode = TimeMode.up,
  }) {
    print('play game');
    return Get.toNamed('/game', arguments: {
      'ilp': ilp,
      'index': index,
      'allowDebug': allowDebug,
      'allowPause': allowPause,
      'timeMode': timeMode,
    })!;
  }

  static replace(ILP ilp, {
    int? index = 0,
    bool? allowDebug = false,
    bool allowPause = false,
    timeMode = TimeMode.up,
  }) async {
    Get.back(closeOverlays: true);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      Get.toNamed('/game', arguments: {
        'ilp': ilp,
        'index': index,
        'allowDebug': allowDebug,
        'allowPause': allowPause,
        'timeMode': timeMode,
      })!;
    });
  }
}
