import 'dart:io';

import 'package:ilp_assets/update_pubspec.dart';
import 'package:path/path.dart' as path;

final buildPath = path.join(
  Directory.current.path,
  'build',
  'app',
  'outputs',
  'bundle',
  'release',
);

final assetsPath = path.join(
  Directory.current.path,
  '..',
  '..',
  'package',
  'ilp_assets',
);

void main() async {
  print('开始构建Google Play版本');
  print('当前文件夹 ${Directory.current.path}');

  /// 更新游戏资源索引
  await updateILPAssetsPubspec(path.join(
    Directory.current.path,
    '..',
    '..',
    'package',
    'ilp_assets',
  ));

  print('检查文件');
  print('upload.jks: ${File('./android/upload.jks').lengthSync()}');
  print('secrets.properties: ${File('./android/key.properties').lengthSync()}');

  /// 更新ilp游戏资源文件
  var res = await Process.run(
    'dart ',
    ['build_pubspec.dart'],
    runInShell: true,
    workingDirectory:
        path.join(Directory.current.path, '..', '..', 'package', 'ilp_assets'),
  );
  stdout.writeln('更新ilp文件 ${res.stdout}');

  await Process.run(
    'flutter',
    ['clean'],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );
  await Process.run(
    'flutter',
    ['pub', 'get'],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );

  res = await Process.run(
    'flutter',
    [
      'build',
      'appbundle',
      '--target=./lib/main_prod.dart',
      '--verbose',
    ],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );
  if (res.exitCode != 0) throw res.stderr;
  print('appbundle 完成');

  res = await Process.run(
    'flutter',
    [
      'build',
      'apk',
      '--target=./lib/main_prod.dart',
      '--release',
      '--verbose',
    ],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );
  if (res.exitCode != 0) throw res.stderr;
  print('apk 完成');

  /// 还原资源package
  resetILPAssetsPackagePubspecFile();
  print('成功, 位置$buildPath');
}
