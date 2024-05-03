import 'package:get/get.dart';

import '../explorer/file.dart';

class PageSaveImageEntry {
  static Future<dynamic>? open(ExplorerFile file, int index) {
    return Get.toNamed(
      '/save',
      id: GetPlatform.isDesktop ? 1 : null,
      arguments: {'file': file, 'index': index},
    );
  }
}
