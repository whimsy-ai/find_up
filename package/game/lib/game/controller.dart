import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game/i_offset_scale.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:tweener/tweener.dart';

import '../data.dart';
import '../get_ilp_info_unlock.dart';
import 'canvas.dart';
import 'core.dart';
import 'resources.dart';

enum TimeMode { up, down }

enum GameMode {
  normal,
  hard,
}

enum GameBarMode {
  fullSize,
  miniSize,
}

enum GameState {
  /// loading ilp layers
  loading(0),
  loadError(1),

  /// game image fade in animate
  animating(2),
  already(3),
  started(4),
  paused(5),
  stopped(6),
  completed(7),
  failed(8);

  final num value;

  const GameState(this.value);
}

class GameController extends IOffsetScaleController {
  static final _audioPlayer = AudioPlayer();

  playCorrectAudio() => _audioPlayer
    ..stop()
    ..play(Resources.correctSource);

  playWrongAudio() => _audioPlayer
    ..stop()
    ..play(Resources.wrongSource);

  playErrorAudio() => _audioPlayer
    ..stop()
    ..play(Resources.errorSource);

  void Function({
    required double pastUnlock,
    required double newUnlock,
    int? nextIndex,
  })? onFinish;

  final ILP ilp;
  final TimeMode timeMode;
  final Duration? countdown;
  final bool allowDebug, allowPause;
  bool _debug = false;

  bool get isDebug => _debug;

  bool get test => _debug;

  set test(val) {
    _debug = val;
    update(['ui', 'game']);
  }

  late final GameCore _core = GameCore(_onFixedUpdate);

  late int index;
  late int _seed = 0;
  ILPHeader? _header;
  ILPInfo? info;
  ILPLayer? layer;

  int get clicks => _clicks;
  int _clicks = 0;

  int get seed => _seed;

  /// error text
  String? error;

  final List<ILayerBuilder> layers = [];

  GameState get state => _state;
  GameState _state = GameState.loading;

  Duration _time = Duration.zero;

  String get time {
    var time = (_time.inMilliseconds / Duration.millisecondsPerSecond)
        .toString()
        .split('.');

    /// 这里处理毫秒
    // time[1] = time[1].padLeft(2, '0').substring(0, 2);

    return time[0];
    // final t = _time.toString().split('.');
    // t[1] = t[1].substring(0, 2);
    // return t.join('.');
  }

  bool get isLoading => _state == GameState.loading;

  bool get isLoadError => _state == GameState.loadError;

  bool get isAnimating => _state == GameState.animating;

  bool get isStarted => _state == GameState.started;

  bool get isPaused => _state == GameState.paused;

  bool get isFailed => _state == GameState.failed;

  bool get isCompleted => _state == GameState.completed;

  bool get isStopped => _state == GameState.stopped;

  bool get isReady => _state == GameState.already;

  final _tappedLayerIdList = <String>[];

  var _opacity = 0.0;

  double get opacity => _opacity;

  // Widget _halfWidget(
  //   LayerLayout layout,
  //   double scale,
  //   double x,
  //   double y,
  //   bool debug,
  // ) {
  //   return Expanded(
  //     child: LayoutBuilder(
  //       builder: (context, constrains) {
  //         _moveBounds = Rect.fromLTWH(
  //           50,
  //           50,
  //           constrains.biggest.width - 100,
  //           constrains.biggest.height - 100,
  //         );
  //         return ILPCanvas(
  //           layout: layout,
  //           scale: scale,
  //           layers: layers,
  //           offsetX: x,
  //           offsetY: y,
  //           debug: debug,
  //         );
  //       },
  //     ),
  //   );
  // }

  GameController({
    required this.ilp,
    required this.index,
    required this.timeMode,
    required this.allowPause,
    required this.allowDebug,
    this.countdown,
  }) {
    if (timeMode == TimeMode.down) assert(countdown != null);
  }

  Tweener? _tweener;

  Future<void> start({int? index, int? seed}) async {
    error = null;
    _core.stop();
    _tweener?.stop();
    _opacity = 0;
    _clicks = 0;
    _state = GameState.loading;
    _seed = seed ?? randomSeed();
    _time = Duration(minutes: 2);
    print('切换到loading');
    update(['ui', 'game']);
    try {
      /// 读取游戏界面资源
      await Resources.init();

      /// 读取游戏内容
      final list = await Future.wait([
        ilp.header,
        ilp.info(index ?? this.index),
        ilp.layer(index ?? this.index),

        /// 读取时长 兜底
        Future.delayed(Duration(milliseconds: 500)),
      ]);
      _header = list.first as ILPHeader;
      info = list[1] as ILPInfo;
      layer = list[2] as ILPLayer;
    } catch (e) {
      _state = GameState.loadError;
      error = e.toString();
      update(['ui', 'game']);
      return;
    }
    update(['ui', 'game']);
    _randomLayers();
    _state = GameState.animating;
    update(['game']);

    resetScaleAndOffset();

    _core.start();
    _state = GameState.started;
    await _opacityTweenTo(1);
  }

  Future<void> _opacityTweenTo(double opacity) {
    final completer = Completer<void>();
    _tweener?.stop();
    _tweener = Tweener({'opacity': _opacity})
        .to({'opacity': opacity}, 500)
        .easing(Ease.quart.easeOut)
        .onUpdate((obj) {
          _opacity = math.min(obj['opacity'], 1);
          print('tween opacity $_opacity');
          update(['ui', 'game']);
        })
        .onComplete((obj) {
          _opacity = opacity;
          update(['ui', 'game']);
          completer.complete();
        })
        .start();
    return completer.future;
  }

  stop() {
    if (isStarted) {
      _state = GameState.stopped;
      _core.stop();
      update(['ui', 'game']);
    }
  }

  fail() {
    if (isStarted) {
      _time = Duration.zero;
      _state = GameState.failed;
      _core.stop();
      _opacity = 0;
      update(['ui', 'game']);
    }
  }

  pause() async {
    if (isStarted) {
      _state = GameState.paused;
      await _opacityTweenTo(0);
      update(['ui', 'game']);
    }
  }

  resume() async {
    if (state == GameState.paused) {
      _state = GameState.started;
      update(['ui', 'game']);
      await _opacityTweenTo(1);
    }
  }

  _randomLayers() async {
    info = await ilp.info(index);
    layers.clear();
    final random = math.Random(_seed);
    int layerIndex = 0;
    loop(List<ILPLayer> layers, {isGroup = false}) {
      final List<ILPLayer> contents = [];
      for (var layer in layers) {
        if (layer.content.isNotEmpty) {
          contents.add(layer);
        } else if (layer.layers.isNotEmpty) {
          loop(layer.layers, isGroup: true);
        }
      }
      if (contents.isNotEmpty) {
        if (isGroup) {
          final isShow = random.nextBool();
          if (isShow) {
            final layer = contents[random.nextInt(contents.length)];
            ILPLayer? otherLayer;

            /// if show other side layer
            /// 如果另外一边也要显示内容
            if (random.nextBool()) {
              contents.remove(layer);
              if (contents.isNotEmpty) {
                otherLayer = contents[random.nextInt(contents.length)];
              }
            }
            final leftSide = random.nextBool();
            final canvasLayer = ILPCanvasLayer(
              name: '$layerIndex',
              layout: leftSide ? LayerLayout.left : LayerLayout.right,
              left: leftSide ? layer : otherLayer,
              right: leftSide ? otherLayer : layer,
              onTap: _onTap,
            );
            this.layers.add(canvasLayer);
          }
        } else {
          for (var layer in contents) {
            final isShow = random.nextBool();
            if (isShow) {
              final leftSide = random.nextBool();
              final canvasLayer = ILPCanvasLayer(
                name: '$layerIndex',
                layout: leftSide ? LayerLayout.left : LayerLayout.right,
                left: leftSide ? layer : null,
                right: leftSide ? null : layer,
                onTap: _onTap,
              );
              this.layers.add(canvasLayer);
            }
          }
        }
      }
      layerIndex++;
    }

    /// 背景图层
    layers.add(ILPCanvasLayer(
      name: '背景层',
      layout: LayerLayout.all,
      left: layer,
      right: layer,
      onTap: _onTap,
      tappedSide: LayerLayout.all,
    ));

    /// 其余图层
    while (layers.length == 1) {
      loop(layer!.layers);
    }
    print('随机图层 ${layers.length}');
    update(['ui', 'game']);
  }

  _onTap(LayerLayout clicked, ILPCanvasLayer layer, Offset tapPosition) {
    if (state != GameState.started) return;
    _clicks++;
    print('点击了图层 ${(layer.left ?? layer.right)?.name}');

    /// 背景图层
    if (layer.layout == LayerLayout.all || layer.tapped) {
      playWrongAudio();
    }

    /// 未被点击过的图层
    else {
      playCorrectAudio();
      layer.tappedSide = clicked;
      layer.highlight = false;
      if (layer == tipLayer) tipLayer = null;

      layers.add(LabelLayer(index: _clicks, position: tapPosition));

      /// 点击了左边
      if (clicked == LayerLayout.left) {
        // print('点击了左边');
        if (layer.left != null) _tappedLayerIdList.add(layer.left!.id);
      }

      /// 点击了右边
      else if (clicked == LayerLayout.right) {
        // print('点击了右边');
        if (layer.right != null) _tappedLayerIdList.add(layer.right!.id);
      }
    }
    update(['ui', 'game']);
    if (unTappedLayers == 0) {
      stop();
      final pastUnlock = getIlpInfoUnlock(info!);
      Data.layersId.addAll(_tappedLayerIdList);
      final hasNext = (_header!.infoList.length - 1) > index;
      onFinish?.call(
        pastUnlock: pastUnlock,
        newUnlock: getIlpInfoUnlock(info!),
        nextIndex: hasNext ? index + 1 : null,
      );
    }
  }

  @override
  void resetScaleAndOffset() {
    final screenHalfWidth = Get.width / 2;
    final int width = info!.width, height = info!.height;
    // if (width > height) {
    //   scale = (oneSideScreenWidth - IOffsetScaleController.padding) / info!.width;
    // } else if (width < height) {
    //   scale = (Get.height - IOffsetScaleController.padding) / info!.height;
    // } else {
    //   if (oneSideScreenWidth < Get.height) {
    //     scale = (oneSideScreenWidth - IOffsetScaleController.padding) / info!.width;
    //   } else {
    //     scale = (Get.height - IOffsetScaleController.padding) / info!.height;
    //   }
    // }
    scale = (math.min(screenHalfWidth, Get.height) - IOffsetScaleController.padding) /
        math.max(width, height);
    offsetX = (screenHalfWidth - width * scale) / 2;
    offsetY = (Get.height - height * scale) / 2;
  }

  Future<void> changeSeed({bool force = false, int? seed}) async {
    pause();
    if (!force) {
      final sure = await Get.dialog(AlertDialog(
        title: Text(UI.gameBarChangeSeed.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(UI.confirm.tr),
          ),
        ],
      ));
      if (sure != true) {
        resume();
        return;
      }
    }
    start(seed: seed ?? randomSeed());
  }

  static int randomSeed() => math.Random().nextInt(65535);

  Future<void> _onFixedUpdate(Duration lastFrame) async {
    if (isStarted) {
      /// 游戏时间 倒计时
      _time -= lastFrame;

      /// 提示道具 倒计时
      if (lastTipTimer.inMilliseconds > 0) lastTipTimer -= lastFrame;

      update(['time', 'tip']);

      if (_time.inMilliseconds < 0) {
        fail();
      }
    }
  }

  int get unTappedLayers => layers
      .whereType<ILPCanvasLayer>()
      .where((element) => !element.tapped)
      .length;

  int get allLayers => layers.whereType<ILPCanvasLayer>().length - 1;

  @override
  void onClose() {
    print('GameController onClose');
    _tweener?.stop();
    _core.dispose();
    super.onClose();
  }

  /// for debug
  void setFailed() {
    _time = Duration.zero;
    update(['game', 'ui']);
  }

  /// 提示道具 代码区域
  // 在此局使用了多少次提示道具
  int useTipToolTimes = 0;

  // 最后一次使用提示道具 距今 的时间
  Duration lastTipTimer = Duration.zero;

  ILPCanvasLayer? tipLayer;

  final _fixedTipTime = Duration(seconds: 10);

  /// 显示提示
  ILPCanvasLayer? showTip() {
    if (lastTipTimer.inMilliseconds > 0) return null;
    if (unTappedLayers > 0 == false) return null;
    if (tipLayer != null) return null;
    final layer = layers
        .whereType<ILPCanvasLayer>()
        .firstWhereOrNull((element) => !element.tapped);
    if (layer == null) return null;
    layer.highlight = true;
    tipLayer = layer;
    useTipToolTimes++;
    lastTipTimer = _fixedTipTime * useTipToolTimes;
    update(['game', 'tip']);
    return layer;
  }

  @override
  double get maxScale => 4;

  @override
  double get minScale => layer!.width > layer!.height
      ? Get.width / 3 / layer!.width
      : Get.height / 2 / layer!.height;
}
