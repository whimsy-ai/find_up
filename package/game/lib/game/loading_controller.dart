import 'package:get/get.dart';

mixin LoadingController on GetxController {
  int downloadedBytes = 0, totalBytes = 0;

  int get downloadedPercent => ((downloadedBytes / totalBytes) * 100).toInt();

  resetBytes() {
    downloadedBytes = totalBytes = 0;
  }
}
