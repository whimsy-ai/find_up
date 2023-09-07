import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:game/build_flavor.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/global_progress_indicator_dialog.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:steamworks/steamworks.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ui.dart';
import '../../utils/steam_ex.dart';
import '../explorer/steam/steam_file.dart';
import 'ilp_info_file.dart';
import 'steam/steam_tags_dialog.dart';

class Link {
  String name, url;

  Link(this.name, this.url);

  @override
  String toString() => '$name => $url';
}

final eq = ListEquality().equals;

class ILPEditorController extends GetxController {
  final ILP ilp = ILP.fromConfigFiles([]);

  int version = 1;

  late final _configs = RxList<ILPInfoFile>()
    ..listen((p0) async {
      update(['cover', 'layers']);
    });

  List<ILPInfoFile> get configs => _configs;

  late final links = RxList<Link>()
    ..listen((p0) {
      update(['editor']);
    });

  /// 文件封面
  String? _cover;

  bool get hasCover => _cover != null;

  removeCover() {
    _cover = null;
    update(['cover']);
  }

  String name = '';
  String author = env.isSteam
      ? SteamClient.instance.steamFriends.getPersonaName().toDartString()
      : '';
  String _desc = '';

  String? get cover =>
      _cover ??
      _configs
          .firstWhereOrNull((element) => element.config?.cover != null)
          ?.config
          ?.cover;

  set desc(String? val) => _desc = val ?? '';

  String get desc => _desc;

  reorderLink(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    links.insert(newIndex, links.removeAt(oldIndex));
  }

  reorderInfoAndLayer(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    _configs.insert(newIndex, _configs.removeAt(oldIndex));
  }

  final Map<String, String> infoNameCaches = {};

  Future<Uint8List> toBytes() async {
    for (var config in _configs) {
      if (config.config == null) {
        throw ILPConfigException(
          message: '${config.file} ${WindowsUI.ilpEditorFilesNotExist.tr}',
          file: config.file,
        );
      }
      final validate = await config.config!.validate();
      if (!validate) {
        throw ILPConfigException(
          message:
              '${config.config!.name} ${WindowsUI.ilpEditorFilesNotExist.tr}',
          file: config.file,
        );
      }
    }

    /// 强制重新加载所有文件
    ilp.configs.clear();
    ilp.configs.addAll(_configs.map((file) {
      final info = ILPInfoConfig.fromFileSync(file.file);
      if (infoNameCaches.containsKey(file.file)) {
        info.name = infoNameCaches[file.file]!;
      }
      return info;
    }));
    return ilp.toBytes(
      author: author,
      name: name,
      description: desc,
      links: _linksString(),
      coverFilePath: _cover,
      version: version,
    );
  }

  save() async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_v$version.ilp';
    final FileSaveLocation? file =
        await getSaveLocation(suggestedName: fileName, acceptedTypeGroups: [
      XTypeGroup(label: 'ILP', extensions: ['.ilp']),
    ]);
    if (file == null) return;
    Get.dialog(
      AlertDialog(title: Text(UI.saving.tr)),
      barrierDismissible: false,
    );
    late Uint8List bytes;
    try {
      bytes = await toBytes();
    } catch (e) {
      showToast(e.toString());
      return;
    }
    final XFile saveFile = XFile.fromData(bytes, name: fileName);
    await saveFile.saveTo(file.path);
    Get.back();
    _check(bytes, file.path);
  }

  List<String> _linksString() {
    final list = <String>[];
    for (var link in links) {
      list.addAll([link.name, link.url]);
    }
    return list;
  }

  _check(Uint8List bytes, String filePath) async {
    final ilp = await ILP.fromFile(filePath);
    Get.dialog(
      AlertDialog(
        title: Text(WindowsUI.ilpEditorValidatingFile.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 验证文件长度
            _ValidatorListTile(
                name: WindowsUI.ilpEditorFileLength.tr,
                validator: () async {
                  if (bytes.length == await ilp.length) {
                    return WindowsUI.ilpEditorConsistent.tr;
                  }
                  return WindowsUI.ilpEditorInconsistent.tr;
                }),

            /// 验证文件信息
            _ValidatorListTile(
                name: UI.fileInfo.tr,
                validator: () async {
                  final header = await ilp.header;
                  final infoNames =
                      (await this.ilp.infos).map((info) => info.name).toList();
                  final fileInfoNames =
                      (await ilp.infos).map((info) => info.name).toList();
                  if (header.name != name) {
                    return WindowsUI.ilpEditorNameInconsistent.tr;
                  } else if (header.description != desc) {
                    print('desc $desc , header desc ${header.description}');
                    return WindowsUI.ilpEditorDescInconsistent.tr;
                  } else if (header.author != author) {
                    return WindowsUI.ilpEditorAuthorInconsistent.tr;
                  } else if (!eq(_linksString(), header.links)) {
                    return WindowsUI.ilpEditorLinksInconsistent.tr;
                  } else if (!eq(infoNames, fileInfoNames)) {
                    return WindowsUI.ilpEditorImagesInconsistent.tr;
                  } else if (header.version != version) {
                    return WindowsUI.ilpEditorVersionInconsistent.tr;
                  } else {
                    return WindowsUI.ilpEditorConsistent.tr;
                  }
                }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              launchUrlString('file://${path.dirname(filePath)}');
            },
            child: Text(UI.open.tr, style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(UI.ok.tr),
          ),
          ElevatedButton(
            onPressed: () => PageGameEntry.play(ilp),
            child: Text(WindowsUI.playtest.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  editInfoConfig(ILPInfoFile file) async {
    final formKey = GlobalKey<FormState>();
    final info = file.config!;
    String name = infoNameCaches[file.file] ?? info.name;

    check() {
      if (formKey.currentState!.validate()) {
        infoNameCaches[file.file] = name;
        update(['layers']);
        Get.back();
      }
    }

    await Get.dialog<bool>(
      AlertDialog(
        title: Text(WindowsUI.ilpEditorModifyImageName.tr),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(UI.cover.tr),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.file(File(info.cover), height: 100),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                      labelText: WindowsUI.ilpEditorImageName.tr),
                  initialValue: name,
                  onChanged: (v) => name = v,
                  onFieldSubmitted: (v) => check(),
                  validator: (v) {
                    if (v!.isEmpty) return WindowsUI.ilpEditorInputImageName.tr;
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => check(),
            child: Text(UI.modify.tr),
          ),
        ],
      ),
    );
  }

  removeFile(ILPInfoFile file) async {
    final index = configs.indexOf(file);
    if (index == -1) return;
    bool? sure = false;
    if (file.config == null) {
      sure = true;
    } else {
      sure = await Get.dialog<bool>(
        AlertDialog(
          title: Text('${UI.remove} ${file.config!.name} ? '),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.file(File(file.config!.cover), width: 100)],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
            ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: Text(UI.remove.tr)),
          ],
        ),
      );
    }
    if (sure == true) {
      configs.removeAt(index);
    }
  }

  removeLink(Link link) async {
    final sure = await Get.dialog<bool>(
      AlertDialog(
        title: Text('${WindowsUI.ilpEditorRemoveLink.tr} ${link.name}?'),
        content: Text(link.url),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(UI.remove.tr),
          ),
        ],
      ),
    );
    if (sure == true) links.remove(link);
  }

  selectCoverFile() async {
    const XTypeGroup group =
        XTypeGroup(label: 'image', extensions: ['jpg', 'jpeg', 'png']);
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[
      group,
    ]);
    if (file == null) return;
    _cover = file.path;
    update(['cover']);
  }

  selectConfigFiles() async {
    const XTypeGroup group = XTypeGroup(label: 'ilp', extensions: ['json']);
    final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
      group,
    ]);
    if (files.isEmpty) return;
    addConfigFiles(files.map((e) => e.path).toList());
  }

  addConfigFiles(List<String> files) {
    final currentFiles = _configs.map((e) => e.file).toList();
    final exists = <String>[];
    final notJsonFile = <String>[];
    files.toList().forEach((file) {
      if (!file.endsWith('.json')) {
        notJsonFile.add(file);
        files.remove(file);
      }
      if (currentFiles.contains(file)) {
        exists.add(file);
        files.remove(file);
      }
    });
    if (exists.isNotEmpty) {
      showToast(
        [WindowsUI.ilpEditorFileExisted.tr, ...exists].join('\n'),
        duration: Duration(seconds: 5),
      );
    }
    if (files.isEmpty) return;
    _configs.addAll(files.map((e) => ILPInfoFile(e)));
  }

  SteamFile? _steamFile;

  SteamFile? get steamFile => _steamFile;

  set steamFile(SteamFile? value) {
    _steamFile = value;
    name = _steamFile?.name ?? '';
    version = _steamFile?.version ?? 1;
    _desc = _steamFile?.description ?? '';
    update(['editor']);
  }

  uploadToSteam() async {
    final tags = await SteamTagsDialog.show(
      age: _steamFile?.ageRating,
      style: _steamFile?.style,
      shape: _steamFile?.shape,
    );
    if (tags == null) return;
    GlobalProgressIndicatorDialog.show(WindowsUI.steamUploading.tr);
    final bytes = await toBytes();

    final temp = await getTemporaryDirectory();
    final contentFolder = await temp.createTemp();
    final previewFile = File(path.join(temp.path, 'preview.png'));
    await previewFile.writeAsBytes(await ilp.cover);
    final file = File(path.join(contentFolder.path, 'main.ilp'));
    await file.writeAsBytes(bytes);

    final itemId = _steamFile?.id ?? await SteamClient.instance.createItem();
    await SteamClient.instance.updateItem(
      itemId,
      language: ApiLanguage.english,
      title: name,
      description: desc,
      contentFolder: contentFolder.path,
      previewImagePath: previewFile.path,
      tags: tags,
      metaData: jsonEncode(
        {
          'version': version,
          'infos': (await ilp.infos).map((e) {
            final copy = ILPInfo.fromBuffer(e.writeToBuffer());
            copy.clearCover();
            return copy.writeToJson();
          }).toList(),
        },
      ),
    );

    /// hide uploading dialog
    Get.back();
    Get.dialog(
      AlertDialog(
        title: Text(WindowsUI.steamUploadSuccess.tr),
        actions: [
          TextButton(
            onPressed: () {
              SteamClient.instance
                  .openUrl('steam://url/CommunityFilePage/$itemId');
            },
            child: Text(WindowsUI.viewFileInSteam.tr),
          ),
          ElevatedButton(onPressed: () => Get.back(), child: Text(UI.ok.tr)),
        ],
      ),
    );
  }
}

class _ValidatorListTile extends StatelessWidget {
  final String name;
  final Future<String> Function() validator;
  final _result = RxString(WindowsUI.ilpEditorValidating.tr);

  _ValidatorListTile({
    super.key,
    required this.name,
    required this.validator,
  }) {
    validator().then((value) => _result.value = value);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListTile(
        title: Text(name),
        trailing: Text(_result.value),
      );
    });
  }
}
