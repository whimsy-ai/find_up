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

  ///todo
  static LevelMode random(math.Random random) => LevelMode.findDifferences;
  // static LevelMode random(math.Random random) =>
  // LevelMode.values[random.nextInt(LevelMode.values.length)];
}

mixin LevelLoader on Level {
  Future<ILPInfo> loadILPInfo() => file.ilp!.info(ilpIndex);

  Future<ILPLayer> loadILPLayer() => file.ilp!.layer(ilpIndex);

  Future<void> drawContent();
}

abstract class Level {
  LevelState state = LevelState.loading;
  final Set<String> tappedLayerId = {};
  final LevelController controller;
  final ExplorerFile file;
  final int ilpIndex;
  final List<ILPCanvasLayer> layers = [];
  final LevelMode mode;
  late double width, height;

  late Duration time;
  ILPLayer? layer;
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
        layer = value;
        width = layer!.width.toDouble();
        height = layer!.height.toDouble();
      }),
    ]);
  }

  Future<void> draw() async {
    state = LevelState.drawing;
    await (this as LevelLoader).drawContent();
    state = LevelState.already;
  }

  ILPCanvasLayer? hint();

  void randomLayers(math.Random random);

  List<String> unlockedLayersId() {
    final list = <String>[];
    for (var layer in layers) {
      if (layer.left?.id != null) list.add(layer.left!.id);
      if (layer.right?.id != null) list.add(layer.right!.id);
    }
    return list;
  }

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
