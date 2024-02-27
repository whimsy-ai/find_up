import 'dart:math' as math;

import 'package:ilp_file_codec/ilp_codec.dart';

import 'game/canvas.dart';

extension ILPLayerEx on ILPLayer {
  /// The first element is the background image
  List<ILPCanvasLayer> randomList({
    required math.Random random,
    OnTapLayer? onTap,
    int? max,
  }) {
    final list = <ILPCanvasLayer>{};

    /// the root layers set isGroup = false
    loop(List<ILPLayer> layers, {isGroup = false}) {
      if (max != null && list.length > max) return;
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
              onTap: onTap,
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
                onTap: onTap,
              );
              list.add(canvasLayer);
            }
            if (max != null && list.length > max) break;
          }
        }
      }
    }

    /// 背景图层
    list.add(ILPCanvasLayer(
      name: '背景层',
      layout: LayerLayout.all,
      tappedSide: LayerLayout.all,
      left: this,
      right: this,
      onTap: onTap,
    ));

    /// 其余图层
    while (list.length == 1) {
      loop(layers);
    }

    return list.toList();
  }
}
