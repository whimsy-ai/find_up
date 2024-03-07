import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steamworks/steamworks.dart';

import 'utils/steam_ex.dart';
import 'utils/steam_file_ex.dart';
import 'utils/steam_looper.dart';
import 'utils/steam_tags.dart';

const itemId = 3020685633;

void main() async {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    Locale.fromSubtags(languageCode: 'zh');
    SteamLooper.init().start();

    await SteamClient.instance.getAllItems(
      type: TagType.file,
      page: 1,
      sort: SteamUGCSort.updateTime,
    );

    SteamLooper.instance.stop();
  });
}
