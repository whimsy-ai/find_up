import 'package:flutter/material.dart';
import 'package:game/save_image/save_image_editor.dart';

import 'pc_save_image_controller.dart';

class PageSaveImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: SaveImageEditor<PCSaveImageController>());
}
