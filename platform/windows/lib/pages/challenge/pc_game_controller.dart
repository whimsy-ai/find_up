import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:game/game/game_state.dart';
import 'package:game/game/level.dart';
import 'package:game/game/level_controller.dart';
import 'package:game/game/level_find_differences.dart';
import 'package:game/game/level_puzzle.dart';
import 'package:game/game/mouse_controller.dart';
import 'package:game/game/offset_scale_controller.dart';
import 'package:game/game/resources.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:steamworks/steamworks.dart';

import '../../utils/steam_ex.dart';
import '../explorer/steam/steam_file.dart';

class PCGameController extends LevelController with MouseController {
  final List<ExplorerFile> files;
  final int? ilpIndex;

  PCGameController({required this.files, this.ilpIndex});

  @override
  Future<void> start({int? seed}) async {
    levels.clear();
    this.seed = seed ?? math.Random().nextInt(65535);
    final random = math.Random(this.seed);

    super.stop();
    state = GameState.loading;

    tapPositions.clear();

    current = 0;
    update(['ui', 'game']);

    /// 读取游戏资源
    await Resources.init();
    await _loadFile(files.first, random);
    print('total level ${levels.length}');
    state = GameState.already;
    update(['ui', 'game']);

    /// 读取第一关，关卡信息对话框会等待读取
    loadCurrentLevel();

    /// silent load other files
    for (var i = 1; i < files.length; i++) {
      // print('silent load $i level');
      await _loadFile(files[i], random);
    }
  }

  @override
  void onLevelFinish() {
    if (current < levels.length - 1) {
      nextLevel();
    } else {
      onCompleted();
    }
    update(['ui', 'game']);
  }

  @override
  void resetScaleAndOffset() {
    final screenHalfWidth = Get.width / 2;
    final width = currentLevel!.width, height = currentLevel!.height;
    minScale = scale = (math.min(screenHalfWidth, Get.height) -
            OffsetScaleController.padding) /
        math.max(width, height);
    offsetX = (screenHalfWidth - width * scale) / 2;
    offsetY = (Get.height - height * scale) / 2;
  }

  @override
  Offset onScalePosition(Offset position) {
    // -2 是纵向分割线的宽度
    final half = (Get.width - 2) / 2;
    return Offset(
      position.dx < half ? position.dx : position.dx - half,
      position.dy,
    );
  }

  Timer? _downloadTimer;

  Future<File> _downloadSteamFile(SteamSimpleFile file) async {
    SteamClient.instance.steamUgc.suspendDownloads(false);
    final download = SteamClient.instance.downloadUGCItem(
      file.id,
      highPriority: true,
    );
    final completer = Completer<String>();
    _downloadTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      await file.updateDownloadBytes();
      downloadedBytes = file.downloadedBytes;
      totalBytes = file.totalBytes;
      update(['ui']);
    });
    await download;
    _downloadTimer?.cancel();
    using((arena) async {
      final size = arena<UnsignedLongLong>();
      final folder = arena<Uint8>(1000).cast<Utf8>();
      final timeStamp = arena<UnsignedInt>();
      final installed = SteamClient.instance.steamUgc.getItemInstallInfo(
        file.id,
        size,
        folder,
        1000,
        timeStamp,
      );
      completer.complete(folder.toDartString());
    });
    return File(path.join(await completer.future, 'main.ilp'));
  }

  Future<void> _loadFile(ExplorerFile file, math.Random random) async {
    if (file is SteamSimpleFile) {
      file = ILPFile(await _downloadSteamFile(file));
    }
    await file.load();
    final ilp = file.ilp!;
    final length = (await ilp.infos).length;
    for (var i = 0; i < length; i++) {
      final mode = LevelMode.random(random);
      switch (mode) {
        case LevelMode.findDifferences:
          levels.add(LevelFindDifferences(
            controller: this,
            file: file,
            ilpIndex: i,
            type: LevelDifferentType.random(random),
            flip: Flip.random(random),
          ));
          break;
        case LevelMode.puzzle:
          levels.add(LevelPuzzle(
            controller: this,
            file: file,
            ilpIndex: i,
            type: LevelPuzzleType.random(random),
          ));
      }
    }
  }

  @override
  void exit() {
    SteamClient.instance.steamUgc.suspendDownloads(true);
    Get.back();
  }
}
