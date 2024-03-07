import 'package:flutter_test/flutter_test.dart';
import 'package:steamworks/steamworks.dart';
import 'package:windows/utils/steam_ex.dart';
import 'package:windows/utils/steam_file_ex.dart';
import 'package:windows/utils/steam_looper.dart';
import 'package:windows/utils/steam_tags.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SteamLooper.init().start();

    final list = await SteamClient.instance.getAllItems(
      type: TagType.file,
      page: 1,
      sort: SteamUGCSort.updateTime,
    );

    print('list ${list.files.length}');

    SteamLooper.instance.stop();
  });
}
