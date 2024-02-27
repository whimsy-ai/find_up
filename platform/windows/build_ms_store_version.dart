import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml_edit/yaml_edit.dart';

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

  await _updateILPAssetsPubspec();

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
  await _resetILPAssetsPubspec();
  print('成功, 位置$buildPath');
}

final assetsPath = path.join(
  Directory.current.path,
  '..',
  '..',
  'package',
  'ilp_assets',
);
final ilpAssetsPackagePubspecFile = File(path.join(assetsPath, 'pubspec.yaml'));
final ilpAssetsPackageAssetsFolder = Directory(path.join(assetsPath, 'assets'));

String _oldPubspec = '';

Future<void> _updateILPAssetsPubspec() async {
  _oldPubspec = await ilpAssetsPackagePubspecFile.readAsString();
  final editor = YamlEditor(ilpAssetsPackagePubspecFile.readAsStringSync());
  final files = ilpAssetsPackageAssetsFolder.listSync(recursive: true);
  final folders = files
      .whereType<Directory>()
      .map((e) =>
          '${path.relative(e.path, from: assetsPath).replaceAll('\\', '/')}/')
      .toList()
    ..sort();
  editor.update(['flutter', 'assets'], folders.toList());
  ilpAssetsPackagePubspecFile.writeAsString(editor.toString());
  stdout.writeln('ilp files length: ${folders.length}');
}

Future<void> _resetILPAssetsPubspec() async {
  print('原始内容 $_oldPubspec');
  await ilpAssetsPackagePubspecFile.writeAsString(_oldPubspec);
}
