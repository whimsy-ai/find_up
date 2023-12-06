import 'package:flutter_test/flutter_test.dart';
import 'package:steamworks/steamworks.dart';
import 'package:windows/utils/steam_ex.dart';
import 'package:windows/utils/steam_looper.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SteamLooper.init().start();

    final list = await SteamClient.instance.getAllItems(
      page: 1,
      sort: SteamFileSort.updateTime,
    );

    print('list ${list.files.length}');

    SteamLooper.instance.stop();
  });
}
