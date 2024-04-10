import 'package:game/build_flavor.dart';

import 'main.dart';
import 'utils/steam_ex.dart';
import 'utils/steam_looper.dart';

void main(List<String> args) async {
  BuildEnvironment.init(flavor: BuildFlavor.steam);
  SteamLooper.init().start();
  SteamDownloadListener.init();
  runMain(args);
}
