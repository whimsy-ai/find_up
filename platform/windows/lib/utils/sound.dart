import 'package:audioplayers/audioplayers.dart';
import 'package:game/sound.dart';

import 'asset_path.dart';

class Sound extends ISound {
  static final Sound instance = Sound._();

  Sound._();

  @override
  DeviceFileSource get correctSource =>
      DeviceFileSource(assetPath(package: 'game', paths: [
        'sounds',
        'correct.wav',
      ]));

  @override
  DeviceFileSource get wrongSource =>
      DeviceFileSource(assetPath(package: 'game', paths: [
        'sounds',
        'wrong.mp3',
      ]));

  @override
  DeviceFileSource get errorSource =>
      DeviceFileSource(assetPath(package: 'game', paths: [
        'sounds',
        'error.wav',
      ]));
}
