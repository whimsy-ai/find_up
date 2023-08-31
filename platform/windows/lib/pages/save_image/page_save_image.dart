import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:game/save_image/save_image_editor.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';

import '../../ui.dart';

class PageSaveImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SaveImageEditor(onSave: _saveToFile),
    );
  }

  void _saveToFile(Uint8List bytes) async {
    final file = await getSaveLocation(
        suggestedName: 'find_up_${DateTime.now().millisecondsSinceEpoch}.png');
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
          child: Text(WindowsUI.openFolder.tr),
        ),
        ElevatedButton(onPressed: () => Get.back(), child: Text(UI.ok.tr)),
      ],
    ));
  }
}
