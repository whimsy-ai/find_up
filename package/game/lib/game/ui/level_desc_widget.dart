import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import '../../duration_extension.dart';
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
        if (loading)
          Text(
            UI.loading.tr,
            style: _loadingStyle,
          ),
        TextButton(
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
    final inSeconds = UI.inSeconds.trParams(
        {'seconds': controller.currentLevel!.time.toSemanticString()});
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
    if (controller.levels.length < 2) return SizedBox.shrink();
    return LevelsIndicator<T>();
  }
}
