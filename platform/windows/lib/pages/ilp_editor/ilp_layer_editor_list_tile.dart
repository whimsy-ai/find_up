import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/global_progress_indicator_dialog.dart';
import 'package:game/info_table.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'controller.dart';
import 'ilp_info_file.dart';

class ILPEditorInfoListTile extends GetView<ILPEditorController> {
  static const double iconSize = 20;
  final ILPInfoFile file;

  const ILPEditorInfoListTile({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final removeWidget = Tooltip(
          message: UI.remove.tr,
          child: InkWell(
            onTap: () => controller.removeFile(file),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: iconSize,
              ),
            ),
          ),
        );
        final refreshWidget = Tooltip(
          message: UI.reload.tr,
          child: InkWell(
            onTap: () => file.load(force: true),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.refresh,
                color: Colors.blue,
                size: iconSize,
              ),
            ),
          ),
        );
        if (file.exception != null) {
          return ListTile(
            leading: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 20,
            ),
            title: Text(file.file),
            subtitle: Text(file.exception!.message),
            trailing: Wrap(children: [refreshWidget, removeWidget]),
          );
        } else {
          final info = file.config!;
          return ListTile(
            onTap: () => controller.editInfoConfig(file),
            leading: Image.file(
              File(info.cover),
              width: 50,
              height: 50,
            ),
            title: Text(controller.infoNameCaches[file.file] ?? info.name),
            subtitle: InfoTable(
              style: TextStyle(fontSize: 12, color: Colors.grey),
              rows: [
                ('${UI.file.tr} ${UI.path.tr}', info.filePath!),
                (UI.resolution.tr, '${info.width} x ${info.height}'),
                (UI.layerCount.tr, info.layer.count()),
              ],
            ),
            trailing: Wrap(
              spacing: 10,
              children: [
                refreshWidget,
                Tooltip(
                  message: UI.test.tr,
                  child: InkWell(
                    onTap: () async {
                      GlobalProgressIndicatorDialog.show();
                      ILP? ilp;
                      try {
                        ilp = ILP.fromBytes(await controller.toBytes());
                      } on ILPConfigException catch (e) {
                        Get.dialog(
                          AlertDialog(
                            title: Text(UI.error.tr),
                            content: Text(e.file ?? e.message),
                          ),
                        );
                      }
                      if (ilp != null) {
                        Get.back();
                        PageGameEntry.play(
                          ilp,
                          index: controller.configs.indexOf(file),
                          allowDebug: true,
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.green,
                        size: iconSize,
                      ),
                    ),
                  ),
                ),
                removeWidget,
              ],
            ),
          );
        }
      },
    );
  }
}
