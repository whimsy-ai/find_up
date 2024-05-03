import 'package:flutter/material.dart';
import 'package:game/game/drag_and_scale_widget_new.dart';
import 'package:game/game/find_differences/canvas.dart';
import 'package:game/game/find_differences/layer.dart';
import 'package:game/game/find_differences/level_find_differences.dart';
import 'package:game/game/game_state.dart';
import 'package:game/game/game_ui_new.dart';
import 'package:game/game/level_controller.dart';
import 'package:game/game/puzzle/canvas.dart';
import 'package:game/game/puzzle/level_puzzle.dart';
import 'package:get/get.dart';

class PagePlayChallenge<T extends LevelController> extends GetView<T> {
  PagePlayChallenge({super.key}) {
    controller.start();
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
