import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/game/controller.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

class PageGame extends GetView<GameController> {
  @override
  final String tag;

  PageGame({super.key, required this.tag}) {
    controller.onFinish = _onFinish;
  }

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
      'tag': DateTime.now().toString(),
    })!;
  }

  static Future next(
    ILP ilp, {
    int? index = 0,
    bool? allowDebug = false,
    bool allowPause = false,
    timeMode = TimeMode.up,
  }) =>
      Get.offAndToNamed('/game', arguments: {
        'ilp': ilp,
        'index': index,
        'allowDebug': allowDebug,
        'allowPause': allowPause,
        'timeMode': timeMode,
        'tag': DateTime.now().toString(),
      })!;

  void _onFinish({
    required double pastUnlock,
    required double newUnlock,
    int? nextIndex,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(UI.finish.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedUnlockProgressBar(
              from: pastUnlock,
              to: newUnlock,
              showConfetti: true,
              text: UI.unlock.tr,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(
              '/save',
              arguments: {'info': controller.info, 'layer': controller.layer},
            ),
            child: Text(UI.saveImage.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.reStart();
            },
            child: Text(UI.playAgain.tr),
          ),
          TextButton(
            onPressed: () => Get.back(closeOverlays: true),
            child: Text(UI.back.tr),
          ),
          if (nextIndex != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                PageGame.next(controller.ilp, index: nextIndex);
              },
              child: Text(UI.playNext.tr),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.start();
    return Scaffold(body: controller.body);
  }
}
