import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:game/save_image/save_image_editor.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:oktoast/oktoast.dart';

class PageSaveImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SaveImageEditor(onSave: _saveToFile),
    );
  }

  void _saveToFile(Uint8List bytes) async {
    final result = await ImageGallerySaver.saveImage(
      bytes,
      quality: 100,
      name: 'find_up_${DateTime.now().millisecondsSinceEpoch}.png',
      isReturnImagePathOfIOS: true,
    );
    showToast('已保存到 $result');
  }
}
