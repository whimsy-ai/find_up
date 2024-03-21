import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return GestureDetector(
      onTapDown: (e) {},
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
  }

  void _drawLeft(Canvas canvas, Size size) {
    for (var row in level.pieces) {
      for (var piece in row) {
        if (!piece.isTarget) {
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
                  ..style = PaintingStyle.stroke);
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
    for (var piece in level.targets) {
      final x = (maxSize - piece.width) / 2, y = (maxSize - piece.height) / 2;
      canvas
        ..save()
        ..translate(x, y)
        ..drawImage(
          piece.image,
          Offset.zero,
          PuzzlePiece.imagePaint,
        )
        ..drawPath(
          piece.path,
          Paint()
            ..color =
                controller.debug && piece.isFake ? Colors.red : level.lineColor
            ..style = PaintingStyle.stroke,
        )
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
