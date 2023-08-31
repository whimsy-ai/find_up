import 'package:flutter/material.dart';
import 'package:game/build_flavor.dart';

import 'main.dart';

void main() async {
  BuildEnvironment.init(flavor: BuildFlavor.development);
  WidgetsFlutterBinding.ensureInitialized();
  runMain();
}
