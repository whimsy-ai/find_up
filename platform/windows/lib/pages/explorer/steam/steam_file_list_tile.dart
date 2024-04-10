import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/get_ilp_info_unlock.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

import '../../../utils/steam_filter.dart';
import '../../../utils/steam_tags.dart';
import 'steam_cached_image.dart';
import 'steam_file.dart';
import 'steam_file_bottom_sheet.dart';

class SteamFileGirdTile<T extends SteamFilterController>
    extends StatelessWidget {
  final SteamFile file;
  late final double unlock = file.type == TagType.file
      ? file.infos.map((e) => getIlpInfoUnlock(e)).toList().sum /
          file.infos.length
      : 0;

  SteamFileGirdTile({super.key, required this.file}) {
    if (file.type == TagType.file) file.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      id: file.id,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Positioned(child: SteamCachedImage(file.cover)),
                if (file.levelCount != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Tooltip(
                      message: UI.levelCount.tr,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).dialogBackgroundColor.withOpacity(0.5),
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(8)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          children: [
                            Icon(FontAwesomeIcons.layerGroup, size: 16),
                            Text('${file.levelCount}'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                _infoButton(
                  file,
                  Theme.of(context).hintColor,
                ),
              ],
            ),
            if (file.type == TagType.file)
              AnimatedUnlockProgressBar(
                duration: Duration(milliseconds: 300),
                from: 0,
                to: unlock,
              ),
          ],
        );
      },
    );
  }

  Widget _infoButton(
    SteamFile file,
    Color color,
  ) =>
      InkWell(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.info_outline_rounded, color: color),
        ),
        onTap: () => SteamFileBottomSheet.show<T>(file),
      );
}
