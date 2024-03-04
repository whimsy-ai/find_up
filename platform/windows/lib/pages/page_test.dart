import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:game/extension_path.dart';
import 'package:game/game/level_puzzle.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

class PageTest extends StatefulWidget {
  @override
  State<PageTest> createState() => _PageTestState();
}

class _PageTestState extends State<PageTest> {
  final ilpPath =
      'E:\\SteamLibrary\\steamapps\\workshop\\content\\2550370\\3154914212\\main.ilp';
  final List<List<PuzzlePiece>> _puzzles = [];

  final int rows = 5, columns = 4;

  ui.Image? _bg;
  final random = math.Random();
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    _puzzles.clear();
    setState(() {});
    late ILPLayer layer;
    await Future.wait([
      ILP.fromFile(ilpPath).then((ilp) => ilp.layer(0)).then((v) {
        layer = v;
        return _loadImage(layer.content as Uint8List);
      }).then((value) => _bg = value),
      Future.delayed(Duration(milliseconds: 1500)),
    ]);
    final types = [PuzzleEdgeType.knob, PuzzleEdgeType.hole];
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
          types.shuffle(random);
          right = types.first;
        } else {
          left = leftPiece.right == PuzzleEdgeType.hole
              ? PuzzleEdgeType.knob
              : PuzzleEdgeType.hole;
          // print('lastP ${leftPiece.right}=>$left');
          if ((column + 1) < columns) {
            types.shuffle(random);
            right = types.first;
          }
        }
        if (upPiece == null) {
          types.shuffle(random);
          bottom = types.first;
        } else {
          top = upPiece.bottom == PuzzleEdgeType.hole
              ? PuzzleEdgeType.knob
              : PuzzleEdgeType.hole;
          if ((row + 1) < rows) {
            types.shuffle(random);
            bottom = types.first;
          }
        }

        rowPieces.add(PuzzlePiece(
          layer: layer,
          image: _bg!,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ));
      }
    }
    opacity = 1;
    setState(() {});
  }

  double x = 0, y = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test')),
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
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    left: x,
                    top: y,
                    child: AnimatedOpacity(
                      opacity: _puzzles.isEmpty ? 0 : 1,
                      duration: Duration(milliseconds: 200),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          isComplex: true,
                          size: Size(_bg!.width.toDouble(),
                                  _bg!.height.toDouble()) *
                              0.2,
                          painter: _Painter(
                            puzzles: _puzzles,
                            bg: _bg,
                          ),
                          // painter: _Painter(
                          //   puzzles: _puzzles,
                          //   bg: _bg,
                          //   scale: 0.2,
                          // ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final List<List<PuzzlePiece>> puzzles;

  final ui.Image? bg;

  _Painter({
    super.repaint,
    required this.puzzles,
    this.bg,
  });

  Offset offset = Offset.zero;

  @override
  void paint(Canvas canvas, Size size) {
    if (puzzles.isEmpty) return;
    print('painter draw');
    canvas.drawColor(Colors.blueGrey, BlendMode.src);

    final imgPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    final rows = puzzles.length, columns = puzzles.first.length;
    final width = bg!.width / columns,
        height = bg!.height / rows,
        linePaint = Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..blendMode = BlendMode.softLight
          ..strokeWidth = 4;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final piece = puzzles[row][column];
        canvas.save();
        var path = Path()
          ..puzzle(
            width: width,
            height: height,
            top: piece.top,
            right: piece.right,
            bottom: piece.bottom,
            left: piece.left,
          );
        final offset = Offset(column * width, row * height);
        canvas.translate(offset.dx + column * (20), offset.dy + row * (20));
        canvas.clipPath(path);

        /// bg
        canvas.drawImage(bg!, -offset, imgPaint);
        canvas.drawPath(path, linePaint);

        canvas.restore();
        TextPainter(
          text: TextSpan(
            text: 'row:$row\ncolumn:$column',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          textDirection: ui.TextDirection.ltr,
        )
          ..layout()
          ..paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => true;
}

Future<ui.Image> _loadImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}
