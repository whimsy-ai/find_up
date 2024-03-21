import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../ilp_layer_extend.dart';
import 'is_transparent_pixel.dart';
import 'layer.dart';
import 'level.dart';

enum LevelDifferentType {
  single,
  multi;

  static LevelDifferentType random(math.Random random) => LevelDifferentType
      .values[random.nextInt(LevelDifferentType.values.length)];
}

const _TypeAndTimes = {
  LevelDifferentType.single: 20,
  LevelDifferentType.multi: 120,
};

enum Flip {
  no,
  left,
  right;

  static Flip random(math.Random random) =>
      Flip.values[random.nextInt(Flip.values.length)];
}

class LevelFindDifferences extends Level with LevelLoader {
  final List<ILPCanvasLayer> layers = [];
  final LevelDifferentType type;

  ui.Image? left;
  ui.Image? right;

  /// 是否翻转
  late Flip flip;

  bool get flipLeft => flip == Flip.left;

  bool get flipRight => flip == Flip.right;

  LevelFindDifferences({
    super.mode = LevelMode.findDifferences,
    required super.controller,
    required super.file,
    required super.ilpIndex,
    required this.type,
    this.flip = Flip.no,
  }) {
    flip = Flip.no;
    time = Duration(seconds: 1) * _TypeAndTimes[type]!;
    time += switch (flip) {
      Flip.no => Duration.zero,
      Flip.left ||
      Flip.right =>
        Duration(seconds: LevelDifferentType.single == type ? 10 : 30),
    };
  }

  @override
  int get allLayers => layers.length - 1;

  @override
  Future<void> drawContent() async {
    await Future.wait([
      _drawFindDifferencesImage(layers, LayerLayout.left).then((value) {
        left = value;
      }),
      _drawFindDifferencesImage(layers, LayerLayout.right).then((value) {
        right = value;
      }),
    ]);
  }

  @override
  reset() {
    tappedLayerId.clear();
    layers.clear();
    left = right = null;
  }

  @override
  randomLayers(math.Random random) {
    layers
      ..clear()
      ..addAll(rootLayer!.randomList(
        random: random,
        max: type == LevelDifferentType.single ? 1 : 10,
      ));
  }

  @override
  bool hint() {
    for (var layer in layers) {
      if (layer.isBackground || layer.tapped) continue;
      hintTarget = layer;
      return true;
    }
    return false;
  }

  @override
  Future<ILPCanvasLayer?> onTap(LayerLayout layout, Offset position) async {
    print('==================');
    print('鼠标 $position');
    for (var i = 1; i < layers.length; i++) {
      final layer = layers[i];
      if (!layer.tapped) {
        /// layer original rect
        final rect = layer.rect(layout);

        if (rect.contains(position)) {
          print('rect ${position - rect.topLeft}');
          var content =
              (layout == LayerLayout.left ? layer.left : layer.right) ??
                  (layout == LayerLayout.left ? layer.right : layer.left);
          if (content == null) return null;
          tappedLayerId.add(content.id);
          if (content.hasContent()) {
            final x = (position.dx - rect.topLeft.dx).toInt();
            final y = (position.dy - rect.topLeft.dy).toInt();
            print('相对坐标 $x, $y');
            final isTransparent = await isTransparentPixel(
              content.content as Uint8List,
              x: x,
              y: y,
            );
            print('是否透明 $isTransparent');
            if (!isTransparent) {
              foundLayers++;
              return layer;
            }
          }
        }
      }
    }
    return null;
  }

  @override
  List<String> unlockedLayersId() {
    final list = <String>[];
    for (var layer in layers) {
      if (layer.left?.id != null) list.add(layer.left!.id);
      if (layer.right?.id != null) list.add(layer.right!.id);
    }
    return list;
  }
}

Future<ui.Image> _drawFindDifferencesImage(
  List<ILPCanvasLayer> layers,
  LayerLayout layout,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  var paint = ui.Paint()
    ..isAntiAlias = true
    ..filterQuality = ui.FilterQuality.high;

  /// draw bg
  final bg = layers.first;
  canvas.drawImage(
    await _loadImage(layers.first.left!.content as Uint8List),
    ui.Offset.zero,
    paint,
  );

  /// draw difference layers
  for (var i = 1; i < layers.length; i++) {
    final layer = layers[i];
    if (layout == LayerLayout.left && layer.left != null) {
      canvas.drawImage(
        await _loadImage(layer.left!.content as Uint8List),
        layer.leftRect!.topLeft,
        paint,
      );
    } else if (layout == LayerLayout.right && layer.right != null) {
      canvas.drawImage(
        await _loadImage(layer.right!.content as Uint8List),
        layer.rightRect!.topLeft,
        paint,
      );
    }
  }
  return recorder
      .endRecording()
      .toImage(bg.leftRect!.width.toInt(), bg.leftRect!.height.toInt());
  // final pictureData = await img.toByteData(format: ui.ImageByteFormat.png);
  // return Uint8List.view(pictureData!.buffer);
}

Future<ui.Image> _loadImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
  return completer.future;
}
