import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:game/save_image/save_image_controller.dart';
import 'package:game/save_image/save_image_editor.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

class PageSaveImage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageSaveImage();
}

class _PageSaveImage extends State<PageSaveImage> with WindowListener {
  late final controller = Get.find<SaveImageController>();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }  @override

  void onWindowResize() {
    super.onWindowResize();
    print('onWindowResize');
    controller.update(['ui']);
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    print('onWindowResized');
    controller.update(['ui']);
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    print('onWindowMaximize');
    controller.update(['ui']);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SaveImageEditor(onSave: _saveToFile),
      );

  void _saveToFile(Uint8List bytes) async {
    final file = await getSaveLocation(
        suggestedName: 'find_up_${DateTime.now().millisecondsSinceEpoch}.png',
        acceptedTypeGroups: [
          XTypeGroup(label: 'PNG', extensions: ['.png']),
        ]);
    if (file == null) return;
    await File(file.path).writeAsBytes(bytes);
    Get.dialog(AlertDialog(
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
