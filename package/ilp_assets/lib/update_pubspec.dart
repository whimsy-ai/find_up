import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml_edit/yaml_edit.dart';

String _oldPubspec = '';

Future<Completer<void>> updateILPAssetsPubspec(String assetsPath) async {
  final ilpAssetsPackagePubspecFile =
      File(path.join(assetsPath, 'pubspec.yaml'));
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
  final completer = Completer();
  completer.future.then((value) {
    ilpAssetsPackagePubspecFile.writeAsStringSync(_oldPubspec);
  });
  return completer;
}
