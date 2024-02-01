import 'dart:ui';

import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _layersKey = 'layers';
const _foldersKey = 'folders';
const _showILPEditorTipKey = 'show_ilp_editor_tip';
const _steamFilterKey = 'steam_filter';
const _localeKey = 'locale';
const _adultKey = 'adult';

/// for v1.0.17+
const _gameHelperKey = 'game_helper_v1.0.17';

abstract class Data {
  static late SharedPreferences _core;

  static SharedPreferences get core => _core;

  static final _layers = RxSet<String>();
  static final _folders = RxSet<String>();

  static bool _showILPEditorTip = true;

  static bool get showILPEditorTip => _showILPEditorTip;

  static set showILPEditorTip(bool val) {
    _showILPEditorTip = val;
    _signAndSave();
  }

  static bool _gameHelper = false;

  static bool get showGameHelper => _gameHelper;

  static set showGameHelper(bool value) {
    _gameHelper = value;
    _signAndSave();
  }

  static bool _isAdult = false;

  static bool get isAdult => _isAdult;

  static set isAdult(bool value) {
    _isAdult = value;
    _signAndSave();
  }

  static Future init() async {
    print('存储路径 ${(await getApplicationSupportDirectory()).path}');
    _core = await SharedPreferences.getInstance();
    if (_core.containsKey(_layersKey)) {
      _layers.addAll(_core.getStringList(_layersKey)!);
    }
    if (_core.containsKey(_foldersKey)) {
      _folders.addAll(_core.getStringList(_foldersKey)!);
    }
    if (_core.containsKey(_steamFilterKey)) {
      _steamFilter.addAll(_core.getStringList(_steamFilterKey)!);
    }
    _showILPEditorTip = _core.getBool(_showILPEditorTipKey) ?? true;
    _gameHelper = _core.getBool(_gameHelperKey) ?? true;
    _isAdult = _core.getBool(_adultKey) ?? false;
    _layers.listen(_rxListener);
    _folders.listen(_rxListener);
  }

  static Set<String> get layersId => _layers;

  static Set<String> get folders => _folders;

  static Future<void> reset() async {
    _layers.clear();
    _folders.clear();
    _steamFilter.clear();
    _showILPEditorTip = true;
    _gameHelper = true;
    _isAdult = false;
    await _core.clear();
  }

  static _rxListener(_) {
    _signAndSave();
  }

  static String _getSign(Map map) {
    final sortedKey = map.keys.toList()..sort();
    return sortedKey.map((e) {
      return switch (map[e]) {
        Iterable => (map[e] as Iterable).join('_'),
        _ => map[e].toString(),
      };
    }).join('_');
  }

  static _signAndSave() {
    _core.setStringList(_layersKey, _layers.toList());
    _core.setStringList(_foldersKey, _folders.toList());
    _core.setStringList(_steamFilterKey, _steamFilter.toList());
    _core.setBool(_showILPEditorTipKey, _showILPEditorTip);
    _core.setBool(_gameHelperKey, _gameHelper);
    _core.setBool(_adultKey, _isAdult);
  }

  static Locale get locale {
    final locale = Data.core.getString(_localeKey);
    print('语言 $locale');
    if (locale != null && UI.languages.keys.contains(locale)) {
      return Locale(locale);
    }
    return Get.deviceLocale!;
  }

  static set localeString(String locale) =>
      Data.core.setString(_localeKey, locale);

  static Set<String> _steamFilter = {};

  static set steamFilter(Set<String> filter) {
    _steamFilter = filter;
    Data.core.setStringList(_steamFilterKey, filter.toList());
  }

  static Set<String> get steamFilter => _steamFilter;
}
