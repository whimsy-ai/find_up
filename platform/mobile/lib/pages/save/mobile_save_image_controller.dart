import 'dart:typed_data';
import 'dart:ui';

import 'package:game/save_image/save_image_controller.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:oktoast/oktoast.dart';

class MobileSaveImageController extends SaveImageController {
  MobileSaveImageController({
    required super.file,
    required super.index,
    super.flex = 1 - 1 / 3,
  });

  @override
  Offset onScalePosition(Offset position) => position;

  @override
  load() async {
    loading = true;
    update(['ui', 'layers', 'image']);
    await file.load();
    info = await file.ilp!.info(index);
    layer = await file.ilp!.layer(index);
    width = layer.width.toDouble();
    height = layer.height.toDouble();
    resetScaleAndOffset();
    loading = false;
    update(['ui', 'layers', 'image']);
  }

  @override
  Future<void> onSave(Uint8List data) async {
    final result = await ImageGallerySaver.saveImage(
      data,
      quality: 100,
      name: 'find_up_${DateTime.now().millisecondsSinceEpoch}.png',
      isReturnImagePathOfIOS: true,
    );
    showToast('已保存到 $result');
  }
}
