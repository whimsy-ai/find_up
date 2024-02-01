import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game/core.dart';
import 'package:game/data.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/game/canvas.dart';
import 'package:game/game/controller.dart';
import 'package:game/game/game_ui.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:window_manager/window_manager.dart';

import 'game_helper.dart';

class PageGame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageGame();
}

class _PageGame extends State<PageGame> with WindowListener {
  late final controller = Get.find<GameController>();

  @override
  void initState() {
    super.initState();
    controller.onFinish = _onFinish;
    windowManager.addListener(this);
  }

  @override
  void onWindowResize() {
    super.onWindowResize();
    print('onWindowResize');
    controller.update(['ui']);
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    print('onWindowResized');
    controller.update(['ui']);
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    print('onWindowMaximize');
    controller.update(['ui']);
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
          /// 导出图片
          TextButton(
            onPressed: () => Get.toNamed(
              '/save',
              arguments: {'info': controller.info, 'layer': controller.layer},
            ),
            child: Text(UI.saveImage.tr),
          ),

          /// 再玩一次
          TextButton(
            onPressed: () {
              Get.back();
              controller.start();
            },
            child: Text(UI.playAgain.tr),
          ),

          /// 返回
          TextButton(
            onPressed: () => Get.back(closeOverlays: true),
            child: Text(UI.back.tr),
          ),

          /// 玩下一张图片
          if (nextIndex != null)
            ElevatedButton(
              onPressed: () => PageGameEntry.replace(
                controller.ilp,
                index: nextIndex,
              ),
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
        controller.start();
      });
    } else {
      controller.start();
    }
    return Scaffold(
      body: Stack(children: [
        GetBuilder<GameController>(
          id: 'game',
          builder: (c) {
            if (controller.state.value < GameState.already.value) {
              return SizedBox.shrink();
            }
            return Opacity(
              opacity: c.opacity,
              child: DragAndScaleWidget(
                controller: controller,
                layer: c.layer!,
                layers: c.layers,
                debug: controller.test,
                scaleEvent: (original) {
                  final half = Get.width / 2;
                  // -2 是纵向分割线的宽度
                  return Offset(
                    original.dx < half ? original.dx : original.dx - half - 2,
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
                          debug: controller.isDebug,
                        ),
                      ),
                      VerticalDivider(width: 2),
                      Expanded(
                        child: ILPCanvas(
                          layout: LayerLayout.right,
                          debug: controller.isDebug,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        GetBuilder<GameController>(
          id: 'ui',
          builder: (c) => GameUI(controller: c),
        ),
      ]),
    );
  }
}
