import 'dart:io';

import 'package:yaml_edit/yaml_edit.dart';

void main() {
  final target = File('pubspec.yaml');
  final editor = YamlEditor(target.readAsStringSync());
  final folder = Directory('assets');
  final files = folder.listSync(recursive: true);
  final folders = files
      .whereType<Directory>()
      .map((e) => e.path.replaceAll('\\', '/') + '/')
      .toList()
    ..sort();
  editor.update(['flutter', 'assets'], folders.toList());
  target.writeAsString(editor.toString());
  stdout.writeln('ilp files length: ${folders.length}');
}
