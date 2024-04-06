import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../data.dart';
import '../game/animated_unlock_progress_bar.dart';
import '../game/drag_and_scale_widget_new.dart';
import '../get_ilp_info_unlock.dart';
import 'save_image_controller.dart';

class SaveImageEditor<T extends SaveImageController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// 左边图层列表
        GetBuilder<T>(
            id: 'ui',
            builder: (c) {
              if (c.loading) {
                return SizedBox.shrink();
              }
              return Expanded(
                flex: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: Text(UI.saveImage.tr),
                      actions: [
                        ElevatedButton.icon(
                          onPressed: () => _saveToFile(),
                          icon: Icon(Icons.save_outlined),
                          label: Text(UI.save.tr),
                        )
                      ],
                    ),
                    ListTile(title: Text(controller.info.name)),
                    ListTile(
                      title: AnimatedUnlockProgressBar(
                        to: getIlpInfoUnlock(controller.info),
                        height: 24,
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (_, i) => _LayerIcon<T>(index: i),
                        itemCount: controller.layers.length,
                      ),
                    ),
                  ],
                ),
              );
            }),

        VerticalDivider(width: 2),

        /// 右边图片预览
        Expanded(
          flex: 300,
          child: GetBuilder<T>(
            id: 'game',
            builder: (c) {
              if (c.loading) {
                return Center(child: CircularProgressIndicator());
              }
              return LayoutBuilder(
                builder: (c, constrains) {
                  return NewDragAndScaleWidget<T>(
                    builder: (c) => ClipRect(
                      clipBehavior: Clip.antiAlias,
                      child: CustomPaint(
                        size: constrains.biggest,
                        painter: _Painter(controller),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveToFile() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = ui.Canvas(recorder);
    double x = controller.offsetX,
        y = controller.offsetY,
        scale = controller.scale;
    controller.offsetX = controller.offsetY = 0.0;
    controller.scale = 1.0;
    var painter = _Painter(controller);

    final size = Size(controller.width, controller.height);
    painter.paint(canvas, size);
    ui.Image renderedImage = await recorder.endRecording().toImage(
          controller.layer.width,
          controller.layer.height,
        );
    controller.offsetX = x;
    controller.offsetY = y;
    controller.scale = scale;

    final bytes =
        await renderedImage.toByteData(format: ui.ImageByteFormat.png);
    controller.onSave(bytes!.buffer.asUint8List());
  }
}

class _LayerIcon<T extends SaveImageController> extends GetView<T> {
  final int index;
  late final ILPLayer layer =
      controller.layers[controller.layers.keys.elementAt(index)]!;
  late final _selected = controller.selectedLayers.containsKey(layer);
  late final unlock = Data.layersId.contains(layer.id);

  _LayerIcon({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: !unlock
          ? Icon(Icons.lock_outline_rounded)
          : InkWell(
              onTap: () => controller.selectLayer(layer),
              child: ColoredBox(
                color: _selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.memory(layer.content as Uint8List),
                ),
              ),
            ),
    );
  }
}

// class _LayerListTile extends GetView<SaveImageController> {
//   final ILPLayer layer;
//   late final _selected = controller.canvasLayer.containsKey(layer);
//   late final unlock = Data.layersId.contains(layer.id);
//
//   _LayerListTile({super.key, required this.layer});
//
//   @override
//   Widget build(BuildContext context) {
//     if (!unlock) {
//       return ListTile(
//         leading: Icon(Icons.lock_outline_rounded),
//         title: Text(layer.name),
//       );
//     }
//     return Material(
//       child: ListTile(
//         selected: _selected,
//         selectedTileColor: Colors.blueGrey.withOpacity(0.2),
//         title: Text(layer.name),
//         leading: Image.memory(
//           layer.content as Uint8List,
//           width: 20,
//           height: 20,
//         ),
//         onTap: () => controller.selectLayer(layer),
//       ),
//     );
//   }
// }

class _Painter extends CustomPainter {
  final SaveImageController controller;

  _Painter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(controller.offsetX, controller.offsetY);
    canvas.scale(controller.scale);
    controller.selectedLayers.forEach((key, value) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(
          key.x.toDouble(),
          key.y.toDouble(),
          key.width.toDouble(),
          key.height.toDouble(),
        ),
        image: value,
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
