import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'game_state.dart';

class GameCore extends TickerProvider {
  final void Function(Duration) update;

  late final Ticker _ticker = Ticker(_loop);

  GameCore(this.update);

  Duration _previous = Duration.zero;

  void _loop(timestamp) {
    // print('gamecore _loop');
    final durationDelta = timestamp - _previous;
    _previous = timestamp;
    update(durationDelta);
  }

  void start() {
    print('gamecore start');
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void stop() {
    print('gamecore stop');
    if (_ticker.isActive) {
      _ticker.stop();
      _previous = Duration.zero;
    }
  }

  void dispose() {
    print('gamecore dispose');
    _ticker.dispose();
  }

  @override
  Ticker createTicker(TickerCallback onTick) => _ticker;
}

mixin CoreController on GetxController {
  late final core = GameCore(onUpdate);

  void onUpdate(Duration lastFrame);

  void onClose() {
    core.dispose();
    print('$runtimeType onClose');
  }

  GameState state = GameState.loading;

  void start() {
    state = GameState.started;
    core.start();
  }

  void stop() {
    state = GameState.stopped;
    core.stop();
  }

  void pause() {
    if (state == GameState.started) {
      state = GameState.paused;
      update(['ui', 'game']);
    }
  }

  void resume() {
    if (state == GameState.paused) {
      state = GameState.started;
      update(['ui', 'game']);
    }
  }

  void setFail() {
    state = GameState.failed;
    update(['ui', 'game']);
  }

  bool get isLoading => state == GameState.loading;

  bool get isLoadError => state == GameState.loadError;

  bool get isAnimating => state == GameState.animating;

  bool get isStarted => state == GameState.started;

  bool get isPaused => state == GameState.paused;

  bool get isFailed => state == GameState.failed;

  bool get isCompleted => state == GameState.completed;

  bool get isStopped => state == GameState.stopped;

  bool get isReady => state == GameState.already;
}
