import 'package:dio/dio.dart';

Future<Map<String, Map<String, String>>> getLanguages() async {
  final res =
      await Dio().get<String>('https://www.deepl.com/translator-mobile');

  var reg = RegExp(
    r"selectLang_source_(.+?)'] = '(.+?)'",
    multiLine: true,
    dotAll: true,
    caseSensitive: false,
  );
  final source = Map<String, String>.fromIterable(reg.allMatches(res.data!),
      key: (e) => e.group(2), value: (e) => e.group(1));
  reg = RegExp(
    r"selectLang_target_(.+?)'] = '(.+?)'",
    multiLine: true,
    dotAll: true,
    caseSensitive: false,
  );
  final target = Map<String, String>.fromIterable(reg.allMatches(res.data!).where((e) => !(e.group(1)!.contains('-'))),
      key: (e) => e.group(2), value: (e) => e.group(1));
  return {'source': source, 'target': target};
}
