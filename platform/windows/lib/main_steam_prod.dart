import 'package:game/build_flavor.dart';

import 'main.dart';
import 'utils/steam_looper.dart';

void main(List<String> args) async {
  BuildEnvironment.init(flavor: BuildFlavor.steamProduction);
  SteamLooper.init().start();
  runMain(args);
}
