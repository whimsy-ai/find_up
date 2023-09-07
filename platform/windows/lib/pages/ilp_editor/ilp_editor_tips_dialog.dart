import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:game/data.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ui.dart';
import '../../utils/asset_path.dart';

ilpEditorTipsDialog({bool force = false}) async {
  if (!force && !Data.showILPEditorTip) return;
  final dontShowAgain = false.obs;
  await Get.dialog(AlertDialog(
    title: Text(WindowsUI.ilpEditorHelpTitle.tr),
    content: SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text('1')),
            title: Text(WindowsUI.ilpEditorStep1Title.tr),
            subtitle: Text(WindowsUI.ilpEditorStep1Content.tr),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('2')),
            title: Text.rich(
              TextSpan(text: WindowsUI.ilpEditorStep2TitleUse.tr, children: [
                WidgetSpan(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () => launchUrlString(
                        'https://github.com/whimsy-ai/ilp_photoshop_plugin'),
                    child: Text(
                      WindowsUI.ilpEditorStep2TitleBtn.tr,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                )),
                TextSpan(text: WindowsUI.ilpEditorStep2TitleExport.tr),
              ]),
            ),
            subtitle: Text(WindowsUI.ilpEditorStep2Content.tr),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('3')),
            title: Text(WindowsUI.ilpEditorStep3Title.tr),
            subtitle: Text(WindowsUI.ilpEditorStep3Content.tr),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('4')),
            title: Text(WindowsUI.ilpEditorStep4Title.tr),
            subtitle: Text(WindowsUI.ilpEditorStep4Content.tr),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        child: Text(WindowsUI.exportLogoExamplePSD.tr),
        onPressed: () async {
          final psd = File(assetPath(paths: ['logo_example.psd']));
          final FileSaveLocation? file = await getSaveLocation(
            suggestedName: 'logo_example.psd',
            acceptedTypeGroups: [
              XTypeGroup(label: 'PSD', extensions: ['.psd']),
            ],
          );
          if (file != null) {
            await File(file.path).writeAsBytes(await psd.readAsBytes());
            final sure = await Get.dialog(
              AlertDialog(
                title: Text(WindowsUI.exportFinish.tr),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(), child: Text(UI.back.tr)),
                  ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(UI.open.tr)),
                ],
              ),
            );
            if (sure == true) launchUrlString(file.path);
          }
        },
      ),
      if (!force)
        Obx(() => FilterChip(
              label: Text(UI.dontShowAgain.tr),
              selected: dontShowAgain.value,
              onSelected: (val) => dontShowAgain.value = val,
            )),
      ElevatedButton(onPressed: () => Get.back(), child: Text(UI.ok.tr)),
    ],
  ));
  if (dontShowAgain.value) {
    Data.showILPEditorTip = false;
  }
}
