import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../bytes_size.dart';
import '../game/unlock_progress_bar.dart';
import '../info_table.dart';
import 'file.dart';
import 'ilp_file.dart';

class ILPInfoBottomSheet extends StatelessWidget {
  final ExplorerFile file;
  final ILP ilp;
  final ILPInfo? currentInfo;
  final RxList<Widget> _children = RxList();
  final Rxn<ILPHeader> _header = Rxn();

  final void Function(int)? onTapPlay;

  ILPInfoBottomSheet._({
    required this.ilp,
    required this.file,
    required this.onTapPlay,
    this.currentInfo,
  }) {
    ilp.header.then((header) {
      final links = <(String, String)>[];
      for (var i = 0; i < header.links.length; i += 2) {
        links.add((header.links[i], header.links[i + 1]));
      }
      _children.addAll([
        ListTile(
          title: Text(UI.ilpName.tr),
          subtitle: Text(header.hasName() ? header.name : UI.empty.tr),
        ),
        ListTile(
          title: Text(UI.ilpAuthor.tr),
          subtitle: Text(header.hasAuthor() ? header.author : UI.empty.tr),
        ),
        ListTile(
          title: Text(UI.ilpVersion.tr),
          subtitle: Text(header.version.toString()),
        ),
        ListTile(
          title: Text(UI.ilpDesc.tr),
          subtitle: Text(
            header.description.isNotEmpty ? header.description : UI.empty.tr,
          ),
        ),
        if (file is ILPFile)
          ListTile(
            title: Text(UI.path.tr),
            subtitle: Text((file as ILPFile).file.path),
          ),
        ListTile(
          title: Text(UI.fileSize.tr),
          subtitle: Text(bytesSize(file.fileSize, 2)),
        ),
        ListTile(
          title: Text(UI.link.tr),
          subtitle: header.links.isEmpty
              ? Text(UI.empty.tr)
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: links
                      .map(
                        (link) => TextButton(
                          onPressed: () => launchUrlString(link.$2),
                          child: Text(link.$1),
                        ),
                      )
                      .toList(),
                ),
        ),
        ListTile(
          title: Text(
            UI.imageLengthStr.trArgs([header.infoList.length.toString()]),
          ),
        ),
      ]);
      return ilp.header;
    }).then((header) {
      _header.value = header;
    });
  }

  static Future show({
    required ExplorerFile file,
    required ILP ilp,
    void Function(int)? onTapPlay,
    ILPInfo? currentInfo,
  }) =>
      Get.bottomSheet(
        ILPInfoBottomSheet._(
          ilp: ilp,
          file: file,
          currentInfo: currentInfo,
          onTapPlay: onTapPlay,
        ),
        backgroundColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) => Obx(
        () => Column(
          children: [
            ListTile(title: Text(UI.fileInfo.tr)),
            Expanded(
              child: ListView(
                children: [
                  ..._children,
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _header.value?.infoList.length ?? 0,
                    itemBuilder: (_, i) => _InfoListTile(
                      file: file,
                      ilp: ilp,
                      index: i,
                      onTapPlay: onTapPlay,
                      currentInfoId: currentInfo?.id,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _InfoListTile extends StatelessWidget {
  final ExplorerFile? file;
  final ILP ilp;
  final int index;
  final String? currentInfoId;
  final void Function(int)? onTapPlay;
  final _info = Rxn<ILPInfo>();

  _InfoListTile({
    super.key,
    required this.file,
    required this.ilp,
    required this.index,
    this.onTapPlay,
    this.currentInfoId,
  }) {
    ilp.info(index).then((value) => _info.value = value);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final info = _info.value;
      if (info == null) {
        return ListTile(
          title: Text(UI.loading.tr),
        );
      }
      final selected = currentInfoId == info.id;
      return ListTile(
        selected: selected,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        leading: Image.memory(info.cover as Uint8List, width: 100),
        visualDensity: VisualDensity(vertical: 4),
        title: Text(
          info.name.isNotEmpty ? info.name : '${UI.image.tr} ${index + 1}',
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoTable(
              rows: [
                (
                  UI.resolution.tr,
                  '${_info.value!.width} x ${_info.value!.height}'
                ),
                (UI.layerCount.tr, _info.value!.contentLayerIdList.length),
              ],
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            UnlockProgressBar.byILPInfo(
              _info.value!,
              width: 200,
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 10,
          children: [
            if (onTapPlay != null)
              TextButton(
                  onPressed: () => onTapPlay!(index),
                  child: Icon(Icons.play_arrow_rounded)),
            TextButton(
              child: Icon(Icons.save_outlined),
              onPressed: () async {
                Get.toNamed('/save', arguments: {
                  'file': file,
                  'index': index,
                });
              },
            ),
          ],
        ),
      );
    });
  }
}
