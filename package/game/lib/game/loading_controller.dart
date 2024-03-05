import 'dart:math';

import 'package:get/get.dart';

import '../explorer/file.dart';

mixin LoadingController on GetxController {
  int downloadedBytes = 0, totalBytes = 0;

  int get downloadedPercent => ((downloadedBytes / totalBytes) * 100).toInt();

  resetBytes() {
    downloadedBytes = totalBytes = 0;
  }

  Future<void> loadFile(ExplorerFile file, Random random);
}
