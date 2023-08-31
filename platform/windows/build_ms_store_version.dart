import 'dart:io';

import 'package:path/path.dart' as path;

final buildPath = path.join(
  Directory.current.path,
  'build',
  'windows',
  'runner',
  'Release',
);

void main() async {
  print('开始构建微软商店版本');
  print('当前文件夹 ${Directory.current.path}');

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
  print('成功, 位置$buildPath');
}
