import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart' hide GetNumUtils;
import 'package:ilp_file_codec/ilp_codec.dart';

import 'canvas.dart';
import 'controller.dart';

class LayerWidget extends GetView<GameController> {
  final ILPCanvasLayer layer;
  final LayerLayout parent;

  const LayerWidget({super.key, required this.layer, required this.parent});

  @override
  Widget build(BuildContext context) {
    Widget? child;
    Rect? rect;
    if (layer.isBackground) {
      child = Image.memory(
        layer.left!.content as Uint8List,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      );
      rect = _rect(layer.left!);
    } else {
      final isLeft = parent == LayerLayout.left;
      ILPLayer? ilpLayer;
      if (!layer.tapped) {
        ilpLayer = isLeft ? layer.left : layer.right;
      } else {
        if (layer.tappedSide == LayerLayout.left) {
          ilpLayer = layer.left;
        } else if (layer.tappedSide == LayerLayout.right) {
          ilpLayer = layer.right;
        }
      }
      rect = _rect(ilpLayer);
      if (ilpLayer != null) {
        child = Image.memory(
          ilpLayer.content as Uint8List,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        );
        if (layer.highlight) {
          child = _HighlightWidget(
            opacity: 0.5,
            child: child,
          );
        }
      } else if (layer.highlight) {
        child = Opacity(
          opacity: 0.5,
          child: _HighlightWidget(
            opacity: 1,
            child: Image.memory(
              (layer.left ?? layer.right)!.content as Uint8List,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ),
        );
      }
    }
    rect ??= _rect(layer.left ?? layer.right)!;
    child ??= SizedBox(width: rect.width, height: rect.height);

    return Positioned(
      left: controller.offsetX + rect.left * controller.scale,
      top: controller.offsetY + rect.top * controller.scale,
      width: rect.width * controller.scale,
      height: rect.height * controller.scale,
      child: child,
    );
  }
}

class _HighlightWidget extends StatelessWidget {
  final Widget child;
  final double opacity;

  const _HighlightWidget({
    super.key,
    required this.child,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 1000.ms,
          size: 3,
          colors: Colors.accents.map((e) => e.withOpacity(opacity)).toList(),
        )
        .animate();
  }
}

class LabelWidget extends GetView<GameController> {
  final LayerLayout parent;
  final LabelLayer layer;

  const LabelWidget({super.key, required this.layer, required this.parent});

  @override
  Widget build(BuildContext context) {
    final rect = layer.rect(parent);
    return Positioned(
      left: controller.offsetX + rect.left * controller.scale - rect.height / 2,
      top: controller.offsetY + rect.top * controller.scale - rect.height / 2,
      width: rect.width,
      height: rect.height,
      child: Container(
        width: layer.size,
        height: layer.size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: layer.color,
              width: 2,
            )),
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
