import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import 'game_state.dart';
import 'level_controller.dart';
import 'resources.dart';
import 'stroke_shadow.dart';
import 'ui/level_desc_widget.dart';
import 'ui/paused_widget.dart';
import 'ui/score_bar.dart';
import 'ui/steam_downloading_indicator.dart';
import 'ui/tip_tool_widget.dart';

class NewGameUI<T extends LevelController> extends GetView<T> {
  const NewGameUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (controller.isLoading)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
                SizedBox(height: 10),
                Text(UI.loading.tr),
                if (controller.totalBytes > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: 200,
                      child: SteamDownloadIndicator<T>(),
                    ),
                  ),
              ],
            ),
          ),

        if (controller.isLoadError)
          Center(
            child: AlertDialog(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 50,
                    color: Colors.amber,
                  ),
                  Text(UI.loadingError.tr),
                ],
              ),
              content: Text(controller.error ?? UI.unKnowError.tr),
              actions: [
                TextButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text(UI.retry.tr),
                  onPressed: () => controller.start(),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.chevron_left_rounded),
                  label: Text(UI.back.tr),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

        /// 左上
        /// 返回按钮
        if (controller.state != GameState.init)
          Positioned(
            top: 10,
            left: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () => controller.exit(),
                    elevation: 0,
                    child: StrokeShadow.path(Resources.iconLeft),
                  ),
                ),
              ],
            ),
          ),

        /// 关卡介绍对话框
        if (controller.state == GameState.already)
          Center(child: LevelDescriptionBuilder<T>()),

        /// 时间栏
        /// 得分栏
        if (controller.state.value > GameState.already.value)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ScoreBar<T>(),
            ),
          ),

        /// 右上
        /// 暂停按钮
        if (controller.state == GameState.started)
          Positioned(
              top: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      elevation: 0,
                      child: StrokeShadow.path(
                        Resources.iconPause,
                      ),
                      onPressed: () {
                        if (controller.isStarted) {
                          controller.pause();
                        } else if (controller.isPaused) {
                          controller.resume();
                        }
                      },
                    ),
                  ),
                ],
              )),

        /// 左下
        if (controller.showDebugWidget)
          Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                color: Colors.white.withOpacity(0.6),
                padding: EdgeInsets.all(8),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Text([
                      'Debug',
                      'seed:${controller.seed}',
                      'scale:${controller.scale}',
                      'level:${controller.current + 1} / ${controller.levels.length}',
                      'layers: ${controller.currentLevel?.allLayers}'
                    ].join('\n')),
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.prevLevel();
                            controller.update(['ui', 'game']);
                          },
                          child: Text('Previous'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.start();
                          },
                          child: Icon(Icons.refresh),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.nextLevel();
                            controller.update(['ui', 'game']);
                          },
                          child: Text('Next'),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        Text('debug'),
                        SizedBox(
                          width: 30,
                          height: 20,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                                value: controller.debug,
                                onChanged: (v) {
                                  controller.debug = v;
                                  controller.update(['ui', 'game']);
                                }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),

        /// 右下
        /// 提示功能
        if (controller.isStarted)
          Positioned(
            bottom: 10,
            right: 10,
            child: Wrap(
              spacing: 10,
              children: [
                if (controller.debug)
                  ElevatedButton(
                    onPressed: controller.setFail,
                    child: Text('使失败'),
                  ),
                TipToolWidget<T>(),
              ],
            ),
          ),

        /// 暂停界面
        if (controller.isPaused)
          Positioned(
            bottom: Get.height / 2 - 100,
            left: 0,
            right: 0,
            child: PausedWidget<T>(height: 200),
          ),

        /// 失败界面
        if (controller.isFailed)
          Positioned(
            bottom: Get.height / 2 - 100,
            left: 0,
            right: 0,
            child: PausedWidget<T>(title: UI.failed.tr, height: 200),
          ),

        /// 完成界面
        if (controller.isCompleted)
          Positioned(
            bottom: Get.height / 2 - 100,
            left: 0,
            right: 0,
            child: PausedWidget<T>(title: UI.finish.tr, height: 200),
          ),
      ],
    );
  }
}
