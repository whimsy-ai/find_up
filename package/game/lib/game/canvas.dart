import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'controller.dart';
import 'layer_widgets.dart';

enum LayerLayout {
  all,
  left,
  right,
}

abstract interface class ILayerBuilder {
  String get name;

  final LayerLayout layout;
  LayerLayout? tappedSide;

  bool get tapped => tappedSide != null;

  ILayerBuilder({
    required this.layout,
    this.tappedSide,
  });

  bool get isAll => layout == LayerLayout.all;

  bool get isLeft => layout == LayerLayout.left;
}

class LabelLayer extends ILayerBuilder {
  final int index;
  final Color color;
  final Offset position;
  final double size;

  LabelLayer({
    super.layout = LayerLayout.all,
    required this.index,
    required this.position,
    this.color = Colors.red,
    this.size = 30,
  });

  @override
  late final name = '$index';

  Rect rect(layout) => Rect.fromPoints(position, position + Offset(size, size));
}

class ILPCanvasLayer extends ILayerBuilder {
  final bool isBackground;
  @override
  final String name;
  final ILPLayer? left, right;

  bool highlight = false;

  Rect? get leftRect => _rect(left);

  Rect? get rightRect => _rect(right);

  Rect rect(layout) {
    final isLeftCanvas = layout == LayerLayout.left;
    Rect? rect = isLeftCanvas ? leftRect : rightRect;
    if (tapped) {
      if (isLeftCanvas) {
        rect = rightRect ?? leftRect;
      } else {
        rect = leftRect ?? rightRect;
      }
    } else {
      rect ??= leftRect ?? rightRect;
    }
    return rect!;
  }

  final void Function(
    LayerLayout clicked,
    ILPCanvasLayer layer,
    Offset position,
  ) onTap;

  bool get isNotEmpty => left != null || right != null;

  ILPCanvasLayer({
    required this.name,
    required super.layout,
    required this.onTap,
    super.tappedSide,
    this.left,
    this.right,
  })  : isBackground = layout == LayerLayout.all,
        assert(left != null || right != null);
}

final _debugStyle = BoxDecoration(color: Colors.blue.withOpacity(0.3));

class ILPCanvas extends GetView<GameController> {
  final LayerLayout layout;
  final bool debug;
  late final isLeft = layout == LayerLayout.left;
  late final offsetX = controller.offsetX, offsetY = controller.offsetY;
  late final scale = controller.scale;
  late final layers = controller.layers;

  ILPCanvas({
    super.key,
    required this.layout,
    this.debug = false,
  });

  @override
  Widget build(BuildContext context) {
    final ilpLayers = <ILPCanvasLayer>[];
    final labelLayers = <LabelLayer>[];
    for (var layer in controller.layers) {
      if (layer is ILPCanvasLayer) {
        ilpLayers.add(layer);
      } else if (layer is LabelLayer) {
        labelLayers.add(layer);
      }
    }
    return GestureDetector(
      onTapUp: (detail) {
        final position =
            (detail.localPosition - Offset(offsetX, offsetY)) / scale;
        // print('点击位置 $position');
        for (final layer in ilpLayers.reversed) {
          final rect = layer.rect(layout);
          if (rect.contains(position) == true) {
            layer.onTap(layout, layer, position);
            break;
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...ilpLayers.map((l) => LayerWidget(parent: layout, layer: l)),
          ...labelLayers
              .whereType<LabelLayer>()
              .map((l) => LabelWidget(parent: layout, layer: l)),
          // if (debug)
          //   ...ilpLayers
          //       .where((l) => !l.isBackground && !l.tapped)
          //       .map((l) {
          //     final rect = l.rect(layout);
          //     if (rect == null) return null;
          //     return Positioned(
          //       left: offsetX + rect.left * scale,
          //       top: offsetY + rect.top * scale,
          //       width: rect.width * scale,
          //       height: rect.height * scale,
          //       child: IgnorePointer(child: Container(decoration: _debugStyle)),
          //     );
          //   }).nonNulls,
        ],
      ),
    );
  }
}

Rect? _rect(ILPLayer? layer) {
  return layer == null
      ? null
      : Rect.fromLTWH(
          layer.x.toDouble(),
          layer.y.toDouble(),
          layer.width.toDouble(),
          layer.height.toDouble(),
        );
}
