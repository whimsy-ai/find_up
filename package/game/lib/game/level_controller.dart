import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:game/game/resources.dart';
import 'package:get/get.dart';

import '../data.dart';
import '../duration_extension.dart';
import '../explorer/file.dart';
import 'core_controller.dart';
import 'game_state.dart';
import 'hint_controller.dart';
import 'layer.dart';
import 'level.dart';
import 'level_find_differences.dart';
import 'level_puzzle.dart';
import 'loading_controller.dart';
import 'offset_scale_controller.dart';
import 'seed_controller.dart';
import 'sound_controller.dart';

abstract class LevelController extends GetxController
    with
        SeedController,
        CoreController,
        OffsetScaleController,
        SoundController,
        SeedController,
        HintController,
        LoadingController {
  final List<Level> levels = [];
  int current = 0;

  /// for debug
  bool debug = false;
  bool showDebugWidget = false;

  final tapPositions = <Offset>[];

  String? error;

  final List<ExplorerFile> files;
  final int? ilpIndex;

  LevelController({required this.files, this.ilpIndex});

  @override
  void start({int? seed}) async {
    state = GameState.init;
    update(['ui', 'game']);

    levels.clear();
    this.seed = seed ?? math.Random().nextInt(65535);
    final random = math.Random(this.seed);

    super.stop();

    /// 读取游戏资源
    await Resources.init();

    tapPositions.clear();

    current = 0;
    update(['ui', 'game']);

    await loadFile(files.first, random);
    print('total level ${levels.length}');
    state = GameState.already;
    update(['ui', 'game']);

    /// 读取第一关，关卡信息对话框会等待读取
    loadCurrentLevel();

    /// 静默读取其余文件，创建关卡
    for (var i = 1; i < files.length; i++) {
      // print('silent load $i level');
      await loadFile(files[i], random);
    }
  }

  void prevLevel() {
    if (current > 0) {
      current--;
      tapPositions.clear();
      state = GameState.already;
      loadCurrentLevel();
    }
  }

  void nextLevel() {
    if (current < levels.length - 1) {
      current++;
      tapPositions.clear();
      resetBytes();
      loadCurrentLevel();
    } else {
      onLevelFinish();
    }
  }

  Level? get currentLevel => levels.elementAtOrNull(current);

  @override
  void onUpdate(Duration lastFrame) {
    if (state == GameState.started) {
      countdown(lastFrame);
      currentLevel!.onUpdate(lastFrame);
      update(['ui']);
    }
  }

  void onTap(LayerLayout layout, TapUpDetails details) async {
    final offset = Offset(offsetX, offsetY);
    final tapPosition = (details.localPosition - offset) / scale;

    final found = await currentLevel?.onTap(layout, tapPosition);

    if (found == null) {
      playDuckAudio();
    } else {
      playCorrectAudio();
      tapPositions.add(tapPosition);
      found.tappedSide = layout;
      if (found == hintLayer) hintLayer = null;
      update(['ui', 'game']);
    }
    if (currentLevel!.layers.whereNot((l) => l.tapped).isEmpty) {
      currentLevel!.onCompleted();
      onLevelFinish();
    }
  }

  void onLevelFinish() {
    if (current < levels.length - 1) {
      nextLevel();
    } else {
      onCompleted();
    }
    update(['ui', 'game']);
  }

  final _controller = ConfettiController();

  void playConfetti({
    Duration duration = const Duration(seconds: 1),
    double gravity = 0.1,
  }) {
    if (_controller.state == ConfettiControllerState.playing) return;
    _controller.duration = duration;
    final entry = OverlayEntry(
      builder: (_) {
        return Positioned.fill(
          top: -150,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: math.pi / 2,
              maxBlastForce: 50,
              // set a lower max blast force
              minBlastForce: 20,
              // set a lower min blast force
              emissionFrequency: 0.1,
              numberOfParticles: 20,
              gravity: gravity,
              colors: Colors.accents,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ),
        );
      },
    );
    Overlay.of(Get.overlayContext!).insert(entry);
    _controller.play();
  }

  void stopConfetti() {
    if (_controller.state == ConfettiControllerState.playing) {
      _controller.stop();
    }
  }

  Future<void> loadCurrentLevel() async {
    final level = currentLevel;
    if (level == null) return;
    state = GameState.already;
    final load = level.load();
    update(['ui', 'game']);
    await load;
    width = level.width;
    height = level.height;
    level.randomLayers(math.Random(seed));
    await level.draw();
    resetHint();
    resetScaleAndOffset();
    update(['ui', 'game']);
  }

  @override
  void onClose() {
    super.onClose();
    stopConfetti();
    tapPositions.clear();
    _controller.dispose();
  }

  int get allLayers => currentLevel!.allLayers;

  int get foundLayers => currentLevel!.foundLayers;

  String get time => currentLevel!.time.toSemanticString();

  onCompleted() {
    final hasFailed = levels.firstWhereOrNull(
            (element) => element.state == LevelState.failed) !=
        null;
    if (hasFailed) {
      state = GameState.failed;
    } else {
      /// 通关
      playConfetti();
      state = GameState.completed;

      /// store unlocked layers id
      final id = levels.map((e) => e.tappedLayerId).flattened.toSet();
      print('unlocked ${id.length}');
      Data.layersId.addAll(id);
    }
    update(['ui', 'game']);
  }

  void exit();

  @override
  void resetScaleAndOffset() {
    final screenHalfWidth = Get.width / 2;
    final width = currentLevel!.width, height = currentLevel!.height;
    minScale = scale = (math.min(screenHalfWidth, Get.height) -
            OffsetScaleController.padding) /
        math.max(width, height);
    offsetX = (screenHalfWidth - width * scale) / 2;
    offsetY = (Get.height - height * scale) / 2;
  }

  @override
  Future<void> loadFile(ExplorerFile file, math.Random random) async {
    await file.load();

    final ilp = file.ilp!;
    final length = (await ilp.infos).length;
    for (var i = 0; i < length; i++) {
      final mode = LevelMode.random(random);
      switch (mode) {
        case LevelMode.findDifferences:
          levels.add(LevelFindDifferences(
            controller: this,
            file: file,
            ilpIndex: i,
            type: LevelDifferentType.random(random),
            flip: Flip.random(random),
          ));
          break;
        case LevelMode.puzzle:
          levels.add(LevelPuzzle(
            controller: this,
            file: file,
            ilpIndex: i,
            type: LevelPuzzleType.random(random),
          ));
      }
    }
  }
}
