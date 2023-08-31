import 'package:flutter/material.dart';
import 'package:game/info_table.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'steam/steam_file.dart';

class SelectSteamFileDialog extends StatelessWidget {
  static Future<SteamFile?>? show() async {
    Get.put(ILPExplorerController(ExplorerMode.selectSteamFile));
    final file = await Get.dialog(SelectSteamFileDialog());
    Get.delete<ILPExplorerController>();
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ILPExplorerController>(
      id: 'files',
      builder: (controller) {
        return AlertDialog(
          title: Row(
            children: [
              TextButton(
                onPressed: () {
                  controller.currentPage--;
                  controller.reload();
                },
                child: Icon(Icons.chevron_left_rounded),
              ),
              Text('${controller.currentPage}'),
              TextButton(
                onPressed: () {
                  controller.currentPage++;
                  controller.reload();
                },
                child: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            height: 500,
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (_, i) => Divider(),
              itemBuilder: (_, i) {
                final file = controller.files[i] as SteamFile;
                return ListTile(
                  leading: Image.network(file.cover),
                  title: Text(file.name),
                  subtitle: InfoTable(
                    rows: [
                      ('id', file.id),
                      (UI.ilpVersion.tr, file.version.toString()),
                      (UI.layerCount.tr, file.infos.length.toString()),
                    ],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () => Get.back(result: file),
                );
              },
              itemCount: controller.files.length,
            ),
          ),
        );
      },
    );
  }
}
