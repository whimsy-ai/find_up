import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

enum LayerLayout {
  all,
  left,
  right,
}

typedef LayoutWidgetBuilder = Widget? Function(
  BuildContext context, {
  required LayerLayout layout,
  required double scale,
});

abstract interface class ILayerBuilder {
  String get name;

  Rect? rect(LayerLayout layout);

  final LayerLayout layout;
  LayerLayout? tappedSide;

  bool get tapped => tappedSide != null;

  LayoutWidgetBuilder get builder;

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

  @override
  LayoutWidgetBuilder get builder => (
        _, {
        required LayerLayout layout,
        required double scale,
      }) =>
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                )),
          );

  LabelLayer({
    super.layout = LayerLayout.all,
    required this.index,
    required this.position,
    this.color = Colors.red,
    this.size = 30,
  });

  @override
  Rect rect(layout) => Rect.fromPoints(position, position + Offset(size, size));
  @override
  late final name = '$index';
}

class ILPCanvasLayer extends ILayerBuilder {
  final bool isBackground;
  @override
  final String name;
  ILPLayer? left, right;

  Rect? get leftRect => _rect(left);

  Rect? get rightRect => _rect(right);

  @override
  Rect? rect(layout) {
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
    return rect;
  }

  final void Function(
    LayerLayout clicked,
    ILPCanvasLayer layer,
    Offset position,
  ) onTap;

  @override
  LayoutWidgetBuilder get builder => (
        context, {
        required LayerLayout layout,
        required double scale,
      }) {
        if (isBackground) {
          // print('背景');
          return Image.memory(
            left!.content as Uint8List,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          );
        }

        final isLeftCanvas = layout == LayerLayout.left;

        ILPLayer? layer = isLeftCanvas ? left : right;
        Rect? rect = isLeftCanvas ? leftRect : rightRect;
        if (tapped) {
          if (isLeftCanvas) {
            layer = right ?? left;
            rect = rightRect ?? leftRect;
          } else {
            layer = left ?? right;
            rect = leftRect ?? rightRect;
          }
        } else {
          layer ??= left ?? right;
          rect ??= leftRect ?? rightRect;
        }
        if (layer != null) {
          return Image.memory(
            layer.content as Uint8List,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          );
        }
        if (rect != null) {
          return SizedBox(width: rect.width, height: rect.height);
        }
        return null;
      };

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
}

final _debugStyle = BoxDecoration(color: Colors.blue.withOpacity(0.3));

class ILPCanvas extends StatelessWidget {
  final double scale;
  final LayerLayout layout;
  final List<ILayerBuilder> layers;
  final double offsetX, offsetY;
  final bool debug;
  late final isLeft = layout == LayerLayout.left;

  ILPCanvas({
    super.key,
    required this.layout,
    required this.scale,
    required this.layers,
    required this.offsetX,
    required this.offsetY,
    this.debug = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (detail) {
        final position =
            (detail.localPosition - Offset(offsetX, offsetY)) / scale;
// print('点击位置 $position');
        for (final ILPCanvasLayer layer
            in layers.whereType<ILPCanvasLayer>().toList().reversed) {
          final rect = layer.rect(layout);
          if (rect?.contains(position) == true) {
            layer.onTap(layout, layer, position);
            if (layout == LayerLayout.left) {
              layer.right = layer.left;
            } else {
              layer.left = layer.right;
            }
            break;
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...(layers.map((l) => _layerWrapper(context, l))).nonNulls,
          if (debug)
            ...layers
                .whereType<ILPCanvasLayer>()
                .where((l) => !l.isBackground && !l.tapped)
                .map((l) {
              final rect = l.rect(layout);
              if (rect == null) return null;
              return Positioned(
                left: offsetX + rect.left * scale,
                top: offsetY + rect.top * scale,
                width: rect.width * scale,
                height: rect.height * scale,
                child: IgnorePointer(child: Container(decoration: _debugStyle)),
              );
            }).nonNulls,
        ],
      ),
    );
  }

  Widget? _layerWrapper(BuildContext context, ILayerBuilder layer) {
    Widget? child = layer.builder(context, layout: layout, scale: scale);
    if (child == null) return null;
    if (layer is ILPCanvasLayer) {
      final rect = isLeft ? layer.leftRect : layer.rightRect;
      if (rect != null) {
        return Positioned(
          left: offsetX + rect.left * scale,
          top: offsetY + rect.top * scale,
          width: rect.width * scale,
          height: rect.height * scale,
          child: GestureDetector(
            child: child,
          ),
        );
      }
    } else if (layer is LabelLayer) {
      final rect = layer.rect(layout);
      return Positioned(
        left: offsetX + rect.left * scale - rect.height / 2,
        top: offsetY + rect.top * scale - rect.height / 2,
        width: rect.width,
        height: rect.height,
        child: child,
      );
    }
    return null;
  }
}
