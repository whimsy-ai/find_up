import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../data.dart';
import '../game/animated_unlock_progress_bar.dart';
import '../game/drag_and_scale_widget.dart';
import '../get_ilp_info_unlock.dart';
import '../ui.dart';
import 'save_image_controller.dart';

class SaveImageEditor extends GetView<SaveImageController> {
  final void Function(Uint8List bytes) onSave;

  const SaveImageEditor({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                right: BorderSide(
              width: 2,
              color: Theme.of(context).primaryColor,
            )),
          ),
          child: GetBuilder<SaveImageController>(
              id: 'layers',
              builder: (controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.white),
                        ),
                        onPressed: () => Get.back(),
                        child: Icon(Icons.arrow_back_ios),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () => _saveToFile(),
                        icon: Icon(Icons.save_outlined),
                        label: Text(UI.save.tr),
                      ),
                    ),
                    ListTile(title: Text(controller.info.name)),
                    ListTile(
                      title: AnimatedUnlockProgressBar(
                        to: getIlpInfoUnlock(controller.info),
                        height: 24,
                        text: UI.unlock.tr,
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (_, i) => _LayerIcon(index: i),
                        itemCount: controller.layers.length,
                      ),
                    ),
                  ],
                );
              }),
        ),
        Expanded(
          child: DragAndScaleWidget(
            layer: controller.layer,
            layers: [],
            minScale: controller.minScale,
            builder: (
              context, {
              required scale,
              required minScale,
              required maxScale,
              required x,
              required y,
            }) =>
                Stack(
              children: [
                Positioned.fill(
                  left: x,
                  top: y,
                  child: GetBuilder<SaveImageController>(
                    id: 'canvas',
                    builder: (controller) => CustomPaint(
                      painter: _Painter(controller, scale),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded(
        //     child: Stack(
        //   children: [
        //     Obx(
        //       () => Positioned.fill(
        //         left: _offset.value.dx,
        //         top: _offset.value.dy,
        //         child: GetBuilder<SaveImageController>(
        //           id: 'canvas',
        //           builder: (controller) => GestureDetector(
        //             onDoubleTap: () => _offset.value = Offset.zero,
        //             onPanUpdate: (details) {
        //               _offset.value += details.delta;
        //             },
        //             child: CustomPaint(painter: _Painter(controller)),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // )),
      ],
    );
  }

  void _saveToFile() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    var painter = _Painter(controller, 1);

    final size = Size(
        controller.layer.width.toDouble(), controller.layer.height.toDouble());
    painter.paint(canvas, size);
    ui.Image renderedImage = await recorder.endRecording().toImage(
          controller.layer.width,
          controller.layer.height,
        );

    final bytes =
        await renderedImage.toByteData(format: ui.ImageByteFormat.png);
    onSave(bytes!.buffer.asUint8List());
  }
}

class _LayerIcon extends GetView<SaveImageController> {
  final int index;
  late final ILPLayer layer =
      controller.layers[controller.layers.keys.elementAt(index)]!;
  late final _selected = controller.canvasLayer.containsKey(layer);
  late final unlock = Data.layersId.contains(layer.id);

  _LayerIcon({super.key, required this.index});

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
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
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
  final double scale;
  final SaveImageController controller;

  _Painter(this.controller, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    controller.canvasLayer.forEach((key, value) {
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
