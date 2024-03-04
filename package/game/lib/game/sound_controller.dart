import 'package:audioplayers/audioplayers.dart';

import 'resources.dart';

mixin SoundController {
  static final _audioPlayer = AudioPlayer();

  playCorrectAudio() => _audioPlayer
    ..stop()
    ..play(Resources.correctAudio);

  playWrongAudio() => _audioPlayer
    ..stop()
    ..play(Resources.wrongAudio);

  playErrorAudio() => _audioPlayer
    ..stop()
    ..play(Resources.errorAudio);

  playDuckAudio() => _audioPlayer
    ..stop()
    ..play(Resources.duckAudio);
}
