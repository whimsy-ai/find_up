import 'package:flutter/material.dart';
import 'package:game/data.dart';
import 'package:game/http/http.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

class PageSettings extends StatelessWidget {
  late final _language = Data.locale.languageCode.obs
    ..listen((p0) {
      Data.localeString = p0;
    });

  PageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(UI.settings.tr)),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text('语言 / Language'),
                  trailing: Obx(() => DropdownButton<String>(
                        value: _language.value,
                        items: [
                          DropdownMenuItem(
                            value: 'zh',
                            child: Text("简体中文"),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text("English"),
                          )
                        ],
                        onChanged: (v) {
                          _language.value = v!;
                          Get.updateLocale(switch (v) {
                            'zh' => Locale('zh', 'CN'),
                            _ => Locale('en', 'US'),
                          });
                        },
                      )),
                ),
                ListTile(
                  title: Text(UI.removeCache.tr),
                  onTap: () async {
                    final sure = await Get.dialog<bool>(AlertDialog(
                      title: Text(UI.alertRemoveCacheTitle.tr),
                      content: Text(UI.alertRemoveCacheContent.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text(UI.confirm.tr),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          child: Text(UI.cancel.tr),
                        ),
                      ],
                    ));
                    if (sure == true) {
                      Http.clear();
                      showToast(UI.removed.tr);
                    }
                  },
                ),
                ListTile(
                  title: Text(UI.removeData.tr),
                  onTap: () async {
                    final sure = await Get.dialog<bool>(AlertDialog(
                      title: Text(UI.alertRemoveDataTitle.tr),
                      content: Text(UI.alertRemoveDataContent.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text(UI.confirm.tr),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          child: Text(UI.cancel.tr),
                        ),
                      ],
                    ));
                    if (sure == true) {
                      await Http.clear();
                      await Data.reset();
                      showToast(UI.removed.tr);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
