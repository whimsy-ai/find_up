import 'package:get/get.dart';

import '../explorer/file.dart';
import 'game_mode.dart';

class PageGameEntry {
  static Future<dynamic>? play(
    List<ExplorerFile> files, {
    required GameMode mode,
    int ilpIndex = 0,
  }) =>
      Get.toNamed('/play_challenge',
          id: GetPlatform.isDesktop ? 1 : null,
          arguments: {
            'mode': mode,
            'files': files,
            'ilpIndex': ilpIndex,
          });
}
