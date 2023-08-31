import 'dart:async';
import 'dart:io';

import 'package:steamworks/steamworks.dart';

class SteamLooper {
  static late final SteamLooper instance;
  late final SteamClient client;
  final Duration interval;
  Timer? _loop;

  static SteamLooper init({
    Duration interval = const Duration(milliseconds: 10),
  }) {
    instance = SteamLooper._(interval: interval);
    return instance;
  }

  SteamLooper._({required this.interval}) {
    try {
      SteamClient.init();
    } catch (e) {
      exit(-1);
    }
    client = SteamClient.instance;
  }

  start() {
    print('start steam loop');
    _looper();
  }

  stop() {
    print('stop steam loop');
    _loop?.cancel();
  }

  bool get isLooping => _loop != null;

  _looper() {
    // print('steam loop');
    client.runFrame();
    _loop = Timer(interval, _looper);
  }
}
