import 'package:flutter/material.dart';
import 'package:game/data.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:steamworks/steamworks.dart';

import '../../../utils/steam_ex.dart';

class SteamResultDialog extends StatelessWidget {
  final SubmitResult result;

  const SteamResultDialog._({super.key, required this.result});

  static Future show({required SubmitResult result}) {
    return Get.dialog(
      SteamResultDialog._(result: result),
      barrierDismissible: !result.userNeedsToAcceptWorkshopLegalAgreement,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOk = result.result == EResult.eResultOK;
    Widget title;
    Widget? content;
    if (isOk) {
      title = Text(UI.steamUploadSuccess.tr);
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.userNeedsToAcceptWorkshopLegalAgreement)
            Text.rich(
              TextSpan(children: [
                WidgetSpan(
                  child: Icon(Icons.info_outline_rounded, color: Colors.red),
                ),
                TextSpan(text: '${UI.steamEulaContent1.tr}\n'),
                TextSpan(text: UI.steamEulaContent2.tr),
              ]),
            ),
          Text.rich(
            TextSpan(children: [
              WidgetSpan(
                child: Icon(Icons.tips_and_updates_outlined, color: Colors.red),
              ),
              TextSpan(
                text: UI.steamLimitedAccountDesc1
                    .replaceAll('%s', UI.steamLimitedAccount.tr),
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
                  UI.steamLimitedAccountDesc2.tr.replaceFirst(
                    '%s',
                    UI.steamLimitedAccount.tr,
                  ),
                  style: TextStyle(color: Colors.lightBlue),
                ),
              )),
            ]),
          ),
        ],
      );
    } else {
      title = Text(UI.unKnowError.tr);
    }
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        if (isOk)
          TextButton(
            onPressed: () {
              SteamClient.instance.openUGCItemUrl(result.publishedFileId);
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
