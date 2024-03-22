import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game/extension_path.dart';
import 'package:game/game/puzzle/puzzle.dart';
import 'package:game/utils/utf8list_to_image.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

class PageTest extends StatefulWidget {
  @override
  State<PageTest> createState() => _PageTestState();
}

class _PageTestState extends State<PageTest> {
  final ilpPath = r"C:\Users\user\Desktop\dev_chef.ilp";
  final List<List<PuzzlePiece>> pieces = [];
  final List<PuzzlePiece> targets = [];

  final int rows = 5, columns = 4;

  ui.Image? _bg;
  final random = math.Random();
  double scale = 0;

  double x = 0, y = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    x = y = 0;
    pieces.clear();
    targets.clear();
    setState(() {});
    late ILPLayer layer;
    await Future.wait([
      ILP.fromFile(ilpPath).then((ilp) => ilp.layer(0)).then((v) {
        layer = v;
        return utf8ListToImage(layer.content as Uint8List);
      }).then((value) => _bg = value),
      Future.delayed(Duration(milliseconds: 1500)),
    ]);
    final pieceWidth = _bg!.width / columns, pieceHeight = _bg!.height / rows;

    scale = (math.min(Get.width / 2, Get.height) - 50) /
        math.max(_bg!.width, _bg!.height);
    print('w $pieceHeight, h $pieceWidth');
    for (var row = 0; row < rows; row++) {
      final rowPieces = <PuzzlePiece>[];
      pieces.add(rowPieces);
      for (var column = 0; column < columns; column++) {
        PuzzleEdgeType? top, right, bottom, left;
        PuzzlePiece? leftPiece, upPiece;
        if (row > 0) {
          upPiece = pieces[row - 1][column];
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
          bottom = PuzzleEdgeType.random(random);
        } else {
          top = upPiece.bottom == PuzzleEdgeType.hole
              ? PuzzleEdgeType.knob
              : PuzzleEdgeType.hole;
          if ((row + 1) < rows) {
            bottom = PuzzleEdgeType.random(random);
          }
        }
        rowPieces.add(PuzzlePiece(
          pieceWidth: pieceWidth,
          pieceHeight: pieceHeight,
          row: row,
          column: column,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ));
      }
    }

    /// make the target and fake puzzles
    {
      targets.clear();
      final randomList = pieces.flattened.toList();
      randomList.shuffle(random);
      final totalTarget = random.nextInt(3) + 1;
      for (var i = 0; i < totalTarget; i++) {
        var puzzle = randomList[i]
          ..rightSide = true
          ..rotate = _randomRadian(random);
        targets.add(puzzle);
      }
      final target = totalTarget == 1
          ? targets.first
          : targets[random.nextInt(targets.length)];

      /// random fake piece's left top right bottom edges
      final edges = List.from([0, 1, 2, 3]..shuffle(random))
          .sublist(0, random.nextInt(4) + 1);
      PuzzleEdgeType? left, top, right, bottom;
      if (edges.contains(0)) {
        left = target.column == 0 ? null : _edgeType(random, target.left);
      }
      if (edges.contains(1)) {
        top = target.row == 0 ? null : _edgeType(random, target.top);
      }
      if (edges.contains(2)) {
        right = target.column == columns - 1
            ? null
            : _edgeType(random, target.right);
      }
      if (edges.contains(3)) {
        bottom =
            target.row == rows - 1 ? null : _edgeType(random, target.bottom);
      }
      final fake = target.copyWith(
        pieceWidth: pieceWidth,
        pieceHeight: pieceHeight,
      )
        ..left = left
        ..top = top
        ..right = right
        ..bottom = bottom
        ..isTarget = true
        ..rightSide = true
        ..rotate = _randomRadian(random);
      targets..add(fake)
          // ..shuffle(random)
          ;
    }
    for (var p in targets) {
      await p.draw(_bg!, pieceWidth, pieceHeight);
    }
    for (var rows in pieces) {
      for (var p in rows) {
        if (!p.isTarget) await p.draw(_bg!, pieceWidth, pieceHeight);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: Text('新的'),
      ),
      body: GestureDetector(
        onPanUpdate: (_) {
          setState(() {
            x += _.delta.dx;
            y += _.delta.dy;
          });
        },
        child: Stack(
          children: [
            RepaintBoundary(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _PuzzlePainter(
                          puzzles: pieces,
                          bg: _bg,
                          scale: scale,
                          x: x,
                          y: y,
                          isLeft: true,
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(width: 2),
                  Expanded(
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _PuzzlePainter(
                          puzzles: [targets],
                          bg: _bg,
                          scale: scale,
                          x: x,
                          y: y,
                          isLeft: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.align_horizontal_left)),
          ],
        ),
      ),
    );
  }
}

class _PuzzlePainter extends CustomPainter {
  final List<List<PuzzlePiece>> puzzles;
  final double scale, x, y;
  final ui.Image? bg;
  final bool isLeft;
  final _padding = 50.0;
  late final _linePaint = Paint()
    ..style = ui.PaintingStyle.stroke
    ..isAntiAlias = true
    ..color = Colors.black
    ..strokeWidth = 1 / scale;

  _PuzzlePainter({
    super.repaint,
    required this.puzzles,
    required this.scale,
    required this.x,
    required this.y,
    required this.isLeft,
    this.bg,
  });

  @override
  bool shouldRepaint(_PuzzlePainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    if (puzzles.isEmpty) return;
    isLeft ? _paintLeft(canvas, size) : _paintRight(canvas, size);
  }

  void _paintLeft(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    final rows = puzzles.length, columns = puzzles.first.length;
    final width = bg!.width / columns, height = bg!.height / rows;
    for (var row in puzzles) {
      for (var piece in row) {
        if (!piece.isTarget) {
          canvas
            ..drawImage(
              piece.image,
              Offset(piece.offsetX, piece.offsetY),
              PuzzlePiece.imagePaint,
            )
            ..drawPath(piece.path, _linePaint);
        }
        canvas.translate(width, 0);
      }
      canvas.translate(-row.length * width, height);
    }

    canvas.restore();
    TextPainter(
      text: TextSpan(
        text: 'Left',
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      textDirection: ui.TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset.zero);
  }

  void _paintRight(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    final imgPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    final rows = puzzles.length, columns = puzzles.first.length;
    final width = bg!.width / columns,
        height = bg!.height / rows,
        linePaint = Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / scale;

    var currentRow = 0;
    for (var i = 0; i < puzzles.first.length; i++) {
      final piece = puzzles.first[i];
      canvas.save();
      var x = i * (width) + i * (_padding / scale);
      if (x > bg!.width) {
        x = 0;
        currentRow++;
      }
      var y = currentRow * height + currentRow * (_padding / scale);
      canvas.translate(x, y);
      canvas.drawImage(
        piece.image,
        Offset.zero,
        PuzzlePiece.imagePaint,
      );
      canvas.drawPath(piece.path, linePaint);
      canvas.restore();
    }

    canvas.restore();
  }
}

final _allTypes = [null, ...PuzzleEdgeType.values];

PuzzleEdgeType? _edgeType(math.Random random, PuzzleEdgeType? type) {
  final list = _allTypes.toList()
    ..remove(type)
    ..shuffle(random);
  return list.first;
}

final _angles = [0, 90, 180, 270];

int _randomRadian(math.Random random) => 90
// _angles[random.nextInt(_angles.length)]
    ;
