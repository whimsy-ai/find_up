import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../extension_path.dart';

class PuzzlePiece {
  final int row, column;
  late ui.Path _path;
  late ui.Image image;
  late double width, height;
  static double peakHeight = 0;
  bool isTarget = false, isFake = false;
  PuzzleEdgeType? left, top, right, bottom;

  double offsetX = 0, offsetY = 0;

  ui.Path get path => _path;

  int _rotate = 0;

  int get rotate => _rotate;

  set rotate(int value) {
    _rotate = value;
    if (value == 90 || value == 270) {
      var w = width;
      width = height;
      height = w;
    }
  }

  PuzzlePiece({
    required this.row,
    required this.column,
    required double pieceWidth,
    required double pieceHeight,
    this.left,
    this.top,
    this.right,
    this.bottom,
  }) {
    _path = ui.Path()
      ..puzzle(
        width: pieceWidth,
        height: pieceHeight,
        top: top,
        right: right,
        bottom: bottom,
        left: left,
      );

    if (left == PuzzleEdgeType.knob) {
      offsetX = -peakHeight;
    }
    if (top == PuzzleEdgeType.knob) {
      offsetY = -peakHeight;
    }
    width = pieceWidth +
        (left == PuzzleEdgeType.knob ? peakHeight : 0) +
        (right == PuzzleEdgeType.knob ? peakHeight : 0);
    height = pieceHeight +
        (top == PuzzleEdgeType.knob ? peakHeight : 0) +
        (bottom == PuzzleEdgeType.knob ? peakHeight : 0);
  }

  PuzzlePiece copyWith({
    required double pieceWidth,
    required double pieceHeight,
    PuzzleEdgeType? left,
    PuzzleEdgeType? top,
    PuzzleEdgeType? right,
    PuzzleEdgeType? bottom,
  }) {
    return PuzzlePiece(
      pieceWidth: pieceWidth,
      pieceHeight: pieceHeight,
      row: row,
      column: column,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  @override
  String toString() {
    return 'PuzzlePiece{left: $left, top: $top, right: $right, bottom: $bottom}';
  }

  static final imagePaint = ui.Paint()
    ..isAntiAlias = true
    ..filterQuality = ui.FilterQuality.high;

  Future<void> draw(
    ui.Image bg,
    double pieceWidth,
    double pieceHeight,
  ) async {
    image = await drawPiece(this, bg, pieceWidth, pieceHeight);
  }

  static Future<ui.Image> drawPiece(
    PuzzlePiece piece,
    ui.Image bg,
    double pieceWidth,
    double pieceHeight,
  ) {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    double x, y;
    if (piece.isTarget) {
      print('target piece fake:${piece.isFake}, ${piece.left} ${piece.top} ${piece.right} ${piece.bottom}');
      canvas.rotate(piece.rotate * math.pi / 180);
      if (piece.rotate == 90) {
        x = piece.left == PuzzleEdgeType.knob ? peakHeight : 0;
        y = piece.bottom == PuzzleEdgeType.knob ? peakHeight : 0;
        print('${piece.column}: y $y');
        canvas.translate(x, -pieceHeight + -y);
        canvas.clipPath(piece.path);
        canvas.drawImage(
          bg,
          -Offset(piece.column * pieceWidth, piece.row * pieceHeight),
          imagePaint,
        );
      } else if (piece.rotate == 180) {
        x = piece.right == PuzzleEdgeType.knob ? peakHeight : 0;
        y = piece.bottom == PuzzleEdgeType.knob ? peakHeight : 0;
        canvas.translate(-pieceWidth + -x, -pieceHeight + -y);
        canvas.clipPath(piece.path);
        canvas.drawImage(
          bg,
          -Offset(piece.column * pieceWidth, piece.row * pieceHeight),
          imagePaint,
        );
      } else if (piece.rotate == 270) {
        x = piece.right == PuzzleEdgeType.knob ? peakHeight : 0;
        y = piece.top == PuzzleEdgeType.knob ? peakHeight : 0;
        canvas.translate(-pieceWidth + -x, y);
        canvas.clipPath(piece.path);
        canvas.drawImage(
          bg,
          -Offset(piece.column * pieceWidth, piece.row * pieceHeight),
          imagePaint,
        );
      } else {
        x = piece.offsetX;
        y = piece.offsetY;
        canvas.translate(-x, -y);
        canvas.clipPath(piece.path);
        canvas.drawImage(bg, -Offset(piece.column * pieceWidth, piece.row * pieceHeight), imagePaint);
      }
      // canvas.drawPath(
      //   piece.path,
      //   Paint()
      //     ..color = Colors.blue.withOpacity(0.7)
      //     ..strokeWidth = 4
      //     ..style = PaintingStyle.stroke,
      // );

      /// 旋转原始path
      piece._path = piece.path.transform(canvas.getTransform());

      /// 原点
      // canvas.drawCircle(Offset.zero, 24, Paint()..color = Colors.red);
    } else {
      x = piece.offsetX;
      y = piece.offsetY;
      canvas.translate(-x, -y);
      canvas.clipPath(piece.path);
      canvas.translate(x, y);
      canvas.drawImage(
        bg,
        -Offset(
          piece.column * pieceWidth + x,
          piece.row * pieceHeight + y,
        ),
        imagePaint,
      );
    }
    return pictureRecorder.endRecording().toImage(
          piece.width.ceil(),
          piece.height.ceil(),
        );
  }
}
