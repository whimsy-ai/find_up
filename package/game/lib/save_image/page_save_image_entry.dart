import 'package:get/get.dart';

import '../explorer/file.dart';

class PageSaveImageEntry {
  static Future<dynamic>? open(ExplorerFile file, int index, {int? id}) {
    return Get.toNamed(
      '/save',
      id: id,
      arguments: {'file': file, 'index': index},
    );
  }
}
