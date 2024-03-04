import 'dart:convert';
import 'dart:io';

final _file = 'caches.json';

final Map<String, String> _data = {};

Future writeCaches() async {
  print('写入缓存数量 ${_data.length}');
  final txt = JsonEncoder.withIndent('  ').convert(_data);
  return File(_file).writeAsString(txt);
}

Future<Map<String, String>> readCaches() async {
  final file = File(_file);
  final exists = await file.exists();
  if (exists) {
    final str = await file.readAsString();
    try {
      _data.addAll(Map.from(jsonDecode(str)));
    } catch (e) {
      // TODO
    }
  }
  return _data;
}
