import 'dart:async';
import 'dart:io';

import 'package:puppeteer/puppeteer.dart' as puppeteer;

import 'languages.dart';
import 'translator.dart';

class DeepLTranslator extends Translator {
  static final Map<String, String> sourceLanguages = {}, targetLanguages = {};
  puppeteer.Browser? browser;

  static int _maxTranslateCount = 1000;
  int _translateCount = 0;

  static Future<void> init([int maxTranslateCount = 1000]) async {
    _maxTranslateCount = maxTranslateCount;
    final languages = await getLanguages();
    sourceLanguages
      ..clear()
      ..addAll(languages['source']!);
    targetLanguages
      ..clear()
      ..addAll(languages['target']!);
  }

  String? _sourceLanguage, _targetLanguage;

  Future<void> setLanguage(String source, String target) async {
    if (sourceLanguages.isEmpty) {
      throw Exception('Init first');
    }
    _translateCount = 0;

    if (sourceLanguages.containsKey(source)) {
      _sourceLanguage = sourceLanguages[source];
    } else if (sourceLanguages.containsValue(source)) {
      _sourceLanguage = source;
    }
    if (_sourceLanguage == null) {
      throw Exception(
          'Not found: $source, source languages list: $sourceLanguages');
    }

    if (targetLanguages.containsKey(target)) {
      _targetLanguage = targetLanguages[target];
    } else if (targetLanguages.containsValue(target)) {
      _targetLanguage = target;
    }
    if (_targetLanguage == null) {
      throw Exception(
          'Not found: $target, target languages list: $targetLanguages');
    }
  }

  Future<String> translate(String txt) async {
    if (_sourceLanguage == null) {
      throw Exception('Set language first');
    }
    if (_translateCount > _maxTranslateCount) {
      await closeBrowser();
      _translateCount = 0;
    }
    final page = await getPage();
    await page.emulate(puppeteer.puppeteer.devices.iPhoneXR);

    final wait = Completer<String>();
    late StreamSubscription stream;
    stream = await page.onRequestFinished.listen((req) async {
      if (req.url.contains('LMT_handle_jobs') &&
          req.method.toLowerCase() == 'post') {
        await stream.cancel();
        wait.complete(_parseResult(await req.response!.json));
      }
    });
    final url =
        'https://www.deepl.com/translator-mobile#$_sourceLanguage/$_targetLanguage/${Uri.encodeComponent(txt)}';
    stdout.writeln('Opening $url');
    await page.goto(url, wait: puppeteer.Until.networkAlmostIdle);
    _translateCount += txt.length;

    return wait.future;
  }

  String _parseResult(Map data) {
    final list = data['result']['translations'] as List<dynamic>;
    return list.map((e) => e['beams'][0]['sentences'][0]['text']).join('\n');
  }

  Future<void> close() async {
    await closeBrowser();
  }
}
