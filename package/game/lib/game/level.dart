import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../explorer/file.dart';
import 'layer.dart';
import 'level_controller.dart';

typedef OnTapLayer = void Function(LayerLayout layou, TapUpDetails e);

enum LevelState {
  loading(0),
  drawing(1),
  already(2),
  completed(3),
  failed(4);

  final int value;

  const LevelState(this.value);
}

enum LevelMode {
  findDifferences,
  puzzle;

  static LevelMode random(math.Random random) => LevelMode.puzzle;
  // LevelMode.values[random.nextInt(LevelMode.values.length)];
}

mixin LevelLoader on Level {
  Future<ILPInfo> loadILPInfo() => file.ilp!.info(ilpIndex);

  Future<ILPLayer> loadILPLayer() => file.ilp!.layer(ilpIndex);

  Future<void> drawContent();
}

abstract class Level<T> {
  LevelState state = LevelState.loading;
  final Set<String> tappedLayerId = {};
  final LevelController controller;
  final ExplorerFile file;
  final int ilpIndex;
  final LevelMode mode;
  late double width, height;

  dynamic hintTarget;
  late Duration time;
  ILPLayer? rootLayer;
  ILP? ilp;
  ILPInfo? info;

  Level({
    required this.controller,
    required this.file,
    required this.ilpIndex,
    required this.mode,
  });

  void reset();

  Future<void> load() {
    state = LevelState.loading;
    final loader = this as LevelLoader;
    ilp = file.ilp;
    return Future.wait([
      loader.loadILPInfo().then((value) => info = value),
      loader.loadILPLayer().then((value) {
        rootLayer = value;
        width = rootLayer!.width.toDouble();
        height = rootLayer!.height.toDouble();
      }),
    ]);
  }

  Future<void> draw() async {
    state = LevelState.drawing;
    await (this as LevelLoader).drawContent();
    state = LevelState.already;
  }

  /// 显示提示，成功返回true，失败返回false
  bool hint();

  void randomLayers(math.Random random);

  List<String> unlockedLayersId();

  Future<ILPCanvasLayer?> onTap(LayerLayout layout, Offset position);

  void onUpdate(Duration frame) {
    time -= frame;
    if (time < Duration.zero) {
      state = LevelState.failed;
      controller.nextLevel();
    }
  }

  void onCompleted() {
    state = LevelState.completed;
  }

  int get allLayers;

  int foundLayers = 0;
}
