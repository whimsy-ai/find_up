import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'layer.dart';
import 'level_controller.dart';
import 'level_find_differences.dart';
import 'mouse_controller.dart';

class NewILPCanvas<T extends LevelController> extends GetView<T> {
  final LayerLayout layout;

  const NewILPCanvas({super.key, required this.layout});

  @override
  Widget build(BuildContext context) {
    final hintRect =
        controller.hintLayer?.leftRect ?? controller.hintLayer?.rightRect;
    final child = GestureDetector(
      onTapUp: (e) => controller.onTap(layout, e),
      child: CustomPaint(
        isComplex: true,
        foregroundPainter:
            GetPlatform.isDesktop ? _MousePainter(controller, layout) : null,
        painter: _BackGroundPaint(
          controller: controller,
          layout: layout,
        ),
        child: Stack(
          children: [
            if (hintRect != null)
              Positioned(
                left: controller.offsetX + (hintRect.left * controller.scale),
                top: controller.offsetY + (hintRect.top * controller.scale),
                width: hintRect.width * controller.scale,
                height: hintRect.height * controller.scale,
                child: Container(
                  color: Colors.green.withOpacity(0.7),
                ),
              )
          ],
        ),
      ),
    );
    return GetPlatform.isDesktop
        ? MouseRegion(
            onHover: (controller as MouseController).onHover,
            child: child,
          )
        : child;
  }
}

class _BackGroundPaint extends CustomPainter {
  static final _tapPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeMiterLimit = 0.2
    ..strokeWidth = 3;

  final LevelController controller;
  final LayerLayout layout;

  _BackGroundPaint({
    super.repaint,
    required this.controller,
    required this.layout,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final level = controller.currentLevel as LevelFindDifferences;
    // print('_Paint paint');
    final flip = (level.flipLeft && layout == LayerLayout.left ||
        level.flipRight && layout == LayerLayout.right);
    canvas.save();
    if (flip) {
      canvas.translate(controller.offsetX + level.width * controller.scale,
          controller.offsetY);
    } else {
      canvas.translate(controller.offsetX, controller.offsetY);
    }
    canvas.save();
    canvas.scale(controller.scale);
    if (flip) {
      canvas.scale(-1, 1);
    }

    /// draw layers
    canvas.drawImage(
      layout == LayerLayout.left ? level.left! : level.right!,
      Offset.zero,
      Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true,
    );

    /// draw hint layer
    // final layer = controller.hintLayer;
    // if (layer != null) {
    //   var rect = layer.leftRect;
    //   if (rect == null) {
    //     rect = layer.rightRect;
    //   } else if (layer.rightRect != null) {
    //     rect = rect.expandToInclude(layer.rightRect!);
    //   }
    //   if (rect != null) {
    //     canvas.drawRect(
    //       rect,
    //       Paint()
    //         ..strokeWidth = 2 / controller.scale
    //         ..style = PaintingStyle.stroke
    //         ..color = Colors.red,
    //     );
    //   }
    // }

    /// draw debug stroke
    if (controller.debug) {
      for (var i = 1; i < level.layers.length; i++) {
        final layer = level.layers[i];
        if (layer.tapped) continue;
        canvas.drawRect(
          layer.rect(layout),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.red,
        );
      }
    }
    canvas.restore();
    canvas.restore();

    /// draw tap positions
    if (controller.tapPositions.isNotEmpty) {
      final offset = Offset(controller.offsetX, controller.offsetY);
      for (var pos in controller.tapPositions) {
        canvas.drawCircle(pos * controller.scale + offset, 10, _tapPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_BackGroundPaint oldDelegate) => true;
}

/// draw a fake mouse
class _MousePainter extends CustomPainter {
  static final _mouseLineLength = 10 * Get.pixelRatio;
  static final _mousePaint = Paint()
    ..color = Colors.yellow
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 5;
  static final _mousePath = Path()
    ..moveTo(0, 0)
    ..relativeLineTo(_mouseLineLength, 0)
    ..moveTo(0, 0)
    ..relativeLineTo(0, _mouseLineLength);

  final LayerLayout layout;
  final LevelController controller;

  _MousePainter(this.controller, this.layout);

  @override
  void paint(Canvas canvas, Size size) {
    if (controller is MouseController) {
      final mouse = controller as MouseController;
      if ((mouse.isLeft && layout == LayerLayout.right) ||
          (!mouse.isLeft && layout == LayerLayout.left)) {
        final matrix4 = Matrix4.identity()
          ..setRotationZ(-8 * math.pi / 180)
          ..setTranslationRaw(mouse.position.dx, mouse.position.dy, 1);
        canvas.drawPath(_mousePath.transform(matrix4.storage), _mousePaint);
        // canvas.drawPoints(
        //   PointMode.polygon,
        //   [
        //     mouse.position + Offset(_mouseLineLength, 0),
        //     mouse.position,
        //     mouse.position + Offset(0, _mouseLineLength),
        //   ],
        //   _mousePaint,
        // );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
