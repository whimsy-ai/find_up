import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../game/animated_unlock_progress_bar.dart';
import '../game/page_game_entry.dart';
import 'ilp_file.dart';
import 'ilp_info_bottom_sheet.dart';

class ILPFileGridTile extends StatelessWidget {
  final ILPFile file;

  ILPFileGridTile({super.key, required this.file}) {
    file.load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (file.exception != null) {
        return Column(
          children: [
            SizedBox(
              height: 100,
              child: Center(
                child: Icon(Icons.warning_amber_rounded, color: Colors.red),
              ),
            ),
            ListTile(
              title: Text(file.exception!.message),
            ),
          ],
        );
      }
      if (file.ilp == null) {
        return Column(
          children: [
            SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            ListTile(title: Text(UI.loading.tr)),
          ],
        );
      }
      return Column(
        children: [
          LayoutBuilder(builder: (context, c) {
            return Image.memory(
              file.cover,
              width: c.maxWidth,
            );
          }),
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
              _infoButton(file: file, ilp: file.ilp!),
            ],
          ),
          AnimatedUnlockProgressBar(
            width: 300,
            from: 0,
            to: file.unlock,
            text: UI.unlock.tr,
          ),
        ],
      );
    });
  }
}

Widget _infoButton({
  required ILPFile file,
  required ILP ilp,
  Color color = Colors.black38,
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
          [file],
          ilpIndex: index,
        ),
      ),
    );
