import 'dart:io';

import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
import 'package:file_selector/file_selector.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/explorer/file.dart';
import 'package:game/explorer/i_controller.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;
import 'package:steamworks/steamworks.dart';

import '../../utils/asset_path.dart';
import '../../utils/steam_ex.dart';
import '../../utils/steam_file_ex.dart';
import '../../utils/steam_filter.dart';
import '../../utils/steam_tags.dart';

enum ExplorerMode { openFile, selectSteamFile }

final Queue _searchQueue = Queue(parallel: 4);

class ILPExplorerController extends SteamFilterController
    implements IExplorerController {
  final ExplorerMode mode;
  late final _fixedFolders = {
    if (!env.isSteam) (UI.builtIn.tr, 'assets'),
    if (env.isSteam) (UI.steamWorkshop.tr, 'steam'),
  };

  @override
  List<(String, String)> get folders => _folders.toList();
  late final _folders = <(String, String)>{..._fixedFolders};

  @override
  List<ExplorerFile> get files => _files;
  final _files = <ExplorerFile>[];

  @override
  int get currentFolder => _currentFolder;
  int _currentFolder = 0;

  ILPExplorerController(
    this.mode, {
    super.multipleSelect = false,
  }) {
    _folders.addAll(Data.folders.map((e) => (path.basename(e), e)));

    /// Steam版本, 0就是Steam创意工坊
    /// 微软商店版本，0就是内置的游戏内容
    openFolder(0);
    print('ageRatings $ageRatings');
  }

  @override
  void onChanged() {
    reload();
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
    _searchQueue.clear();
    loading = true;
    update(['folders', 'files']);
    var folder = _folders.elementAt(index);
    var folderPath = folder.$2;
    _files.clear();
    _currentFolder = index;
    if (folderPath == 'steam') {
      await _loadSteamFiles();
    } else {
      Iterable<String> files;
      if (folderPath == 'assets') {
        folderPath = assetPath(package: 'game', paths: ['ilp']);
        files = _loadAssets();
      } else {
        final dir = Directory(folderPath);
        if (!await dir.exists()) {
          showToast(UI.folderNotExists.trArgs([folderPath]));
          return;
        }
        files = dir.listSync(recursive: true).map((e) => e.path);
      }

      /// 过滤ilp后缀
      files = files.where((element) => element.endsWith('.ilp'));
      // print('asset $path');

      if (search.isEmpty) {
        _files.addAll(files.map((file) => ILPFile(File(file))));
      }

      /// 搜索
      else {
        await _searchQueue.addAll(files.map((file) => () async {
              final ilp = await ILP.fromFile(file);
              final header = await ilp.header;
              if (header.name.toLowerCase().contains(search.toLowerCase())) {
                _files.add(ILPFile(File(file)));
              }
              update(['files']);
            }));
      }
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

  /// items amount
  int total = 0;

  Future<void> _loadSteamFiles() async {
    files.clear();
    update(['files']);
    final userId = mode == ExplorerMode.selectSteamFile
        ? SteamClient.instance.userId
        : this.userId;
    final sort = mode == ExplorerMode.selectSteamFile
        ? SteamUGCSort.publishTime
        : this.sort;
    final res = await SteamClient.instance.getAllItems(
      type: TagType.file,
      page: page,
      userId: userId,
      search: search,
      subscribed: subscribed,
      sort: sort,
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

Iterable<String> _loadAssets() {
  return Directory(assetPath(package: 'ilp_assets'))
      .listSync(recursive: true)
      .reversed
      .map((file) => file.path);
}
