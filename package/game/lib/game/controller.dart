import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../data.dart';
import '../get_ilp_info_unlock.dart';
import '../sound.dart';
import 'canvas.dart';

class Action {
  final Future<void> Function(Duration frameTime) onFixedUpdate;

  Action(this.onFixedUpdate);

  void update(Duration frameTime) {
    onFixedUpdate(frameTime);
  }
}

enum TimeMode { up, down }

enum GameMode {
  normal,
  hard,
}

enum GameCoreState {
  notStart,
  started,
  stopped,
  paused,
}

class GameCore {
  final void Function(Duration) update;

  GameCore(this.update);

  GameCoreState _state = GameCoreState.notStart;

  GameCoreState get state => _state;
  DateTime? startTime, stopTime, pauseTime;

  bool get isStarted => _state == GameCoreState.started;

  bool get isPaused => _state == GameCoreState.paused;

  bool get isStopped => _state == GameCoreState.stopped;

  late DateTime _frameTime;

  Future<void> _loop() async {
    update(DateTime.now().difference(_frameTime));
    _frameTime = DateTime.now();
    if (isStarted) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _loop();
      });
    }
  }

  void start() {
    _state = GameCoreState.started;
    _frameTime = DateTime.now();
    _loop();
  }

  void stop() {
    if (_state != GameCoreState.started) return;
    _state = GameCoreState.stopped;
    stopTime = DateTime.now();
  }

  void pause() {
    if (_state == GameCoreState.started) {
      pauseTime = DateTime.now();
      _state = GameCoreState.paused;
    }
  }

  void resume() {
    if (_state == GameCoreState.paused) {
      _state = GameCoreState.started;
      pauseTime = null;
      _loop();
    }
  }

  void reset() {
    _state = GameCoreState.notStart;
    startTime = stopTime = pauseTime = null;
  }
}

class GameCoreTimer extends Action {
  final TimeMode mode;
  Duration _data = Duration.zero;
  final Duration? target;

  GameCoreTimer({
    required Future<void> Function(Duration) onFixedUpdate,
    this.mode = TimeMode.up,
    this.target,
  })  : assert(mode == TimeMode.down ? target != null : target == null),
        super(onFixedUpdate);

  @override
  void update(Duration frameTime) {
    _data += frameTime;
    super.update(frameTime);
  }

  Duration get time => mode == TimeMode.up ? _data : target! - _data;
}

class GameController extends GetxController {
  void Function({
    required double pastUnlock,
    required double newUnlock,
    int? nextIndex,
  })? onFinish;
  final ISound? sound;

  final ILP ilp;
  final TimeMode timeMode;
  final Duration? countdown;
  final bool allowDebug, allowPause;
  bool _debug = false;

  bool get isDebug => _debug;

  bool get test => _debug;

  set test(val) {
    _debug = val;
    update(['bar', 'game']);
  }

  late math.Random _random;

  late final GameCore _core = GameCore(_onFixedUpdate);

  late int index;
  late int _seed = math.Random().nextInt(65535);
  ILPHeader? _header;
  ILPInfo? info;
  ILPLayer? layer;

  int get clicks => _clicks;
  int _clicks = 0;

  int get seed => _seed;

  final List<ILayerBuilder> layers = [];

  GameCoreState get state => _core.state;

  Duration _time = Duration.zero;

  String get time {
    final t = _time.toString().split('.');
    t[1] = t[1].substring(0, 2);
    return t.join('.');
  }

  bool get isStarted => _core.isStarted;

  bool get isStopped => _core.isStopped;

  final _tappedLayerIdList = <String>[];

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
    this.sound,
    this.countdown,
  }) {
    if (timeMode == TimeMode.down) assert(countdown != null);
  }

  @override
  void onInit() {
    super.onInit();
    print('onInit');
  }

  start({int? index, int? seed}) async {
    await Future.wait([
      ilp.header,
      ilp.info(index ?? this.index),
      ilp.layer(index ?? this.index),
    ]).then((list) {
      _header = list.first as ILPHeader;
      info = list[1] as ILPInfo;
      layer = list.last as ILPLayer;
    });
    _randomLayers(seed: seed);
    _core.start();
    update(['bar', 'game']);
  }

  stop() {
    _core.stop();
    update(['bar', 'game']);
  }

  pause() {
    _core.pause();
    update(['bar', 'game']);
  }

  resume() {
    _core.resume();
    update(['bar', 'game']);
  }

  reStart() async {
    pause();
    await Future.delayed(Duration(milliseconds: 100));
    _clicks = 0;
    _time = Duration.zero;
    _core.reset();
    start(index: index);
  }

  _randomLayers({int? index, int? seed}) async {
    _seed = seed ?? math.Random().nextInt(65535);
    info = await ilp.info(index ?? this.index);
    layers.clear();
    _random = math.Random(_seed);
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
          final isShow = _random.nextBool();
          if (isShow) {
            final layer = contents[_random.nextInt(contents.length)];
            ILPLayer? otherLayer;

            /// if show other side layer
            /// 如果另外一边也要显示内容
            if (_random.nextBool()) {
              contents.remove(layer);
              if (contents.isNotEmpty) {
                otherLayer = contents[_random.nextInt(contents.length)];
              }
            }
            final leftSide = _random.nextBool();
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
            final isShow = _random.nextBool();
            if (isShow) {
              final leftSide = _random.nextBool();
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
    update(['bar', 'game']);
  }

  _onTap(LayerLayout clicked, ILPCanvasLayer layer, Offset tapPosition) {
    _clicks++;
    print('点击了图层 ${(layer.left ?? layer.right)?.name}');

    /// 背景图层
    if (layer.layout == LayerLayout.all || layer.tapped) {
      sound?.wrong();
    }

    /// 未被点击过的图层
    else {
      sound?.correct();
      layer.tappedSide = clicked;
      layer.highlight = false;
      tipLayer.value = null;

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
    update(['bar', 'game']);
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

  Future<void> _onFixedUpdate(Duration lastFrame) async {
    _time += lastFrame;
    update(['bar']);
  }

  int get unTappedLayers => layers
      .whereType<ILPCanvasLayer>()
      .where((element) => !element.tapped)
      .length;

  int get allLayers => layers.whereType<ILPCanvasLayer>().length - 1;

  var scale = 1.0, offsetX = 0.0, offsetY = 0.0;

  late final tipLayer = Rxn<ILPCanvasLayer>()..listen((v) {});

  showTip() {
    if (unTappedLayers > 0 == false) return;
    final layer = layers
        .whereType<ILPCanvasLayer>()
        .firstWhereOrNull((element) => !element.tapped);
    if (layer == null) return;
    layer.highlight = true;
    tipLayer.value = layer;
    update(['game']);
  }

  @override
  void onClose() {
    // print('GameController onClose');
    _core.stop();
    super.onClose();
  }
}
