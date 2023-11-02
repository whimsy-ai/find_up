import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game/core.dart';
import 'package:game/data.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/game/canvas.dart';
import 'package:game/game/controller.dart';
import 'package:game/game/game_bar.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import 'game_helper.dart';

class PageGame extends GetView<GameController> {

  PageGame({super.key}) {
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
    if (Data.showGameHelper) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await GameHelper.show();
        Data.showGameHelper = false;
        controller.start();
      });
    } else {
      controller.start();
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text('Mask'),
        onPressed: () {
          controller.mask ? controller.disableMask() : controller.enableMask();
        },
      ),
      body: Stack(children: [
        GetBuilder<GameController>(
          id: 'game',
          builder: (c) => Opacity(
            opacity: controller.isStarted || controller.isStopped ? 1 : 0,
            child: controller.layer == null
                ? Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : DragAndScaleWidget(
                    layer: c.layer!,
                    layers: c.layers,
                    debug: controller.test,
                    minScale: controller.layer!.width > controller.layer!.height
                        ? Get.width / 3 / controller.layer!.width
                        : Get.height / 2 / controller.layer!.height,
                    scaleEvent: (original) {
                      final half = Get.width / 2;
                      // -2 是纵向分割线的宽度
                      return Offset(
                        original.dx < half
                            ? original.dx
                            : original.dx - half - 2,
                        original.dy,
                      );
                    },
                    builder: (
                      context, {
                      required scale,
                      required minScale,
                      required maxScale,
                      required x,
                      required y,
                    }) {
                      return Row(
                        children: [
                          Expanded(
                            child: ILPCanvas(
                              layout: LayerLayout.left,
                              scale: scale,
                              layers: controller.layers,
                              offsetX: x,
                              offsetY: y,
                              debug: controller.isDebug,
                              mask: controller.maskData,
                            ),
                          ),
                          VerticalDivider(width: 2),
                          Expanded(
                            child: ILPCanvas(
                              layout: LayerLayout.right,
                              scale: scale,
                              layers: controller.layers,
                              offsetX: x,
                              offsetY: y,
                              debug: controller.isDebug,
                              mask: controller.maskData,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        GetBuilder<GameController>(
          id: 'bar',
          builder: (c) => GameBar(controller: c),
        ),
      ]),
    );
  }
}
