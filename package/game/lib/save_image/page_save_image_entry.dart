import 'package:get/get.dart';

import '../explorer/file.dart';

class PageSaveImageEntry {
  static Future<dynamic>? open(ExplorerFile file, int index) {
    return Get.toNamed('/save', arguments: {'file': file, 'index': index});
  }
}
