import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:interact/interact.dart';

import 'bin/deepl_translator.dart';

void main(List<String> arguments) async {
  stdout.writeln('Getting the DeepL language list');
  await DeepLTranslator.init();
  final parser = ArgParser()
    ..addOption('source', abbr: 's')
    ..addOption('target', abbr: 't');
  final argResults = parser.parse(arguments);

  final translator = DeepLTranslator();

  await translator.setLanguage('zh', 'fr');
  print(await translator.translate('中文\n\n\n1234567890'));
  await translator.close();
  exit(0);
}

String _selectLanguage({
  String? select,
  required Map<String, String> languages,
  required String prompt,
}) {
  if (select != null) {
    if (languages.containsKey(select)) {
      select = languages[select];
    }

    if (!languages.containsValue(select)) {
      select = null;
    }
  }
  if (select == null) {
    select = languages[languages.keys.elementAt(Select(
      prompt: prompt,
      options: languages.keys.toList(),
    ).interact())];
  }
  return select!;
}

Stream<String> _stdinLineStreamBroadcaster =
    stdin.transform(utf8.decoder).transform(LineSplitter()).asBroadcastStream();

Future<String> readStdinLine() async {
  var lineCompleter = Completer<String>();

  var listener = _stdinLineStreamBroadcaster.listen((line) {
    if (!lineCompleter.isCompleted) {
      lineCompleter.complete(line);
    }
  });

  return lineCompleter.future.then((line) {
    listener.cancel();
    return line;
  });
}
