import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Future<Map<String, Set<String>>> languagesMap() async {
  final languages =
      await trans(['-list-all']).then((value) => value.split('\n'));

  // final languages =
  //     File('../py_translate/list.txt').readAsStringSync().split('\n');

  // print('languages: ${languages.length}');
  final res = <String, Set<String>>{};
  for (var line in languages) {
    line = line.trim();
    if (line.isEmpty) continue;
    var list = line.split(RegExp('\\s{2,}'));
    res[list.first] = {list[1], list[2]};
  }
  return res;
}

Future<String> translate(String text, {
  required String sourceLanguage,
  required String targetLanguage,
  engine = 'google',
  timeoutSeconds = 14,
}) =>
    trans([
      '-b',
      '-e',
      engine,
      '$sourceLanguage:$targetLanguage',
      '-j',
      text,
    ], timeoutSeconds);

Future<String> trans(List<String> command, [int timeoutSeconds = 14]) {
  print('command: wsl /home/trans ${command.join(' ')}');
  return Process.run(
    'wsl',
    ['/home/trans', ...command],
    runInShell: true,
    stdoutEncoding: utf8,
  ).timeout(Duration(seconds: timeoutSeconds)).then((res) {
    return res.stdout.trim();
  });
}

String toMD5(String input) => md5.convert(utf8.encode(input)).toString();
