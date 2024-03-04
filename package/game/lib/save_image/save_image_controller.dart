import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../explorer/file.dart';
import '../game/offset_scale_controller.dart';

abstract class SaveImageController extends GetxController
    with OffsetScaleController {
  final ExplorerFile file;
  final int index;
  final double flex;
  bool loading = true;

  late ILPInfo info;
  late ILPLayer layer;

  final layers = <String, ILPLayer>{};

  final selectedLayers = <ILPLayer, ui.Image>{};

  @override
  double get maxScale => 3;

  SaveImageController({
    required this.file,
    required this.index,
    required this.flex,
  }) {
    loadLayers();
  }

  Future<void> load();

  Future<void> onSave(Uint8List data);

  loadLayers() async {
    loading = true;
    update(['ui', 'game']);
    await load();
    await selectLayer(layer);
    loading = false;

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

    width = layer.width.toDouble();
    height = layer.height.toDouble();
    resetScaleAndOffset();
    update(['ui', 'game']);
  }

  Future<void> selectLayer(ILPLayer layer) async {
    if (selectedLayers.containsKey(layer)) {
      selectedLayers.remove(layer);
    } else {
      selectedLayers[layer] =
          await decodeImageFromList(layer.content as Uint8List);
    }
    update(['game', 'ui']);
  }

  @override
  void resetScaleAndOffset() {
    final layoutWidth = Get.width * flex;
    final layoutHeight = Get.height;
    print('resetScaleAndOffset layout $layoutWidth, $layoutHeight');
    minScale = scale = (math.min(layoutWidth, layoutHeight) -
            OffsetScaleController.padding) /
        math.max(width, height);
    offsetX = (layoutWidth - width * scale) / 2;
    offsetY = (layoutHeight - height * scale) / 2;
  }

  @override
  ui.Offset onScalePosition(ui.Offset position) => position;
}
