import 'dart:io';

import 'package:ilp_assets/update_pubspec.dart';
import 'package:path/path.dart' as path;

final buildPath = path.join(
  Directory.current.path,
  'build',
  'windows',
  'x64',
  'runner',
  'Release',
);

void main() async {
  print('开始构建微软商店版本');
  print('当前文件夹 ${Directory.current.path}');

  /// 更新游戏资源索引
  await updateILPAssetsPubspec(path.join(
    Directory.current.path,
    '..',
    '..',
    'package',
    'ilp_assets',
  ));

  /// 更新ilp游戏资源
  await Process.run(
    'dart ',
    ['build_pubspec.dart'],
    runInShell: true,
    workingDirectory:
        path.join(Directory.current.path, '..', '..', 'package', 'ilp_assets'),
  );

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

  /// 只构建
  final res = await Process.run(
    'flutter',
    [
      'pub',
      'run',
      'msix:build',
    ],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );
  if (res.exitCode != 0) throw res.stderr;

  /// 打包为msix文件
  await Process.run(
    'flutter',
    [
      'pub',
      'run',
      'msix:pack',
    ],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );

  /// 还原资源package
  resetILPAssetsPackagePubspecFile();
  print('成功, 位置$buildPath');
}

final assetsPath = path.join(
  Directory.current.path,
  '..',
  '..',
  'package',
  'ilp_assets',
);
