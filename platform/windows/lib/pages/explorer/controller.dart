import 'dart:io';

import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
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
import '../../utils/steam_tags.dart';

enum ExplorerMode { openFile, selectSteamFile }

final Queue _searchQueue = Queue(parallel: 4);

class ILPExplorerController extends GetxController
    implements IExplorerController {
  final ExplorerMode mode;
  String? search;
  bool loading = false;
  late final _fixedFolders = {
    if (!env.isSteam) (UI.builtIn.tr, 'assets'),
    if (env.isSteam) (UI.steamWorkshop.tr, 'steam'),
  };

  TagStyle? _style;

  TagStyle? get style => _style;

  set style(TagStyle? value) {
    _style = value;
    currentPage = 1;
    update(['editor']);
    reload();
  }

  TagAgeRating? _ageRating = Data.isAdult ? null : TagAgeRating.everyone;

  TagAgeRating? get ageRating => _ageRating;

  set ageRating(TagAgeRating? value) {
    _checkAgeRating(value);
  }

  _checkAgeRating(TagAgeRating? value) async {
    if (value != TagAgeRating.everyone) {
      if (!Data.isAdult) {
        final sure = await Get.dialog<bool>(
          AlertDialog(
            title: Text(UI.adultAgreementTitle.tr),
            content: Text(UI.adultAgreementContent.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(UI.cancel.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(UI.confirm.tr),
              ),
            ],
          ),
        );
        if (sure != true) return;
        Data.isAdult = true;
      }
    }
    _ageRating = value;
    currentPage = 1;
    update(['editor']);
    reload();
  }

  TagShape? _shape;

  TagShape? get shape => _shape;

  set shape(TagShape? value) {
    _shape = value;
    currentPage = 1;
    update(['editor']);
    reload();
  }

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
      subscribed = false;
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

      if (search == null) {
        _files.addAll(files.map((file) => ILPFile(File(file))));
      }

      /// 搜索
      else if (search != null) {
        await _searchQueue.addAll(files.map((file) => () async {
              final ilp = await ILP.fromFile(file);
              final header = await ilp.header;
              if (header.name.toLowerCase().contains(search!.toLowerCase())) {
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

  int currentPage = 1, totalPage = 1;

  /// items amount
  int total = 0;

  /// steam userId
  int? userId;

  bool subscribed = false;

  SteamFileSort sort = SteamFileSort.publishTime;

  Future<void> _loadSteamFiles() async {
    if (currentPage <= 0) currentPage = 1;
    files.clear();
    update(['files']);
    final userId = mode == ExplorerMode.selectSteamFile
        ? SteamClient.instance.userId
        : this.userId;
    final sort = mode == ExplorerMode.selectSteamFile
        ? SteamFileSort.publishTime
        : this.sort;
    final res = await SteamClient.instance.getAllItems(
      page: currentPage,
      userId: userId,
      search: search,
      subscribed: subscribed,
      sort: sort,
      tags: {
        if (_style != null) _style!.value,
        if (_shape != null) _shape!.value,
        if (_ageRating != null) _ageRating!.value,
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
