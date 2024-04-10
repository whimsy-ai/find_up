import 'dart:io';

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
  print('执行flutter clean');
  await Process.run(
    'flutter',
    ['clean'],
    runInShell: true,
    workingDirectory: Directory.current.path,
  );
  print('开始构建Steam版本');
  print('当前文件夹 ${Directory.current.path}');
  final res = await Process.run(
    'flutter',
    [
      'build',
      'windows',
      '--target=./lib/main_steam.dart',
    ],
    runInShell: true,
    includeParentEnvironment: true,
  );
  if (res.exitCode == 0) {
    /// 复制Steam文件到打包目录
    await copyFile('steam_api64.dll', buildPath);
    // await copyFile('./steam_appid.txt', buildPath);
  } else {
    throw res.stderr;
  }

  /// 删除ilp资源文件夹
  Directory(path.join(
    buildPath,
    'data',
    'flutter_assets',
    'packages',
    'ilp_assets',
    'assets',
  )).deleteSync(recursive: true);
  print('成功, 位置$buildPath');
}

Future copyFile(String from, String to) async {
  final fileName = path.basename(from);
  await File(from).copy(path.join(buildPath, fileName));
}
