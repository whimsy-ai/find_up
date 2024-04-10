import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

import '../../extension_duration.dart';
import '../find_differences/level_find_differences.dart';
import '../game_state.dart';
import '../level.dart';
import '../level_controller.dart';
import 'levels_indicator.dart';

class LevelDescriptionBuilder<T extends LevelController> extends GetView<T> {
  static final _loadingStyle = TextStyle(
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel!;
    final loading = level.state != LevelState.already;
    return AlertDialog(
      title: Text(_title),
      content: _content,
      actions: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        if (loading) _loading(),
        ElevatedButton(
          onPressed: loading
              ? null
              : () {
                  controller
                    ..state = GameState.started
                    ..core.start()
                    ..update(['ui', 'game']);
                },
          child: Text(UI.startGame.tr),
        ),
      ],
    );
  }

  String get _title {
    final inSeconds = '${UI.inSeconds.tr.replaceFirst(
      '%s',
      controller.currentLevel!.time.toSemanticString(),
    )}, ';
    return switch (controller.currentLevel!.mode) {
      LevelMode.findDifferences =>
        (controller.currentLevel as LevelFindDifferences).type ==
                LevelDifferentType.single
            ? inSeconds + UI.findOneLayer.tr
            : inSeconds + UI.findAllLayers.tr,
      LevelMode.puzzle => inSeconds + UI.findPuzzles.tr,
    };
  }

  Widget get _content {
    final level = controller.currentLevel!;
    final desc = SizedBox(
      height: 120,
      child: switch (level.mode) {
        LevelMode.findDifferences =>
          _findDiffImages((level as LevelFindDifferences).type),
        LevelMode.puzzle => _puzzleImages(),
      },
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        desc,
        SizedBox(height: 10),
        if (controller.current > 0) LevelsIndicator<T>(),
      ],
    );
  }

  Widget _loading() {
    var text = UI.loading.tr;
    if (controller.totalBytes > 0) text += ' ${controller.downloadedPercent} %';
    return Text(
      text,
      style: _loadingStyle,
    );
  }
}

Widget _findDiffImages(LevelDifferentType type) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        type == LevelDifferentType.single
            ? 'assets/images/monalisa_left.png'
            : 'assets/images/monalisa_left_multi.png',
        package: 'game',
      ),
      SizedBox(width: 8),
      VerticalDivider(width: 1),
      SizedBox(width: 8),
      Image.asset(
        type == LevelDifferentType.single
            ? 'assets/images/monalisa_right.png'
            : 'assets/images/monalisa_right_multi.png',
        package: 'game',
      ),
    ],
  );
}

Widget _puzzleImages() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/monalisa_puzzle_left.png',
        package: 'game',
      ),
      SizedBox(width: 8),
      VerticalDivider(width: 1),
      SizedBox(width: 8),
      Image.asset(
        'assets/images/monalisa_puzzle_right.png',
        width: 160,
        package: 'game',
      ),
    ],
  );
}
