import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:game/extension_path.dart';
import 'package:game/game/puzzle/peak_height.dart';
import 'package:game/game/puzzle/puzzle.dart';
import 'package:game/utils/utf8list_to_image.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

class PageTest2 extends StatefulWidget {
  @override
  State<PageTest2> createState() => _PageTest2State();
}

class _PageTest2State extends State<PageTest2> {
  final ilpPath = r"C:\Users\user\Desktop\dev_chef.ilp";

  final int rows = 5, columns = 4;

  final List<List<PuzzlePiece>> _puzzles = [];
  final List<PuzzlePiece> _right = [];
  final random = math.Random();
  double scale = 1;
  double x = 50, y = 50;

  double pieceWidth = 0, pieceHeight = 0, totalWidth = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    _puzzles.clear();
    _right.clear();
    x = y = 0;
    final ilp = await ILP.fromFile(ilpPath);
    final layer = await ilp.layer(0);
    final bg = await utf8ListToImage(layer.content as Uint8List);
    totalWidth = bg.width.toDouble();
    scale =
        (math.min(Get.width, Get.height) - 50) / math.max(bg.width, bg.height);
    pieceWidth = bg.width / columns;
    pieceHeight = bg.height / rows;
    PuzzlePiece.peakHeight = findPeakHeightWithSize(pieceWidth, pieceHeight);
    print('w $pieceWidth, h $pieceHeight, peak ${PuzzlePiece.peakHeight}');
    for (var row = 0; row < rows; row++) {
      final rowPieces = <PuzzlePiece>[];
      _puzzles.add(rowPieces);
      for (var column = 0; column < columns; column++) {
        PuzzleEdgeType? top, right, bottom, left;
        PuzzlePiece? leftPiece, upPiece;
        if (row > 0) {
          upPiece = _puzzles[row - 1][column];
        }
        if (rowPieces.isNotEmpty) {
          leftPiece = rowPieces.last;
        }
        if (leftPiece == null) {
          right = PuzzleEdgeType.random(random);
        } else {
          left = leftPiece.right == PuzzleEdgeType.hole
              ? PuzzleEdgeType.knob
              : PuzzleEdgeType.hole;
          // print('lastP ${leftPiece.right}=>$left');
          if ((column + 1) < columns) {
            right = PuzzleEdgeType.random(random);
          }
        }
        if (upPiece == null) {
          right = PuzzleEdgeType.random(random);
        } else {
          top = upPiece.bottom == PuzzleEdgeType.hole
              ? PuzzleEdgeType.knob
              : PuzzleEdgeType.hole;
          if ((row + 1) < rows) {
            right = PuzzleEdgeType.random(random);
          }
        }
        final piece = PuzzlePiece(
          pieceWidth: pieceWidth,
          pieceHeight: pieceHeight,
          row: row,
          column: column,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        );
        await piece.draw(bg, pieceWidth, pieceHeight);
        rowPieces.add(piece);
      }
    }
    _right.add(await _piece(_puzzles.first[0], bg, 0));
    _right.add(await _piece(_puzzles.first[1], bg, 90));
    _right.add(await _piece(_puzzles[3][1], bg, 180));
    _right.add(await _piece(_puzzles[2][2], bg, 270));
    _right.add(await _piece(_puzzles[2][2], bg, 270));
    _right.add(await _piece(_puzzles[2][2], bg, 270));
    _right.add(await _piece(_puzzles[2][2], bg, 270));

    setState(() {});
  }

  Future<PuzzlePiece> _piece(
    PuzzlePiece piece,
    ui.Image bg,
    int rotate,
  ) {
    final fake = piece.copyWith(
      pieceWidth: pieceWidth,
      pieceHeight: pieceHeight,
      // top: piece.row == 0 ? null : PuzzleEdgeType.knob,
      // left: piece.column == 0 ? null : PuzzleEdgeType.knob,
      // right: piece.column == columns - 1 ? null : PuzzleEdgeType.knob,
      // bottom: piece.row == rows - 1 ? null : PuzzleEdgeType.knob,
    )
      ..isTarget = true
      ..rotate = rotate;
    return fake.draw(bg, pieceWidth, pieceHeight).then((value) => fake);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _load),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (e) {
          x += e.delta.dx;
          y += e.delta.dy;
          setState(() {});
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _Painter(
                        totalWidth: totalWidth,
                        isLeft: true,
                        puzzles: _puzzles,
                        scale: scale,
                        x: x,
                        y: y,
                        pieceWidth: pieceWidth,
                        pieceHeight: pieceHeight,
                      ),
                    ),
                  ),
                  VerticalDivider(width: 2),
                  Expanded(
                    child: CustomPaint(
                      painter: _Painter(
                        totalWidth: totalWidth,
                        isLeft: false,
                        puzzles: [_right],
                        scale: scale,
                        x: x,
                        y: y,
                        pieceWidth: pieceWidth,
                        pieceHeight: pieceHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: IconButton.outlined(
                onPressed: () => Get.back(),
                icon: Icon(Icons.chevron_left),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  final List<List<PuzzlePiece>> puzzles;
  final double scale, x, y, pieceWidth, pieceHeight, totalWidth;
  final bool isLeft;

  _Painter({
    super.repaint,
    required this.puzzles,
    required this.scale,
    required this.isLeft,
    required this.x,
    required this.y,
    required this.pieceWidth,
    required this.pieceHeight,
    required this.totalWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (puzzles.isEmpty) return;
    isLeft ? paintLeft(canvas, size) : paintRight(canvas, size);
  }

  void paintLeft(Canvas canvas, Size size) {
    canvas
      ..translate(x, y)
      ..scale(scale);
    for (var row in puzzles) {
      for (var piece in row) {
        canvas
          ..drawImage(
            piece.image,
            Offset(piece.offsetX, piece.offsetY),
            PuzzlePiece.imagePaint,
          )
          ..drawPath(
              piece.path,
              Paint()
                ..color = Colors.red
                ..style = PaintingStyle.stroke)
          ..translate(pieceWidth, 0);
      }
      canvas.translate(-row.length * pieceWidth, pieceHeight);
    }
  }

  void paintRight(Canvas canvas, Size size) {
    canvas
      ..translate(x, y)
      ..scale(scale);

    final maxSize = math.max(pieceWidth, pieceHeight) +
        PuzzlePiece.peakHeight * 2 +
        10;

    double translateX = 0;
    for (var piece in puzzles.first) {
      print(
          'totalWidth: $totalWidth, x $translateX, next ${translateX + maxSize}');

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
            ..color = Colors.pink
            ..strokeWidth = 4 / scale
            ..style = PaintingStyle.stroke,
        )
        ..restore();

      if (translateX + maxSize * 2 < totalWidth) {
        canvas.translate(maxSize, 0);
        translateX += maxSize;
      }

      /// 换行
      else {
        print('换行');
        canvas.translate(-translateX, maxSize);
        translateX = 0;
      }
    }
  }
}
