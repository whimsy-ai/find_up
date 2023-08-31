import 'package:audioplayers/audioplayers.dart';

abstract class ISound {
  static final _player = AudioPlayer();

  Future<void> correct() => _play(correctSource);

  Future<void> wrong() => _play(wrongSource);

  Future<void> error() => _play(errorSource);

  Source get correctSource;

  Source get wrongSource;

  Source get errorSource;

  static Future<void> _play(Source source) async {
    await _player.stop();
    await _player.play(source);
  }
}
