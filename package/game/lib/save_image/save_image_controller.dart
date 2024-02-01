import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../i_offset_scale.dart';

class SaveImageController extends IOffsetScaleController {
  late double width, height;
  final ILPInfo info;
  final ILPLayer layer;
  @override
  late final minScale = layer.width > layer.height
      ? Get.width / 2 / layer.width
      : Get.height / 2 / layer.height;
  @override
  final maxScale = 4;

  final layers = <String, ILPLayer>{};

  final canvasLayer = <ILPLayer, ui.Image>{};

  SaveImageController({
    required this.info,
    required this.layer,
  }) {
    _a(List<ILPLayer> layers) {
      for (var layer in layers) {
        if (layer.layers.isNotEmpty) {
          _a(layer.layers);
        }
        if (layer.hasContent()) {
          this.layers[layer.id] = layer;
        }
      }
    }

    _a(layer.layers);
    selectLayer(layer);
  }

  selectLayer(ILPLayer layer) async {
    if (canvasLayer.containsKey(layer)) {
      canvasLayer.remove(layer);
    } else {
      canvasLayer[layer] =
          await decodeImageFromList(layer.content as Uint8List);
    }
    update(['canvas', 'layers']);
  }

  @override
  void resetScaleAndOffset() {
    scale = (math.min(width, height) - IOffsetScaleController.padding) /
        math.max(info.width, info.height);
    offsetX = (width - info.width * scale) / 2;
    offsetY = (height - info.height * scale) / 2;
  }
}
