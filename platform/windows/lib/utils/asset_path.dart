import 'dart:io';

import 'package:path/path.dart' as path;

/// paths里可以忽略路径中的assets文件夹
String assetPath({String? package, List<String>? paths}) {
  final nPath = <String>[
    path.dirname(Platform.resolvedExecutable),
    'data',
    'flutter_assets',
  ];
  if (package == null) {
    nPath.addAll(['assets']);
  } else {
    nPath.addAll([
      'packages',
      package,
      'assets',
    ]);
  }
  if (paths != null) {
    if (paths.first == 'assets') paths.removeAt(0);
    nPath.addAll(paths);
  }
  return path.joinAll(nPath);
}
