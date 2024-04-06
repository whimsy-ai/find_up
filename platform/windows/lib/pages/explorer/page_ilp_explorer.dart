import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:game/explorer/ilp_file_list_tile.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import '../../utils/empty_list_widget.dart';
import 'folder_list_tile.dart';
import 'ilp_explorer_controller.dart';
import 'steam/steam_file.dart';
import 'steam/steam_file_list_tile.dart';
import 'steam/steam_folder_list_tile.dart';

class PageILPExplorer<T extends ILPExplorerController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// 文件夹列表
          SizedBox(
            width: 300,
            child: Column(
              children: [
                AppBar(
                  title: Text(UI.folders.tr),
                  actions: [
                    IconButton(
                      onPressed: controller.addFolder,
                      icon: Icon(Icons.add_rounded),
                      tooltip: UI.addFolder.tr,
                    ),
                  ],
                ),
                Expanded(
                  child: GetBuilder<T>(
                    id: 'folders',
                    builder: (controller) {
                      return ListView.separated(
                          itemCount: controller.folders.length,
                          separatorBuilder: (_, i) => Divider(height: 1),
                          itemBuilder: (_, i) {
                            final folder = controller.folders.elementAt(i);
                            if (folder.$2 == 'steam') {
                              return controller.filterForum<T>(
                                showPageWidget: false,
                              );
                              return SteamFolderListTile();
                            }
                            return FolderListTile(
                              folder: folder,
                              isFixedFolder: controller.isFixedFolder(folder),
                              selected: controller.currentFolder == i,
                              onTap: () => controller.openFolder(i),
                              onRemove: () {
                                controller.removeFolder(folder);
                              },
                            );
                          });
                    },
                  ),
                ),
              ],
            ),
          ),

          VerticalDivider(width: 2),

          /// 文件列表
          Expanded(
            flex: 350,
            child: GetBuilder<T>(
                id: 'files',
                builder: (controller) {
                  return Column(
                    children: [
                      ListTile(
                        title: Wrap(
                          spacing: 10,
                          children: [
                            Text(UI.fileList.tr),
                            Tooltip(
                              message: UI.reload.tr,
                              child: TextButton(
                                onPressed: controller.reload,
                                child: Icon(Icons.refresh_rounded),
                              ),
                            ),
                            if (controller.currentPath == 'steam')
                              controller.pageWidget<T>(id: 'filter'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (controller.loading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (controller.files.isEmpty) {
                            return EmptyListWidget();
                          }
                          return _fileList();
                        }),
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _fileList() => MasonryGridView.extent(
        itemCount: controller.files.length,
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, i) {
          final file = controller.files[i];
          Widget child;
          if (file is ILPFile) {
            child = ILPFileGridTile(file: file);
          } else {
            child = SteamFileGirdTile<T>(file: file as SteamFile);
          }
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                if (file is ILPFile) {
                  _play(file);
                } else {
                  _steamFile(file as SteamFile);
                }
              },
              child: child,
            ),
          );
        },
      );

  _play(ILPFile file) async {
    await PageGameEntry.play([file], mode: GameMode.gallery);
    await file.load(force: true);
    controller.update(['files']);
  }

  _steamFile(SteamFile file) async {
    await PageGameEntry.play([file], mode: GameMode.gallery);
    await file.load(force: true);
    controller.update(['files']);
  }
}
