import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import '../../extension_duration.dart';
import '../game_state.dart';
import '../level.dart';
import '../level_controller.dart';
import '../level_find_differences.dart';
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
      content: _content(),
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
    final inSeconds = UI.inSeconds.tr.replaceFirst(
      '%s',
      controller.currentLevel!.time.toSemanticString(),
    );
    return switch (controller.currentLevel!.mode) {
      LevelMode.findDifferences =>
        (controller.currentLevel as LevelFindDifferences).type ==
                LevelDifferentType.single
            ? inSeconds + UI.findOneLayer.tr
            : inSeconds + UI.findAllLayers.tr,
      LevelMode.puzzle => inSeconds + UI.findPuzzles.tr,
    };
  }

  Widget _content() {
    final level = controller.currentLevel!;
    final desc = switch (level.mode) {
      LevelMode.findDifferences => SizedBox(
          height: 100,
          child: _imageRow((level as LevelFindDifferences).type),
        ),
      LevelMode.puzzle => SizedBox.shrink(),
    };
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

Widget _imageRow(LevelDifferentType tpe) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        tpe == LevelDifferentType.single
            ? 'assets/images/monalisa_left.png'
            : 'assets/images/monalisa_left_multi.png',
        package: 'game',
      ),
      VerticalDivider(width: 1),
      Image.asset(
        tpe == LevelDifferentType.single
            ? 'assets/images/monalisa_right.png'
            : 'assets/images/monalisa_right_multi.png',
        package: 'game',
      ),
    ],
  );
}
