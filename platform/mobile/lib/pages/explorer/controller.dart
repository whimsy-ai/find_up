import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/i_controller.dart';
import 'package:game/explorer/layout.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import 'asset_ilp_file.dart';

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

  @override
  ExplorerLayout get layout => _layout;

  ExplorerController() {
    openFolder(0);
  }

  set layout(ExplorerLayout val) {
    _layout = val;
    Data.explorerListMode = val == ExplorerLayout.list;
    update(['files']);
  }

  ExplorerLayout _layout =
      Data.explorerListMode ? ExplorerLayout.list : ExplorerLayout.grid;

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
          if (env.isProd) if (file.contains('test.ilp')) return;
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

  String getDeviceType() {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  }
}
