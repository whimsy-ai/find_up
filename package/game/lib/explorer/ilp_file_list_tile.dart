import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:path/path.dart' as path;

import '../game/animated_unlock_progress_bar.dart';
import '../game/page_game_entry.dart';
import 'ilp_info_bottom_sheet.dart';
import '../info_table.dart';
import '../ui.dart';
import 'ilp_file.dart';

class ILPFileIcon extends StatelessWidget {
  static const _offset = 86.0;
  final ILPFile file;
  final void Function() onTap;
  final _mouseHover = false.obs;

  ILPFileIcon({super.key, required this.file, required this.onTap}) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget child;
      if (file.exception != null) {
        child = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
              Text(file.exception!.message),
              Text(
                file.exception!.file ?? '',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      } else {
        if (file.ilp == null) {
          child = Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.access_time_rounded),
              Text(UI.loading.tr),
            ],
          );
        } else {
          child = MouseRegion(
            onEnter: (_) => _mouseHover.value = true,
            onExit: (_) => _mouseHover.value = false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.memory(file.cover),
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
                                      Text(
                                        path.basename(file.file.path),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        UI.imageLengthStr.trArgs([
                                          file.infoLength.toString(),
                                        ]),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                _infoButton(file: file, ilp: file.ilp!),
                              ],
                            ),
                            AnimatedUnlockProgressBar(
                              duration: Duration(milliseconds: 300),
                              from: 0,
                              to: _mouseHover.value ? file.unlock : 0,
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
          );
        }
      }
      return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: file.ilp == null ? null : onTap,
            child: child,
          ));
    });
  }
}

class ILPFileListTile extends StatelessWidget {
  final ILPFile file;
  final void Function() onTap;

  ILPFileListTile({
    super.key,
    required this.file,
    required this.onTap,
  }) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget? leading;
      Widget title, subTitle;
      if (file.exception != null) {
        leading = Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
        );
        title = Text(file.exception!.message);
        subTitle = Text(file.file.path);
      } else {
        if (file.ilp == null) {
          title = Text(UI.loading.tr);
          subTitle = Text(file.file.path);
        } else {
          leading = SizedBox(width: 70);
          title = Text(file.name);
          subTitle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoTable(
                space: 14,
                rows: [
                  (UI.file.tr, path.basename(file.file.path)),
                  (UI.ilpVersion.tr, file.version.toString()),
                  (UI.imageLength.tr, file.infoLength.toString()),
                ],
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              AnimatedUnlockProgressBar(
                width: 300,
                from: 0,
                to: file.unlock,
                text: UI.unlock.tr,
              ),
            ],
          );
        }
      }
      return Stack(
        children: [
          if (file.ilp != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image.memory(
                  file.cover,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          if (file.ilp != null)
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
                child: Image.memory(
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
                if (file.ilp != null) _infoButton(file: file, ilp: file.ilp!),
              ],
            ),
          ),
        ],
      );
    });
  }
}

Widget _infoButton({
  required ILPFile file,
  required ILP ilp,
  Color color = Colors.white,
}) =>
    InkWell(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.info_outline_rounded, color: color),
      ),
      onTap: () => ILPInfoBottomSheet.show(
        file: file,
        ilp: ilp,
        onTapPlay: (int index) => PageGameEntry.play(
          ilp,
          index: index,
        ),
      ),
    );
