import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/i_controller.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:game/explorer/layout.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;
import 'package:steamworks/steamworks.dart';

import '../../ui.dart';
import '../../utils/asset_path.dart';
import '../../utils/steam_ex.dart';
import '../../utils/steam_tags.dart';

enum ExplorerMode { openFile, selectSteamFile }

class ILPExplorerController extends GetxController
    implements IExplorerController {
  final ExplorerMode mode;
  String? search;
  bool loading = false;
  late final _fixedFolders = {
    (UI.builtIn.tr, 'assets'),
    if (env.isSteam) (WindowsUI.steamWorkshop.tr, 'steam'),
  };

  TagStyle? _style;
  TagAgeRating? _ageRating;
  TagShape? _shape;


  TagStyle? get style => _style;

  set style(TagStyle? value) {
    _style = value;
    currentPage = 1;
    update(['editor']);
    reload();
  }

  TagAgeRating? get ageRating => _ageRating;

  set ageRating(TagAgeRating? value) {
    _ageRating = value;

    currentPage = 1;
    update(['editor']);
    reload();
  }

  TagShape? get shape => _shape;

  set shape(TagShape? value) {
    _shape = value;
    currentPage = 1;
    update(['editor']);
    reload();
  }

  @override
  ExplorerLayout get layout => _layout;

  set layout(ExplorerLayout val) {
    _layout = val;
    Data.explorerListMode = val == ExplorerLayout.list;
    update(['files']);
  }

  ExplorerLayout _layout =
      Data.explorerListMode ? ExplorerLayout.list : ExplorerLayout.grid;

  @override
  List<(String, String)> get folders => _folders.toList();
  late final _folders = <(String, String)>{..._fixedFolders};

  @override
  List<ExplorerFile> get files => _files;
  final _files = <ExplorerFile>[];

  @override
  int get currentFolder => _currentFolder;
  int _currentFolder = 0;

  ILPExplorerController(this.mode) {
    _folders.addAll(Data.folders.map((e) => (path.basename(e), e)));
    openFolder(mode == ExplorerMode.openFile ? 0 : 1);
  }

  bool isFixedFolder((String, String) dir) => _fixedFolders.contains(dir);

  addFolder() async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) return;
    final dir = (path.basename(directoryPath), directoryPath);
    if (_folders.contains(dir)) {
      return;
    }
    _folders.add(dir);
    Data.folders.add(directoryPath);
    openFolder(_folders.length - 1);
  }

  @override
  String get currentPath => _folders.elementAt(currentFolder).$2;

  @override
  Future<void> openFolder(int index) async {
    if (loading) return;
    loading = true;
    update(['folders', 'files']);
    var folder = _folders.elementAt(index);
    var folderPath = folder.$2;
    _files.clear();
    _currentFolder = index;
    if (folderPath == 'steam') {
      await _loadSteamFiles();
    } else {
      subscribed = false;
      if (folderPath == 'assets') {
        folderPath = assetPath(package: 'game', paths: ['ilp']);
      }
      // print('asset $path');
      final dir = Directory(folderPath);
      if (!await dir.exists()) {
        showToast(UI.folderNotExists.trArgs([folderPath]));
        return;
      }
      final files = dir.listSync(recursive: false).where((file) {
        var filter = true;

        if (search != null) {
          filter = path.basenameWithoutExtension(file.path).contains(search!);
        }
        return filter && file.path.endsWith('.ilp');
      });
      _files.addAll(files.map((file) => ILPFile(File(file.path))));
    }
    loading = false;
    update(['folders', 'files']);
  }

  removeFolder((String, String) folder) {
    final index = _folders.toList().indexOf(folder);
    _folders.remove(folder);
    Data.folders.remove(folder.$2);
    if (index == currentFolder) {
      openFolder(0);
    } else {
      update(['folders']);
    }
  }

  @override
  reload() {
    openFolder(_currentFolder);
  }

  int currentPage = 1, totalPage = 1;

  /// items amount
  int total = 0;

  /// steam userId
  int? userId;

  bool subscribed = false;

  /// 0 = update, 1 = vote
  int voteType = 0;

  Future<void> _loadSteamFiles() async {
    if (currentPage <= 0) currentPage = 1;
    files.clear();
    update(['files']);
    final res = await SteamClient.instance.getAllItems(
      page: currentPage,
      userId: userId,
      search: search,
      subscribed: subscribed,
      voteType: voteType,
      tags: {
        if (style != null) style!.value,
        if (shape != null) shape!.value,
        if (ageRating != null) ageRating!.value,
      },
    );
    if (res.result == EResult.eResultOK) {
      totalPage = (res.total / 50).ceil();
      files.addAll(res.files);
    }
  }
}
