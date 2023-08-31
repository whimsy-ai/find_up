import 'package:game/build_flavor.dart';

import 'main.dart';

void main(List<String> args) async {
  BuildEnvironment.init(flavor: BuildFlavor.development);
  runMain(args);
}
