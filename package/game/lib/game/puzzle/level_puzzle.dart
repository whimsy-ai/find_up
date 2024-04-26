import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../extension_path.dart';
import '../../utils/utf8list_to_image.dart';
import '../find_differences/layer.dart';
import '../level.dart';
import 'girdding.dart';
import 'peak_height.dart';
import 'puzzle.dart';

class LevelPuzzle extends Level with LevelLoader {
  final List<List<PuzzlePiece>> pieces = [];
  @override
  final List<PuzzlePiece> layers = [];

  late int targetsCount;
  late int rows, columns;
  late double pieceWidth, pieceHeight;
  Color lineColor =
      Colors.accents[math.Random().nextInt(Colors.accents.length)];
  Offset mouse = Offset.zero;

  LevelPuzzle({
    super.mode = LevelMode.puzzle,
    required super.controller,
    required super.file,
    required super.ilpIndex,
    required this.targetsCount,
  }) {
    time = Duration(seconds: 15) * targetsCount;
  }

  @override
  int get allLayers => 1;

  @override
  bool hint() {
    for (var target in layers.toList()) {
      if (target.isTarget) continue;
      pieces[target.row][target.column].leftSide = true;
      layers.remove(target);
      return true;
    }
    return false;
  }

  @override
  Future<Duration?> onTap(LayerLayout layout, ui.Offset position) async {
    final paths = transformedPaths();
    for (var i = 0; i < paths.length; i++) {
      final path = paths[i];
      final piece = layers[i];
      if (path.contains(position)) {
        /// 找到正确图层
        if (piece.isTarget) {
          /// 把所有图层都标记为已点击，完成关卡
          for (var element in layers) {
            element.tapped = true;
          }
          return null;
        }

        /// 点击错误图层
        else {
          return Duration(seconds: 10);
        }
      }
    }

    return Duration.zero;
  }

  double _colorTween = 0;
  late final ColorTween _tween = ColorTween(
      begin: lineColor,
      end: Colors.accents[math.Random().nextInt(Colors.accents.length)]);

  @override
  void onUpdate(Duration frame) {
    super.onUpdate(frame);
    _colorTween += frame.inMilliseconds / 1000;
    lineColor = _tween.transform(_colorTween)!;
    if (_colorTween >= 1) {
      _colorTween = 0;
      _tween.begin = _tween.end;
      _tween.end = Colors.accents[math.Random().nextInt(Colors.accents.length)];
    }
    controller.update(['game']);
  }

  @override
  void reset() {}

  @override
  void randomLayers(math.Random random) {
    pieces.clear();
    layers.clear();

    final (row, column) = Grid.calc(
      width,
      height,
      math.min(width, height) / ([3, 4, 5]..shuffle(random)).first,
    );
    // print('random layer $width, $height, $row, $column');
    rows = row;
    columns = column;
    pieceWidth = width / columns;
    pieceHeight = height / rows;
    final id = info!.contentLayerIdList.sublist(1)..shuffle(random);
    _id
      ..clear()
      ..addAll(id.sublist(0, random.nextInt(id.length) + 1));

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
        var piece = randomList[i]..leftSide = false;
        piece = piece.copyWith(
          pieceWidth: pieceWidth,
          pieceHeight: pieceHeight,
          left: piece.left,
          top: piece.top,
          right: piece.right,
          bottom: piece.bottom,
        );
        piece
          ..rightSide = true
          ..rotate = _randomAngle(random);
        layers.add(piece);
      }

      /// 选择一个目标
      final target = layers[random.nextInt(layers.length)];

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
        ..leftSide = false
        ..rightSide = true
        ..rotate = _randomAngle(random);

      layers.add(fake);
      layers.shuffle(random);
    }
  }

  @override
  Future<void> drawContent() async {
    final bg = await utf8ListToImage(rootLayer!.content as Uint8List);
    for (var row in pieces) {
      for (var piece in row) {
        await piece.draw(bg, pieceWidth, pieceHeight);
      }
    }
    for (var piece in layers) {
      await piece.draw(bg, pieceWidth, pieceHeight);
    }
  }

  final List<String> _id = [];

  @override
  List<String> unlockedLayersId() => _id;

  List<Path> transformedPaths() {
    final paths = <Path>[];
    final maxSize =
        math.max(pieceWidth, pieceHeight) + PuzzlePiece.peakHeight * 2 + 10;
    final mx = Matrix4.identity()..scale(controller.scale, controller.scale, 1);
    double translateX = 0, translateY = 0;
    for (var piece in layers.toList()) {
      final x = (maxSize - piece.width) / 2, y = (maxSize - piece.height) / 2;
      final offset = Offset(
        controller.offsetX + (translateX + x) * controller.scale,
        controller.offsetY + (translateY + y) * controller.scale,
      );
      paths.add(piece.path.transform(mx.storage).shift(offset));
      if (translateX + maxSize * 2 < width) {
        translateX += maxSize;
      }

      /// 换行
      else {
        translateY += maxSize;
        translateX = 0;
      }
    }
    return paths;
  }
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
