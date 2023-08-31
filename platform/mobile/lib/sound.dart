import 'package:audioplayers/src/source.dart';
import 'package:flutter/services.dart';
import 'package:game/sound.dart';

class Sound extends ISound {
  static final Sound instance = Sound._();

  Sound._() {
    _load();
  }

  _load() async {
    _correct = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/correct.wav'))
            .buffer
            .asUint8List());
    _error = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/error.wav'))
            .buffer
            .asUint8List());
    _wrong = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/wrong.mp3'))
            .buffer
            .asUint8List());
  }

  late BytesSource _correct, _error, _wrong;

  @override
  Source get correctSource => _correct;

  @override
  Source get errorSource => _error;

  @override
  Source get wrongSource => _wrong;
}
