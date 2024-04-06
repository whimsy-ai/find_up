import 'dart:io';

import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
import 'package:vdf/vdf.dart';

import 'bin/core.dart';

const schinese = '简体中文', tchinese = '繁體中文', latam = 'Latina';

final q = Queue(parallel: 10);

void main(List<String> args) async {
  var file = File('2550370_loc_all.vdf');
  final vdf = vdfDecode(await file.readAsString());
  final sourceLanguages = List<String>.from(vdf['lang'].keys);
  final chinese = Map<String, String>.from(vdf['lang']['schinese']['Tokens']);
  print('chinese $chinese');
  // print('source languages: $sourceLanguages');
  final targetLanguages = await languagesMap();
  // print('target languages $targetLanguages');
  for (var source in sourceLanguages) {
    var sourceLanguage = source;
    if (sourceLanguage == 'schinese') {
      continue;
    } else if (sourceLanguage == 'tchinese') {
      sourceLanguage = tchinese;
    } else if (sourceLanguage == 'latam') {
      sourceLanguage = latam;
    }
    String? targetLanguage;
    for (var languageCode in targetLanguages.keys) {
      final list = targetLanguages[languageCode]!.map((e) => e.toLowerCase());
      var sl = sourceLanguage.toLowerCase();
      for (var value in list) {
        if (value.contains(sl)) {
          targetLanguage = languageCode;
          break;
        }
      }
    }
    if (targetLanguage == null) throw Exception('缺少$sourceLanguage');
    var data = vdf['lang'][source]['Tokens'];
    chinese.forEach((key, value) {
      q.add(()async{
        data[key] = await translate(
          value,
          sourceLanguage: 'zh-CN',
          targetLanguage: targetLanguage!,
        ).then((value) {
          final l = value.split('');
          if (l.first == '"') l.removeAt(0);
          if (l.last == '"') l.removeLast();
          l[0] = l[0].toUpperCase();
          return l.join();
        });
      });
    });
  }
  await q.whenComplete();
  await file.writeAsString(vdfEncode(vdf));
}
