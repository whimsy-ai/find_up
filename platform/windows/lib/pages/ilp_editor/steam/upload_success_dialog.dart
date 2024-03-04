import 'package:flutter/material.dart';
import 'package:game/data.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:steamworks/steamworks.dart';

import '../../../utils/steam_ex.dart';
import '../ilp_editor_controller.dart';

class SteamUploadSuccessDialog<T extends ILPEditorController>
    extends GetView<T> {
  final SubmitResult result;

  const SteamUploadSuccessDialog._({super.key, required this.result});

  static Future show({required SubmitResult result}) {
    return Get.dialog(
      SteamUploadSuccessDialog._(result: result),
      barrierDismissible: !result.userNeedsToAcceptWorkshopLegalAgreement,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.userNeedsToAcceptWorkshopLegalAgreement)
          Text.rich(
            TextSpan(children: [
              WidgetSpan(
                child: Icon(Icons.info_outline_rounded, color: Colors.red),
              ),
              TextSpan(text: UI.steamEulaContent.tr),
              TextSpan(text: '\n'),
            ]),
          ),
        Text.rich(
          TextSpan(children: [
            WidgetSpan(
              child: Icon(Icons.tips_and_updates_outlined, color: Colors.red),
            ),
            TextSpan(
              text: UI.steamLimitedAccountDesc1
                  .trParams({'s': UI.steamLimitedAccount.tr}),
            ),
            TextSpan(text: '\n'),
            WidgetSpan(
                child: InkWell(
              onTap: () {
                final url = Data.locale.languageCode == 'zh'
                    ? 'https://help.steampowered.com/zh-cn/faqs/view/71D3-35C2-AD96-AA3A'
                    : 'https://help.steampowered.com/en/faqs/view/71D3-35C2-AD96-AA3A';
                SteamClient.instance.openUrl(url);
              },
              child: Text(
                UI.steamLimitedAccountDesc2.trParams(
                  {'s': UI.steamLimitedAccount.tr},
                ),
                style: TextStyle(color: Colors.lightBlue),
              ),
            )),
          ]),
        ),
      ],
    );
    return AlertDialog(
      title: Text(UI.steamUploadSuccess.tr),
      content: content,
      actions: [
        TextButton(
          onPressed: () {
            SteamClient.instance.openUrl(
                'steam://url/CommunityFilePage/${result.publishedFileId}');
          },
          child: Text(UI.viewFileInSteam.tr),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(UI.ok.tr),
        ),
        if (result.userNeedsToAcceptWorkshopLegalAgreement)
          ElevatedButton(
            child: Text(UI.steamEulaOpen.tr),
            onPressed: () {
              SteamClient.instance.openEulaUrl();
            },
          ),
      ],
    );
  }
}
