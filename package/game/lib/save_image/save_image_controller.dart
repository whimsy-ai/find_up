import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

class SaveImageController extends GetxController {
  Offset offset = Offset.zero;
  final ILPInfo info;
  final ILPLayer layer;
  late final minScale = layer.width > layer.height
      ? Get.width / 2 / layer.width
      : Get.height / 2 / layer.height;
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
}
