import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class Resources {
  static late final BytesSource correctAudio, wrongAudio, errorAudio, duckAudio;
  static late final Path iconStack,
      iconTime,
      iconStopWatch,
      iconTimer,
      iconFocus,
      iconSave,
      iconDownload,
      iconRefresh,
      iconVideo,
      iconPlay,
      iconPause,
      iconDice,
      iconLeft,
      iconInfo,
      iconSun,
      iconMoon,
      iconKey;

  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    correctAudio = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/correct.wav'))
            .buffer
            .asUint8List());
    wrongAudio = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/wrong.mp3'))
            .buffer
            .asUint8List());
    errorAudio = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/error.wav'))
            .buffer
            .asUint8List());
    duckAudio = BytesSource(
        (await rootBundle.load('packages/game/assets/sounds/duck.mp3'))
            .buffer
            .asUint8List());
    iconLeft = await _loadSvg('icon_left');
    iconStack = await _loadSvg('icon_stack');
    iconTime = await _loadSvg('icon_time');
    iconTimer = await _loadSvg('icon_timer');
    iconStopWatch = await _loadSvg('icon_stopwatch');
    iconFocus = await _loadSvg('icon_focus');
    iconSave = await _loadSvg('icon_save');
    iconVideo = await _loadSvg('icon_video');
    iconDownload = await _loadSvg('icon_download');
    iconRefresh = await _loadSvg('icon_refresh');
    iconKey = await _loadSvg('icon_key');
    iconDice = await _loadSvg('icon_dice');
    iconPlay = await _loadSvg('icon_play');
    iconPause = await _loadSvg('icon_pause');
    iconInfo = await _loadSvg('icon_info');
    iconSun = await _loadSvg('icon_sun');
    iconMoon = await _loadSvg('icon_moon');
    _inited = true;
  }
}

Future<Path> _loadSvg(String name) async {
  final file =
      await rootBundle.loadString('packages/game/assets/images/$name.svg');
  final xml = XmlDocument.parse(file);
  return parseSvgPathData(xml.findAllElements('path').last.getAttribute('d')!);
}
