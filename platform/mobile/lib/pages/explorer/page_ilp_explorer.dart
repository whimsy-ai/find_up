import 'package:flutter/material.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';

import '../../ui.dart';
import 'asset_file_list_tile.dart';
import 'asset_ilp_file.dart';
import 'controller.dart';

class PageILPExplorer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  AppBar(
                    title: Text(MobileUI.explorer.tr),
                  ),
                  Expanded(
                    child: GetBuilder<ExplorerController>(
                      id: 'folder',
                      builder: (controller) => ListView.separated(
                        itemCount: controller.folders.length,
                        separatorBuilder: (_, i) => Divider(height: 1),
                        itemBuilder: (_, i) {
                          final name = controller.folders[i].$1;
                          return ListTile(
                            selected: i == controller.currentFolder,
                            selectedTileColor: Colors.blueGrey.withOpacity(0.3),
                            title: Text(name),
                            onTap: () => controller.openFolder(i),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 2),
            Expanded(
              flex: 3,
              child: GetBuilder<ExplorerController>(
                id: 'files',
                builder: (controller) => ListView.builder(
                  // separatorBuilder: (_, i) => Divider(height: 1),
                  itemCount: controller.files.length,
                  itemBuilder: (_, i) => AssetFileListTile(
                    file: controller.files[i] as AssetILPFile,
                    onTap: () => _tap(controller.files[i] as AssetILPFile),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  _tap(AssetILPFile file) async {
    await PageGameEntry.play(file.ilp!);
  }
}
