import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:game/explorer/asset_ilp_file.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/i_controller.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

class ExplorerController extends GetxController implements IExplorerController {
  late final _fixedFolders = {
    (UI.builtIn.tr, 'assets'),
  };

  late final _folders = <(String, String)>{..._fixedFolders};

  @override
  List<(String, String)> get folders => _folders.toList();
  final _files = RxList<ExplorerFile>();

  late int _currentFolder;

  @override
  int get currentFolder => _currentFolder;

  late String _currentPath;

  @override
  String get currentPath => _currentPath;

  ExplorerController() {
    openFolder(0);
  }

  @override
  openFolder(int index) async {
    _currentFolder = index;
    _currentPath = _folders.elementAt(index).$2;

    _files.clear();
    if (_currentPath == 'assets') {
      final Map<String, dynamic> assets =
          jsonDecode(await rootBundle.loadString('AssetManifest.json'));
      assets.forEach((key, value) {
        if (key.endsWith('.ilp')) {
          final String file = value.first;
          // print('file $file');
          if (kDebugMode) if (file.contains('test.ilp')) return;
          _files.add(AssetILPFile(value.first));
        }
      });
    }
    update(['folder', 'files']);
  }

  @override
  reload() => openFolder(_currentFolder);

  @override
  List<ExplorerFile> get files => _files;
}
