import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../extension_path.dart';
import '../../utils/utf8list_to_image.dart';
import '../layer.dart';
import '../level.dart';
import 'girdding.dart';
import 'peak_height.dart';
import 'puzzle.dart';

class LevelPuzzle extends Level with LevelLoader {
  final List<List<PuzzlePiece>> pieces = [];
  final List<PuzzlePiece> targets = [];

  late int targetsCount;
  late int rows, columns;
  late double pieceWidth, pieceHeight;
  Color lineColor =
      Colors.accents[math.Random().nextInt(Colors.accents.length)];

  LevelPuzzle({
    super.mode = LevelMode.puzzle,
    required super.controller,
    required super.file,
    required super.ilpIndex,
    required this.targetsCount,
  }) {
    time = Duration(seconds: 15)*targetsCount;
  }

  @override
  int get allLayers => 1;

  @override
  bool hint() {
    for (var target in targets.toList()) {
      if (!target.isFake) {
        targets.remove(target);
        return true;
      }
    }
    return false;
  }

  @override
  Future<ILPCanvasLayer?> onTap(LayerLayout layout, ui.Offset position) async {
    if (layout == LayerLayout.left) return null;
    return null;
  }

  double _colorTween = 0;
  late Color _next =
      Colors.accents[math.Random().nextInt(Colors.accents.length)];

  @override
  void onUpdate(Duration frame) {
    super.onUpdate(frame);
    _colorTween += frame.inMilliseconds / 5000;
    if (lineColor.value == _next.value) {
      _next = Colors.accents[math.Random().nextInt(Colors.accents.length)];
    }
    lineColor = Color.lerp(lineColor, _next, _colorTween)!;
    if (_colorTween > 1) _colorTween = 0;
    controller.update(['game']);
  }

  @override
  void reset() {}

  @override
  void randomLayers(math.Random random) {
    pieces.clear();
    targets.clear();
    final (row, column) = Grid.calc(
      width,
      height,
      math.max(width, height) / (random.nextInt(3) + 3),
    );
    print('random layer $width, $height, $row, $column');
    rows = row;
    columns = column;
    pieceWidth = width / columns;
    pieceHeight = height / rows;

    /// 重要, 需要优先计算后再创建PuzzlePiece
    PuzzlePiece.peakHeight = findPeakHeightWithSize(pieceWidth, pieceHeight);

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

    /// 设计假拼图
    {
      final randomList = pieces.flattened.toList();
      randomList.shuffle(random);
      randomList.shuffle(random);
      for (var i = 0; i < targetsCount; i++) {
        var piece = randomList[i]..isTarget = true;
        piece = piece.copyWith(
          pieceWidth: pieceWidth,
          pieceHeight: pieceHeight,
          left: piece.left,
          top: piece.top,
          right: piece.right,
          bottom: piece.bottom,
        );
        piece
          ..isTarget = true
          ..rotate = _randomAngle(random);
        targets.add(piece);
      }

      final target = targets[random.nextInt(targets.length)];

      /// 虚假拼图块需要改变的边
      /// 0: left 1: top 2: right 3: bottom
      var edges = [
        if (target.column != 0) 0,
        if (target.row != 0) 1,
        if (target.column != (columns - 1)) 2,
        if (target.row != (rows - 1)) 3,
      ];
      edges.shuffle(random);
      edges = edges.sublist(0, random.nextInt(edges.length - 1) + 1);
      PuzzleEdgeType? left, top, right, bottom;
      left = edges.contains(0) ? _edgeType(random, target.left) : target.left;
      top = edges.contains(1) ? _edgeType(random, target.top) : target.top;
      right =
          edges.contains(2) ? _edgeType(random, target.right) : target.right;
      bottom =
          edges.contains(3) ? _edgeType(random, target.bottom) : target.bottom;
      final fake = target.copyWith(
        pieceWidth: pieceWidth,
        pieceHeight: pieceHeight,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      )
        ..isTarget = true
        ..isFake = true
        ..rotate = _randomAngle(random);

      targets.add(fake);
      targets.shuffle(random);
    }
  }

  @override
  Future<void> drawContent() async {
    final bg = await utf8ListToImage(rootLayer!.content as Uint8List);
    for (var row in pieces) {
      for (var piece in row) {
        if (piece.isTarget) continue;
        await piece.draw(bg, pieceWidth, pieceHeight);
      }
    }
    for (var piece in targets) {
      await piece.draw(bg, pieceWidth, pieceHeight);
    }
  }

  /// todo
  @override
  List<String> unlockedLayersId() => [];
}

/// 随机旋转角度
final _angles = [0, 90, 180, 270];

int _randomAngle(math.Random random) => _angles[random.nextInt(_angles.length)];

/// 随机拼图边缘类型
final _allTypes = [null, ...PuzzleEdgeType.values];

PuzzleEdgeType? _edgeType(math.Random random, PuzzleEdgeType? type) {
  final list = _allTypes.toList();
  list.remove(type);
  return list[random.nextInt(list.length)];
}
