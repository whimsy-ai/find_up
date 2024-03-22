import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:game/data.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/asset_path.dart';

ilpEditorTipsDialog({bool force = false}) async {
  if (!force && !Data.showILPEditorTip) return;
  final dontShowAgain = false.obs;
  await Get.dialog(AlertDialog(
    title: Text(UI.ilpEditorHelpTitle.tr),
    content: SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text('1')),
            title: Text(UI.ilpEditorStep1Title.tr),
            subtitle: Text(UI.ilpEditorStep1Content.tr),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('2')),
            title: Text.rich(
              TextSpan(text: UI.ilpEditorStep2TitleUse.tr, children: [
                WidgetSpan(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () => launchUrlString(
                        'https://github.com/whimsy-ai/ilp_photoshop_plugin'),
                    child: Text(
                      UI.ilpEditorStep2TitleBtn.tr,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                )),
                TextSpan(text: UI.ilpEditorStep2TitleExport.tr),
              ]),
            ),
            subtitle: Text(UI.ilpEditorStep2Content.tr),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('3')),
            title: Text(UI.ilpEditorStep3Title.tr),
            subtitle: Text(UI.ilpEditorStep3Content.tr),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('4')),
            title: Text(UI.ilpEditorStep4Title.tr),
            subtitle: Text(UI.ilpEditorStep4Content.tr),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        child: Text(UI.exportLogoExamplePSD.tr),
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
                title: Text(UI.exportFinish.tr),
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
