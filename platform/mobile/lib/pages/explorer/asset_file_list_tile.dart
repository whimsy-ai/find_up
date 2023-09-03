import 'package:flutter/material.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/ilp_info_bottom_sheet.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/info_table.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'asset_ilp_file.dart';

class AssetFileListTile extends StatelessWidget {
  final AssetILPFile file;
  final void Function() onTap;

  const AssetFileListTile({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    file.load();
    return Obx(() {
      final ilp = file.ilp;
      if (ilp == null) {
        return ListTile(title: Text(UI.loading.tr));
      }
      return Table(
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FixedColumnWidth(85),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: InkWell(
                  onTap: onTap,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Image.memory(
                          file.cover,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          visualDensity: VisualDensity(vertical: 4),
                          title: Text(file.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InfoTable(
                                rows: [
                                  (UI.ilpVersion.tr, file.version.toString()),
                                  (
                                    UI.imageLength.tr,
                                    file.infoLength.toString()
                                  ),
                                ],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              AnimatedUnlockProgressBar(
                                width: 300,
                                from: 0,
                                to: file.unlock,
                                text: UI.unlock.tr,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.fill,
                child: _infoButton(file: file, ilp: ilp, color: Colors.black45),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _infoButton({
    required ExplorerFile file,
    required ILP ilp,
    Color color = Colors.white,
  }) =>
      InkWell(
        child: Icon(Icons.info_outline_rounded, color: color),
        onTap: () => ILPInfoBottomSheet.show(
          file: file,
          ilp: ilp,
          onTapPlay: (int index) => PageGameEntry.play(
            ilp,
            index: index,
          ),
        ),
      );
}
