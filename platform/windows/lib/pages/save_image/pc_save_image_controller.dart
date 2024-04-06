import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:game/game/mouse_controller.dart';
import 'package:game/save_image/save_image_controller.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/steam_achievement.dart';

/// builder id: ui, layers, image
class PCSaveImageController extends SaveImageController with MouseController {
  PCSaveImageController({
    required super.file,
    required super.index,
    super.flex = 1 - 1 / 3,
  });

  @override
  load() async {
    await file.load();
    info = await file.ilp!.info(index);
    layer = await file.ilp!.layer(index);
  }

  @override
  Future<void> onSave(Uint8List data) async {
    final file = await getSaveLocation(
        suggestedName: 'find_up_${DateTime.now().millisecondsSinceEpoch}.png',
        acceptedTypeGroups: [
          XTypeGroup(label: 'PNG', extensions: ['.png']),
        ]);
    if (file == null) return;
    await File(file.path).writeAsBytes(data);
    SteamAchievement.saveImage.achieved();
    return Get.dialog(AlertDialog(
      title: Text(UI.saved.tr),
      content: Text(file.path),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            launchUrlString(path.dirname(file.path));
          },
          child: Text(UI.openFolder.tr),
        ),
        ElevatedButton(onPressed: () => Get.back(), child: Text(UI.ok.tr)),
      ],
    ));
  }
}
