import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game/data.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/game/controller.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import 'game_helper.dart';

class PageGame extends GetView<GameController> {
  @override
  final String tag;

  PageGame({super.key, required this.tag}) {
    controller.onFinish = _onFinish;
  }

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
                PageGameEntry.next(controller.ilp, index: nextIndex);
              },
              child: Text(UI.playNext.tr),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(Data.showGameHelper) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await GameHelper.show();
        Data.showGameHelper = false;
        controller.start();
      });
    }else{
      controller.start();
    }
    return Scaffold(body: controller.body);
  }
}
