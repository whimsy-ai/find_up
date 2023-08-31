import 'package:flutter_test/flutter_test.dart';
import 'package:steamworks/steamworks.dart';

import 'utils/steam_ex.dart';
import 'utils/steam_looper.dart';

const itemId = 3020685633;

void main() async {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SteamLooper.init().start();

    await SteamClient.instance.getAllItems(page: 1);

    SteamLooper.instance.stop();
  });
}
