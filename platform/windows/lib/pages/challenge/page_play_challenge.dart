import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game/data.dart';
import 'package:game/game/canvas_new.dart';
import 'package:game/game/drag_and_scale_widget_new.dart';
import 'package:game/game/game_state.dart';
import 'package:game/game/game_ui_new.dart';
import 'package:game/game/layer.dart';
import 'package:get/get.dart';

import 'pc_game_controller.dart';
import 'game_helper.dart';

class PagePlayChallenge extends GetView<PCGameController> {
  PagePlayChallenge() {
    if (Data.showGameHelper) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await GameHelper.show();
        controller.start();
      });
    } else {
      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: GetBuilder<PCGameController>(
                id: 'game',
                builder: (c) {
                  if (c.state == GameState.started) {
                    return NewDragAndScaleWidget<PCGameController>(
                      builder: (context) => Row(
                        children: [
                          Expanded(
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: NewILPCanvas<PCGameController>(
                                layout: LayerLayout.left,
                              ),
                            ),
                          ),
                          VerticalDivider(width: 2),
                          Expanded(
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: NewILPCanvas<PCGameController>(
                                layout: LayerLayout.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          ),
          Positioned.fill(
              child: GetBuilder<PCGameController>(
                  id: 'ui',
                  builder: (context) => NewGameUI<PCGameController>())),
        ],
      ),
    );
  }
}
