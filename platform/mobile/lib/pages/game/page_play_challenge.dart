import 'package:flutter/material.dart';
import 'package:game/game/drag_and_scale_widget_new.dart';
import 'package:game/game/find_differences/canvas.dart';
import 'package:game/game/find_differences/layer.dart';
import 'package:game/game/game_state.dart';
import 'package:game/game/game_ui_new.dart';
import 'package:game/game/level_controller.dart';
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
                  if (c.state == GameState.started) {
                    return NewDragAndScaleWidget<T>(
                      builder: (context) => Row(
                        children: [
                          Expanded(
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: FindDiffCanvas<T>(
                                layout: LayerLayout.left,
                              ),
                            ),
                          ),
                          VerticalDivider(width: 2),
                          Expanded(
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: FindDiffCanvas<T>(
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
