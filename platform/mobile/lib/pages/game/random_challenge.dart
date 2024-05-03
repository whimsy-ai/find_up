import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:game/bundle_files.dart';
import 'package:game/explorer/file.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

class RandomChallengeDialog extends StatelessWidget {
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
    _files.value = await getBundleFiles();
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
              Text(UI.randomChallengeDesc.tr),

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
                  // print('挑战，文件数量 ${files.length}');
                  PageGameEntry.play(files, mode: GameMode.challenge);
                },
          child: Text(UI.startGame.tr),
        ),
      ],
    );
  }
}
