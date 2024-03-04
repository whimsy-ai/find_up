import 'package:get/get.dart';

import '../explorer/file.dart';

class PageGameEntry {
  static Future<dynamic>? play(List<ExplorerFile> files, {int ilpIndex = 0}) {
    return Get.toNamed('/play_challenge', arguments: {
      'files': files,
      'ilpIndex': ilpIndex,
    });
  }

// static Future play(
//   ILP ilp, {
//   int? index = 0,
//   bool? allowDebug = false,
//   bool allowPause = false,
//   timeMode = TimeMode.up,
// }) {
//   print('play game');
//   return Get.toNamed('/game', arguments: {
//     'ilp': ilp,
//     'index': index,
//     'allowDebug': allowDebug,
//     'allowPause': allowPause,
//     'timeMode': timeMode,
//   })!;
// }

// static replace(
//   ILP ilp, {
//   int? index = 0,
//   bool? allowDebug = false,
//   bool allowPause = false,
//   timeMode = TimeMode.up,
// }) async {
//   Get.back(closeOverlays: true);
//   SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
//     Get.toNamed('/game', arguments: {
//       'ilp': ilp,
//       'index': index,
//       'allowDebug': allowDebug,
//       'allowPause': allowPause,
//       'timeMode': timeMode,
//     })!;
//   });
// }
}
