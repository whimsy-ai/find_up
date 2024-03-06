import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml_edit/yaml_edit.dart';

late String _assetsPath;
String _oldPubspec = '';

Future<void> updateILPAssetsPubspec(String assetsPath) async {
  _assetsPath = path.join(assetsPath, 'pubspec.yaml');
  final ilpAssetsPackagePubspecFile = File(_assetsPath);
  final ilpAssetsPackageAssetsFolder =
      Directory(path.join(assetsPath, 'assets'));

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

void resetILPAssetsPackagePubspecFile() {
  File(_assetsPath).writeAsStringSync(_oldPubspec);
}
