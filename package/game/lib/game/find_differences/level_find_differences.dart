import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../is_transparent_pixel.dart';
import '../level.dart';
import 'layer.dart';

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
    layers.clear();
    left = right = null;
  }

  @override
  randomLayers(math.Random random) {
    layers
      ..clear()
      ..addAll(_randomList(
        rootLayer: rootLayer!,
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
  Future<Duration?> onTap(LayerLayout layout, Offset position) async {
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
          if (content != null && content.hasContent()) {
            final x = (position.dx - rect.topLeft.dx).toInt();
            final y = (position.dy - rect.topLeft.dy).toInt();
            print('相对坐标 $x, $y');
            final isTransparent = await isTransparentPixel(
              content.content as Uint8List,
              x: x,
              y: y,
            );
            print('是否透明 $isTransparent');

            /// 点击到图层的不透明部分，判断为成功点击
            if (!isTransparent) {
              foundLayers++;
              layer.tappedSide = layout;
              if (layer == hintTarget) {
                hintTarget = null;
              }
              return null;
            }
          }
        }
      }
    }
    return Duration(seconds: 8);
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

List<ILPCanvasLayer> _randomList({
  required ILPLayer rootLayer,
  required math.Random random,
  int? max,
}) {
  final list = <ILPCanvasLayer>[];

  /// the root layers set isGroup = false
  loop(List<ILPLayer> layers, {isGroup = false}) {
    final List<ILPLayer> contents = [];
    for (var layer in layers) {
      if (layer.content.isNotEmpty) {
        contents.add(layer);
      } else if (layer.layers.isNotEmpty) {
        loop(layer.layers, isGroup: true);
      }
    }
    if (contents.isNotEmpty) {
      if (isGroup) {
        final isShow = random.nextBool();
        if (isShow) {
          final layer = contents[random.nextInt(contents.length)];
          ILPLayer? otherLayer;

          /// if show other side layer
          /// 如果另外一边也要显示内容
          if (random.nextBool()) {
            contents.remove(layer);
            if (contents.isNotEmpty) {
              otherLayer = contents[random.nextInt(contents.length)];
            }
          }
          final leftSide = random.nextBool();
          final canvasLayer = ILPCanvasLayer(
            name: layer.name,
            layout: leftSide ? LayerLayout.left : LayerLayout.right,
            left: leftSide ? layer : otherLayer,
            right: leftSide ? otherLayer : layer,
          );
          list.add(canvasLayer);
        }
      } else {
        for (var layer in contents) {
          final isShow = random.nextBool();
          if (isShow) {
            final leftSide = random.nextBool();
            final canvasLayer = ILPCanvasLayer(
              name: layer.name,
              layout: leftSide ? LayerLayout.left : LayerLayout.right,
              left: leftSide ? layer : null,
              right: leftSide ? null : layer,
            );
            list.add(canvasLayer);
          }
        }
      }
    }
  }

  /// 其余图层
  while (list.isEmpty) {
    loop(rootLayer.layers);
  }
  list.shuffle(random);
  if (max != null && list.length > max) {
    final newList = list.sublist(0, max);
    list
      ..clear()
      ..addAll(newList);
  }

  /// 背景图层
  list.insert(
      0,
      ILPCanvasLayer(
        name: '背景层',
        layout: LayerLayout.all,
        tappedSide: LayerLayout.all,
        left: rootLayer,
        right: rootLayer,
      ));

  return list;
}
