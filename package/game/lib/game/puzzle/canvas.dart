import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../find_differences/layer.dart';
import '../level_controller.dart';
import 'level_puzzle.dart';
import 'puzzle.dart';

class PuzzleCanvas<T extends LevelController> extends GetView<T> {
  final bool isLeft;
  final LevelPuzzle level;

  const PuzzleCanvas({
    super.key,
    required this.isLeft,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTapUp: (e) {
        if (!isLeft) {
          controller.onTap(LayerLayout.right, e);
        }
      },
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        painter: _Painter(
          controller: controller,
          isLeft: isLeft,
          level: level,
        ),
      ),
    );
    return isLeft
        ? child
        : MouseRegion(
            onHover: (e) {
              level.mouse = e.localPosition;
              {
                final maxSize = math.max(level.pieceWidth, level.pieceHeight) +
                    PuzzlePiece.peakHeight * 2 +
                    10;
                final mx = Matrix4.identity()
                  ..scale(controller.scale, controller.scale, 1);
                double translateX = 0, translateY = 0;
                for (var piece in level.layers) {
                  final x = (maxSize - piece.width) / 2,
                      y = (maxSize - piece.height) / 2;
                  var offset = Offset(
                    controller.offsetX + (translateX + x) * controller.scale,
                    controller.offsetY + (translateY + y) * controller.scale,
                  );
                  var path = piece.path.transform(mx.storage).shift(offset);
                  piece.highlight = path.contains(e.localPosition);
                  if (translateX + maxSize * 2 < level.width) {
                    translateX += maxSize;
                  }

                  /// 换行
                  else {
                    translateY += maxSize;
                    translateX = 0;
                  }
                }
              }
            },
            child: child,
          );
  }
}

class _Painter extends CustomPainter {
  final LevelController controller;

  final bool isLeft;
  final LevelPuzzle level;

  _Painter({
    super.repaint,
    required this.controller,
    required this.isLeft,
    required this.level,
  });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..translate(controller.offsetX, controller.offsetY)
      ..scale(controller.scale);
    isLeft ? _drawLeft(canvas, size) : _drawRight(canvas, size);

    /// draw other debug info
  }

  void _drawLeft(Canvas canvas, Size size) {
    for (var row in level.pieces) {
      for (var piece in row) {
        if (!piece.rightSide) {
          canvas
            ..drawImage(
              piece.image,
              Offset(piece.offsetX, piece.offsetY),
              PuzzlePiece.imagePaint,
            )
            ..drawPath(
              piece.path,
              Paint()
                ..color = level.lineColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2 / controller.scale,
            );
        }
        canvas.translate(level.pieceWidth, 0);
      }
      canvas.translate(-row.length * level.pieceWidth, level.pieceHeight);
    }
  }

  void _drawRight(Canvas canvas, Size size) {
    final maxSize = math.max(level.pieceWidth, level.pieceHeight) +
        PuzzlePiece.peakHeight * 2 +
        10;
    double translateX = 0;
    final bgColor = Colors.blueGrey.withOpacity(0.2);
    for (var i = 0; i < level.layers.length; i++) {
      var piece = level.layers[i];
      final x = (maxSize - piece.width) / 2, y = (maxSize - piece.height) / 2;
      final pathPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (piece.highlight ? 5 : 2) / controller.scale
        ..color =
            controller.debug && piece.isTarget ? Colors.red : level.lineColor;
      canvas
        ..save()
        ..drawRect(
          Rect.fromPoints(
            Offset.zero,

            /// 画出间隔
            Offset(maxSize - 1, maxSize - 1),
          ),
          Paint()..color = bgColor,
        )
        ..translate(x, y)
        ..drawImage(
          piece.image,
          Offset.zero,
          PuzzlePiece.imagePaint,
        )
        ..drawPath(piece.path, pathPaint)
        ..restore();

      /// debug info
      if (controller.debug) {
        TextPainter(
            text: TextSpan(
                text: '${piece.rotate}',
                style: TextStyle(
                  fontSize: 14 / controller.scale,
                  color: Colors.red,
                )),
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: maxSize)
          ..paint(canvas, Offset(x, y));
      }

      if (translateX + maxSize * 2 < level.width) {
        canvas.translate(maxSize, 0);
        translateX += maxSize;
      }

      /// 换行
      else {
        canvas.translate(-translateX, maxSize);
        translateX = 0;
      }
    }
  }
}
