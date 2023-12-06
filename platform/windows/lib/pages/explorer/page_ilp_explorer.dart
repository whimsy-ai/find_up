import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:game/explorer/ilp_file_list_tile.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:steamworks/steamworks.dart';

import '../../ui.dart';
import '../../utils/steam_ex.dart';
import 'controller.dart';
import 'folder_list_tile.dart';
import 'steam/steam_file.dart';
import 'steam/steam_file_bottom_sheet.dart';
import 'steam/steam_file_list_tile.dart';
import 'steam/steam_folder_list_tile.dart';

class PageILPExplorer extends GetView<ILPExplorerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// 文件夹列表
          Expanded(
            flex: 150,
            child: Column(
              children: [
                AppBar(
                  title: Text(UI.folders.tr),
                  actions: [
                    Tooltip(
                      message: UI.addFolder.tr,
                      child: InkWell(
                        onTap: controller.addFolder,
                        child: SizedBox(width: 60, child: Icon(Icons.add)),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GetBuilder<ILPExplorerController>(
                    id: 'folders',
                    builder: (context) {
                      return ListView.separated(
                          itemCount: controller.folders.length,
                          separatorBuilder: (_, i) => Divider(height: 1),
                          itemBuilder: (_, i) {
                            final folder = controller.folders.elementAt(i);
                            if (folder.$2 == 'steam') {
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
            child: GetBuilder<ILPExplorerController>(
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    child: Icon(Icons.chevron_left_rounded),
                                    onPressed: () {
                                      controller.currentPage--;
                                      controller.reload();
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: 50,
                                    height: 26,
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: controller.currentPage.toString(),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[1-9][0-9]*'),
                                        ),
                                      ],
                                      onSubmitted: (v) {
                                        controller.currentPage = int.parse(v);
                                        controller.reload();
                                      },
                                      style: TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '/ ${controller.totalPage}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(width: 10),
                                  TextButton(
                                    child: Icon(Icons.chevron_right_rounded),
                                    onPressed: () {
                                      controller.currentPage++;
                                      controller.reload();
                                    },
                                  ),

                                  /// Same author
                                  if (controller.userId != null &&
                                      controller.userId !=
                                          SteamClient.instance.userId)
                                    Chip(
                                      avatar: Icon(
                                        Icons.person,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                      ),
                                      label: Text(
                                        WindowsUI.steamAuthorOtherFiles.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDeleted: () {
                                        controller.userId = null;
                                        controller.reload();
                                      },
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      deleteIconColor: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                    ),
                                ],
                              ),

                            /// search
                            if (!controller.subscribed) _search(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (controller.loading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (controller.files.isEmpty) {
                            return Center(
                              child: Wrap(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.file_copy_sharp,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    UI.empty.tr,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          return _fileNewList();
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

  Widget _fileNewList() => MasonryGridView.extent(
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
            child = SteamFileGirdTile(file: file as SteamFile);
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
    await PageGameEntry.play(file.ilp!);
    file.load(force: true);
    controller.update(['files']);
  }

  _steamFile(SteamFile file) async {
    if (file.ilpFile != null) {
      await PageGameEntry.play(ILP.fromFileSync(file.ilpFile!));
      controller.update(['files']);
    } else {
      await SteamFileBottomSheet.show(file);
    }
  }

  Widget _search() => SizedBox(
        width: 130,
        height: 28,
        child: TextField(
          controller: TextEditingController(
            text: controller.search,
          ),
          decoration: InputDecoration(
            prefixIcon: SizedBox(
              child: Icon(
                Icons.search,
                size: 14,
              ),
            ),
            suffixIcon: InkWell(
              child: Icon(
                Icons.close_rounded,
                size: 14,
              ),
              onTap: () {
                controller.search = null;
                controller.currentPage = 1;
                controller.openFolder(controller.currentFolder);
              },
            ),
            contentPadding: EdgeInsets.zero,
            hintText: UI.search.tr,
            hintStyle: TextStyle(fontSize: 14),
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
          onSubmitted: (v) {
            controller.search = v;
            controller.currentPage = 1;
            controller.openFolder(controller.currentFolder);
          },
        ),
      );
}
