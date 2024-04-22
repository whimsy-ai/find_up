import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game/build_flavor.dart';
import 'package:game/bundle_files.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/game/resources.dart';
import 'package:game/game/stroke_shadow.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:steamworks/steamworks.dart';
import 'package:ui/ui.dart';
import 'package:windows/main.dart';

class RandomChallengeDialog extends StatelessWidget {
  static Widget rgbDiceCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: show,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              RGBWidget(
                colors: Colors.accents,
                builder: (c) => StrokeShadow.path(
                  size: 100,
                  Resources.iconDice,
                  color: c,
                  stroke: Stroke(width: 2, color: Colors.black54),
                ),
              ),
              Text(UI.randomChallenge.tr),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show() {
    return Get.dialog(RandomChallengeDialog._());
  }

  RandomChallengeDialog._() {
    _load();
  }

  final Rx<List<ExplorerFile>?> _files = Rx(null);
  final RxInt _value = 1.obs;
  final RxnString _error = RxnString();
  final _loading = true.obs;

  _load() async {
    _loading.value = true;
    _files.value = null;
    _error.value = null;
    if (env.isSteam) {
      final dir = _steamUGCDir();
      if (dir.existsSync()) {
        _files.value = await _steamAllUgcFiles(dir);
        if (_files.value!.isEmpty) {
          _error.value = UI.steam_randomChallengeEmpty.tr;
        }
      } else {
        _error.value = UI.folderNotExists.tr.replaceFirst('%s', dir.uri.path);
      }
    } else {
      _files.value = await getBundleFiles();
    }
    if (_files.value?.isNotEmpty == true) {
      _value.value = math.min(5, _files.value!.length);
    }
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(UI.randomChallenge.tr),
      content: SizedBox(
        width: 400,
        child: Obx(
          () => ListView(
            shrinkWrap: true,
            children: [
              /// 描述
              Text(
                (env.isSteam
                        ? UI.steam_randomChallengeDesc
                        : UI.randomChallengeDesc)
                    .tr,
              ),
              if (env.isSteam)
                Text(
                  UI.steam_randomChallengeDir.tr.replaceFirst(
                    '%s',
                    _steamUGCDir().uri.path,
                  ),
                ),

              /// 错误
              if (_error.value != null)
                Text(_error.value!, style: TextStyle(color: Colors.red)),

              /// 读取中
              if (_loading.value) ...[
                Text(
                  UI.loading.tr,
                ),
              ],

              if (!_loading.value && _error.value == null) ...[
                /// 文件总数
                Text(
                  UI.randomChallengeImages.tr.replaceFirst(
                    '%s',
                    _files.value!.length.toString(),
                  ),
                ),

                /// 滑动条
                if (_files.value?.isNotEmpty == true) ...[
                  Slider(
                    value: _value.toDouble(),
                    autofocus: true,
                    min: 1,
                    max: _files.value!.length.toDouble(),
                    onChanged: _files.value == null
                        ? null
                        : (v) {
                            _value.value = v.toInt();
                          },
                  ),

                  /// 选择的数量
                  Text(
                    UI.randomChallengeSelected.tr
                        .replaceFirst('%s', _value.value.toString()),
                    style: _value.value >= 10
                        ? TextStyle(color: Colors.red)
                        : null,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text(UI.startGame.tr),
          onPressed: _files.value?.isNotEmpty != true
              ? null
              : () {
                  Get.back();
                  var files = _files.value!.toList()..shuffle();
                  files = files.sublist(
                    0,
                    _value.value,
                  );
                  if (files.isEmpty) return;
                  PageGameEntry.play(
                    files,
                    id: 1,
                    mode: GameMode.challenge,
                  );
                },
        ),
      ],
    );
  }
}

Future<List<ExplorerFile>> _steamAllUgcFiles(Directory dir) async {
  final files = dir.listSync(recursive: true);
  return files
      .where((f) => f.path.endsWith('.ilp'))
      .map((f) => ILPFile(File(f.path)))
      .toList();
}

Directory _steamUGCDir() {
  Pointer<Utf8> _dir = malloc.allocate<Utf8>(1000);
  SteamClient.instance.steamApps.getAppInstallDir(steamAppId, _dir, 1000);
  final dir = _dir.toDartString();
  malloc.free(_dir);
  return Directory(path.join(
    dir,
    '..',
    '..',
    'workshop',
    'content',
    steamAppId.toString(),
  ));
}

class RGBWidget extends StatefulWidget {
  final Widget Function(Color color) builder;
  final List<Color> colors;

  const RGBWidget({
    super.key,
    required this.builder,
    required this.colors,
  });

  @override
  State<RGBWidget> createState() => _RGBWidgetState();
}

class _RGBWidgetState extends State<RGBWidget> {
  late Color _start = widget.colors.first;

  late Color _end = widget.colors[1];

  @override
  Widget build(BuildContext context) {
    return Animate(
      autoPlay: true,
      onPlay: (c) => c.repeat(reverse: true),
    )
        .custom(
      duration: Duration(seconds: 1),
      builder: (_, v, __) => widget.builder(Color.lerp(_start, _end, v)!),
    )
        .callback(callback: (_) {
      final list = widget.colors.toList();
      list
        ..remove(_start)
        ..remove(_end)
        ..shuffle();
      _start = _end;
      _end = list.first;
    });
  }
}
