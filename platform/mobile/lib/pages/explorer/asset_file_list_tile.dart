import 'package:flutter/material.dart';
import 'package:game/explorer/asset_ilp_file.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/ilp_info_bottom_sheet.dart';
import 'package:game/game/animated_unlock_progress_bar.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:ui/ui.dart';

class AssetFileListTile extends StatelessWidget {
  final AssetILPFile file;

  AssetFileListTile({super.key, required this.file}) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ilp = file.ilp;
      if (ilp == null) {
        return Column(children: [
          Container(height: 200, color: Colors.black12),
          Text(UI.loading.tr),
        ]);
      }
      return Column(
        children: [
          Image.memory(
            file.cover,
            fit: BoxFit.contain,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    file.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              _infoButton(
                file,
                file.ilp!,
                Theme.of(context).hintColor,
              ),
            ],
          ),
          AnimatedUnlockProgressBar(
            from: 0,
            to: file.unlock,
          ),
        ],
      );
    });
  }
}

Widget _infoButton(
  ExplorerFile file,
  ILP ilp,
  Color color,
) =>
    InkWell(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.info_outline_rounded, color: color),
      ),
      onTap: () => ILPInfoBottomSheet.show(
        file: file,
        ilp: ilp,
        onTapPlay: (int index) => PageGameEntry.play(
          [file],
          mode: GameMode.gallery,
          ilpIndex: index,
        ),
      ),
    );
