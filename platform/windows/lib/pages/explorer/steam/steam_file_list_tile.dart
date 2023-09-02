import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/get_ilp_info_unlock.dart';
import 'package:game/info_table.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import '../controller.dart';
import 'steam_cached_image.dart';
import 'steam_file.dart';
import 'steam_file_bottom_sheet.dart';

class SteamFileIcon extends StatelessWidget {
  static const _offset = 86.0;
  final void Function() onTap;
  final _mouseHover = false.obs;
  final SteamFile file;

  late final unlock = file.infos.map((e) => getIlpInfoUnlock(e)).toList().sum /
      file.infos.length;

  SteamFileIcon({
    super.key,
    required this.file,
    required this.onTap,
  }) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ILPExplorerController>(
        id: file.id,
        builder: (context) {
          return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: MouseRegion(
                  onEnter: (_) => _mouseHover.value = true,
                  onExit: (_) => _mouseHover.value = false,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SteamCachedImage(file.cover),
                      ),
                      Obx(
                        () => AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeOutQuint,
                          left: 0,
                          right: 0,
                          bottom: _mouseHover.value ? 0 : -_offset,
                          height: 120,
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                            padding: EdgeInsets.all(8),
                            child: DefaultTextStyle(
                              style: TextStyle(color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.thumb_up_alt_rounded,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 4),
                                                Text(file.voteUp.toString()),
                                                SizedBox(width: 10),
                                                Icon(
                                                  Icons.thumb_down_alt_rounded,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 4),
                                                Text(file.voteDown.toString()),
                                              ],
                                            ),
                                            Text(
                                              UI.imageLengthStr.trArgs([
                                                file.infos.length.toString(),
                                              ]),
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '${UI.ilpVersion.tr} ${file.version}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (file.ilpFile != null)
                                        _infoButton(file),
                                    ],
                                  ),
                                  AnimatedUnlockProgressBar(
                                    duration: Duration(milliseconds: 300),
                                    from: 0,
                                    to: _mouseHover.value ? unlock : 0,
                                    text: UI.unlock.tr,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}

class SteamFileListTile extends StatelessWidget {
  final void Function() onTap;
  final SteamFile file;

  late final unlock = file.infos.map((e) => getIlpInfoUnlock(e)).toList().sum /
      file.infos.length;

  SteamFileListTile({
    super.key,
    required this.file,
    required this.onTap,
  }) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    Widget? leading = SizedBox(width: 70);
    Widget title, subTitle;
    title = Text(file.name);
    subTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoTable(
          rows: [
            (UI.ilpVersion.tr, file.version.toString()),
            (UI.imageLength.tr, file.infos.length.toString()),
          ],
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        AnimatedUnlockProgressBar(
          width: 300,
          from: 0,
          to: unlock,
          text: UI.unlock.tr,
        ),
      ],
    );

    return GetBuilder<ILPExplorerController>(
        id: file.id,
        builder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: SteamCachedImage(
                    file.cover,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              SizedBox(
                width: 85,
                height: 85,
                child: ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.5, 1],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height)),
                  blendMode: BlendMode.dstIn,
                  child: SteamCachedImage(
                    file.cover,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              ListTile(
                visualDensity: VisualDensity(vertical: 4),
                onTap: onTap,
                leading: leading,
                title: title,
                subtitle: subTitle,
                trailing: Wrap(
                  children: [
                    if (file.ilpFile != null) _infoButton(file),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

Widget _infoButton(
  SteamFile file, {
  Color color = Colors.white,
}) =>
    InkWell(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.info_outline_rounded, color: color),
      ),
      onTap: () => SteamFileBottomSheet.show(file),
    );
