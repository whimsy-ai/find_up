import 'package:flutter/scheduler.dart';

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
