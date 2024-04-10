import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:game/data.dart';
import 'package:game/game/drag_and_scale_widget_new.dart';
import 'package:game/game/find_differences/canvas.dart';
import 'package:game/game/find_differences/layer.dart';
import 'package:game/game/find_differences/level_find_differences.dart';
import 'package:game/game/game_state.dart';
import 'package:game/game/game_ui_new.dart';
import 'package:game/game/puzzle/canvas.dart';
import 'package:game/game/puzzle/level_puzzle.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../utils/game_helper_dialog.dart';
import 'pc_game_controller.dart';

class PagePlayChallenge<T extends PCGameController> extends GetView<T> {
  final HotKey _hotKey = HotKey(
    key: PhysicalKeyboardKey.f1,
    // 设置热键范围（默认为 HotKeyScope.system）
    scope: HotKeyScope.inapp, // 设置为应用范围的热键。
  );

  PagePlayChallenge() {
    if (Data.showGameHelper) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await GameHelperDialog.show();
        controller.start();
      });
    } else {
      controller.start();
    }
    if (kDebugMode) {
      hotKeyManager.register(_hotKey, keyDownHandler: (key) {
        controller
          ..showDebugWidget = !controller.showDebugWidget
          ..update(['ui']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: GetBuilder<T>(
                id: 'game',
                builder: (c) {
                  late Widget left, right;
                  if (controller.currentLevel != null) {
                    if (controller.currentLevel is LevelFindDifferences) {
                      left = FindDiffCanvas<T>(
                        layout: LayerLayout.left,
                      );
                      right = FindDiffCanvas<T>(
                        layout: LayerLayout.right,
                      );
                    } else if (controller.currentLevel is LevelPuzzle) {
                      left = PuzzleCanvas<T>(
                        isLeft: true,
                        level: controller.currentLevel as LevelPuzzle,
                      );
                      right = PuzzleCanvas<T>(
                        isLeft: false,
                        level: controller.currentLevel as LevelPuzzle,
                      );
                    }
                  }
                  if (c.state == GameState.started) {
                    return NewDragAndScaleWidget<T>(
                      builder: (context) => Row(
                        children: [
                          Expanded(
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: left,
                            ),
                          ),
                          VerticalDivider(width: 2),
                          Expanded(
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: right,
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
            child: LayoutBuilder(
              builder: (context, constrains) => GetBuilder<T>(
                id: 'ui',
                builder: (context) => NewGameUI<T>(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
