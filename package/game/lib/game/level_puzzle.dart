import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ilp_file_codec/ilp_codec.dart';

import '../extension_path.dart';
import '../ilp_layer_extend.dart';
import 'layer.dart';
import 'level.dart';

enum LevelPuzzleType {
  content,
  piece;

  static LevelPuzzleType random(math.Random random) =>
      LevelPuzzleType.values[random.nextInt(LevelPuzzleType.values.length)];
}

class PuzzlePiece {
  final ILPLayer layer;
  final ui.Image image;
  PuzzleEdgeType? left, top, right, bottom;

  PuzzlePiece({
    required this.layer,
    required this.image,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  @override
  String toString() {
    return 'PuzzlePiece{left: $left, top: $top, right: $right, bottom: $bottom}';
  }
}

class LevelPuzzle extends Level with LevelLoader {
  final LevelPuzzleType type;
  final pieces = <List<PuzzlePiece>>[];

  LevelPuzzle({
    super.mode = LevelMode.puzzle,
    required super.controller,
    required super.file,
    required super.ilpIndex,
    required this.type,
  }) {
    time = Duration(seconds: 60);
  }

  @override
  int get allLayers => layers.length - 1;

  @override
  Future<void> drawContent() async {}

  @override
  ILPCanvasLayer? hint() {
    return null;
  }

  @override
  Future<ILPCanvasLayer?> onTap(LayerLayout layout, ui.Offset position) async {
    if (layout == LayerLayout.left) return null;
    return null;
  }

  @override
  void reset() {}

  @override
  void randomLayers(math.Random random) {
    layers
      ..clear()
      ..addAll(layer!.randomList(
        random: random,
        max: 1,
      ));
  }
}
