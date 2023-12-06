import 'package:flutter/material.dart';
import 'package:game/info_table.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../explorer/controller.dart';
import '../../explorer/steam/steam_file.dart';

final _format = DateFormat('yyyy-MM-dd hh:mm:ss');
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
            width: 500,
            height: 500,
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (_, i) => Divider(height: 1),
              itemBuilder: (_, i) {
                final file = controller.files[i] as SteamFile;
                return ListTile(
                  style: ListTileStyle.list,
                  dense: true,
                  leading: Image.network(file.cover,width: 80),
                  title: Text(file.name),
                  subtitle: InfoTable(
                    firstColumnWidth: 120,
                    rows: [
                      ('id', file.id),
                      (UI.ilpVersion.tr, file.version),
                      (UI.imageLength.tr, file.infos.length),
                      (UI.publishTime.tr, _format.format(file.publishTime)),
                      (UI.updateTime.tr, _format.format(file.updateTime)),
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
