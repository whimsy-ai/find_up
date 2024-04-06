import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/discord_link.dart';
import 'package:game/http/http.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:oktoast/oktoast.dart';
import 'package:steamworks/steamworks.dart';

import '../utils/update_window_title.dart';

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
                  title: Text(
                      '${UI.language.tr}${Data.locale.languageCode == 'en' ? '' : ' / Language'} (${UI.languages.length})'),
                  trailing: Obx(() => DropdownButton<String>(
                        value: _language.value,
                        items: UI.languages.keys.map((key) {
                          return DropdownMenuItem(
                            value: key,
                            child: Text(UI.languages[key]!),
                          );
                        }).toList(),
                        onChanged: (v) {
                          _language.value = v!;
                          Get.updateLocale(Locale(v));
                          updateWindowTitle();
                        },
                      )),
                ),
                DiscordLink(),
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
                if (env.isSteam)
                  ListTile(
                    leading: Icon(Icons.warning_amber_rounded),
                    title: Text(UI.steamResetAchievements.tr),
                    trailing: Icon(FontAwesomeIcons.steam),
                    onTap: () async {
                      final sure = await Get.dialog(AlertDialog(
                        title: Text(UI.steamResetAchievementsConfirm.tr),
                        actions: [
                          ElevatedButton(
                            child: Text(UI.confirm.tr),
                            onPressed: () => Get.back(result: true),
                          ),
                        ],
                      ));
                      if (sure != true) return;
                      SteamClient.instance.steamUserStats
                        ..resetAllStats(true)
                        ..storeStats();
                      showToast(UI.steamResetAchievementsSuccess.tr);
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
