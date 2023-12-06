import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/get_ilp_info_unlock.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import '../controller.dart';
import 'steam_cached_image.dart';
import 'steam_file.dart';
import 'steam_file_bottom_sheet.dart';

class SteamFileGirdTile extends StatelessWidget {
  final SteamFile file;
  late final unlock = file.infos.map((e) => getIlpInfoUnlock(e)).toList().sum /
      file.infos.length;

  SteamFileGirdTile({super.key, required this.file}) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ILPExplorerController>(
      id: file.id,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SteamCachedImage(file.cover),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                _infoButton(file),
              ],
            ),
            // Text(
            //   UI.imageLengthStr.trArgs([
            //     file.infos.length.toString(),
            //   ]),
            //   style: TextStyle(fontSize: 12),
            // ),
            // Text(
            //   '${UI.ilpVersion.tr} ${file.version}',
            //   style: TextStyle(fontSize: 12),
            // ),
            AnimatedUnlockProgressBar(
              duration: Duration(milliseconds: 300),
              from: 0,
              to: unlock,
              text: UI.unlock.tr,
            ),
          ],
        );
      },
    );
  }
}

Widget _infoButton(
  SteamFile file, {
  Color color = Colors.black38,
}) =>
    InkWell(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.info_outline_rounded, color: color),
      ),
      onTap: () => SteamFileBottomSheet.show(file),
    );
