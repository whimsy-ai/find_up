import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game/bytes_size.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/game/unlock_progress_bar.dart';
import 'package:game/get_ilp_info_unlock.dart';
import 'package:game/info_table.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:steamworks/steamworks.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../ui.dart';
import '../../../utils/steam_ex.dart';
import '../controller.dart';
import 'steam_file.dart';

class SteamFileBottomSheet extends StatefulWidget {
  final SteamFile file;

  const SteamFileBottomSheet._({super.key, required this.file});

  static Future show(SteamFile file) => Get.bottomSheet(
        SteamFileBottomSheet._(file: file),
      );

  @override
  State<SteamFileBottomSheet> createState() => _SteamFileBottomSheetState();
}

class _SteamFileBottomSheetState extends State<SteamFileBottomSheet> {
  late final _voteUp = widget.file.voteUp.obs,
      _voteDown = widget.file.voteDown.obs;

  final _voted = RxnBool();
  final _controller = Get.find<ILPExplorerController>();
  final _ilp = Rxn<ILP>();
  late final _infos = RxList<ILPInfo>(widget.file.infos);

  @override
  void initState() {
    super.initState();
    _getVote();
    _checkState();
  }

  Timer? _check;

  _checkState() async {
    widget.file.load();
    _check = Timer(Duration(milliseconds: 500), _checkState);

    if (widget.file.ilpFile != null && _ilp.value == null) {
      _ilp.value = await ILP.fromFile(widget.file.ilpFile!);
      _infos
        ..clear()
        ..addAll(await _ilp.value!.infos);
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.update([widget.file.id, 'bottomSheet']);
    });
  }

  @override
  void dispose() {
    _check?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GetBuilder<ILPExplorerController>(
        id: 'bottomSheet',
        builder: (controller) => Column(
          children: [
            /// file info title
            ListTile(
              title: Text(UI.fileInfo.tr),
              trailing: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (widget.file.isSubscribed && widget.file.ilpFile != null)
                    ElevatedButton(
                      child: Icon(Icons.play_arrow_rounded),
                      onPressed: () async {
                        await PageGameEntry.play(
                          ILP.fromFileSync(widget.file.ilpFile!),
                        );
                        _controller.update([widget.file.id, 'bottomSheet']);
                      },
                    ),
                  if (widget.file.isSubscribed && widget.file.ilpFile == null)
                    Text(UI.downloading.tr),
                  Obx(
                    () => ElevatedButton.icon(
                      icon: Icon(Icons.thumb_up_rounded),
                      label: Text(_voteUp.value.toString()),
                      onPressed: () => _setVote(true),
                    ),
                  ),
                  Obx(
                    () => ElevatedButton.icon(
                      icon: Icon(Icons.thumb_down_rounded),
                      label: Text(_voteDown.value.toString()),
                      onPressed: () => _setVote(false),
                    ),
                  ),
                  ElevatedButton(
                    child: widget.file.isSubscribed
                        ? Text(WindowsUI.steamUnSubscribe.tr)
                        : Text(WindowsUI.steamSubscribeAndDownload.tr),
                    onPressed: () async {
                      if (widget.file.isSubscribed) {
                        await widget.file.unSubscribe();
                      } else {
                        await widget.file.subscribeAndDownload();
                      }
                      controller.update([widget.file.id, 'bottomSheet']);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  /// tags
                  ListTile(
                    title: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 10,
                        children: [
                          Chip(label: Text(widget.file.style!.value.tr)),
                          Chip(
                              label: Text(
                                  '${WindowsUI.shape.tr}: ${widget.file.shape!.value.tr}')),
                          Chip(
                              label: Text(
                                  '${WindowsUI.ageRating.tr}: ${widget.file.ageRating!.value.tr}')),
                        ],
                      ),
                    ),
                  ),

                  /// 主题
                  ListTile(
                    title: Text(UI.ilpName.tr),
                    subtitle: Text(widget.file.name),
                  ),

                  /// 打开作者的Steam页面
                  ListTile(
                    title: Text(WindowsUI.steamAuthorInfo.tr),
                    subtitle: Text(WindowsUI.openInSteam.tr),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      SteamClient.instance.openUrl(
                          'steam://url/SteamIDPage/${widget.file.steamIdOwner}');
                    },
                  ),

                  /// 在steam打开这个文件页面
                  ListTile(
                    title: Text(WindowsUI.openInSteam.tr),
                    subtitle: Text(WindowsUI.openInSteam.tr),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      SteamClient.instance.openUrl(
                          'steam://url/CommunityFilePage/${widget.file.id}');
                    },
                  ),

                  /// 作者其它文件
                  ListTile(
                    title: Text(WindowsUI.steamAuthorOtherFiles.tr),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Get.back();
                      controller.userId = widget.file.steamIdOwner;
                      controller.currentPage = 1;
                      controller.reload();
                    },
                  ),

                  /// version
                  ListTile(
                    title: Text(UI.ilpVersion.tr),
                    subtitle: Text(widget.file.version.toString()),
                  ),

                  /// desc
                  ListTile(
                    title: Text(UI.ilpDesc.tr),
                    subtitle: Text(widget.file.description?.isNotEmpty == true
                        ? widget.file.description!
                        : UI.empty.tr),
                  ),

                  /// desc
                  ListTile(
                    title: Text(WindowsUI.fileSize.tr),
                    subtitle: Text(bytesSize(widget.file.fileSize, 2)),
                  ),

                  /// image length
                  ListTile(
                    title: Text(
                      UI.imageLengthStr
                          .trArgs([widget.file.infos.length.toString()]),
                    ),
                  ),
                  _infoList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final ugc = SteamClient.instance.steamUgc;

  _setVote(bool up) {
    final ugc = SteamClient.instance.steamUgc;
    SteamClient.instance.registerCallResult<SetUserItemVoteResult>(
      asyncCallId: ugc.setUserItemVote(widget.file.id, up),
      cb: (res, failed) {
        print('setVote $up ${res.result}');
        if (res.result == EResult.eResultOK) {
          final voted = _voted.value;
          if (voted == null) {
            up ? _voteUp.value++ : _voteDown.value++;
          } else {
            if (voted && !up) {
              _voteUp.value--;
              _voteDown.value++;
            } else if (!voted && up) {
              _voteUp.value++;
              _voteDown.value--;
            }
          }
          _voted.value = up;
        }
      },
    );
  }

  Future<EResult> _getVote() async {
    final completer = Completer<EResult>();
    SteamClient.instance.registerCallResult<GetUserItemVoteResult>(
      asyncCallId: ugc.getUserItemVote(widget.file.id),
      cb: (res, failed) {
        if (res.result == EResult.eResultOK) {
          if (res.votedUp) {
            _voted.value = true;
          } else if (res.votedDown) {
            _voted.value = false;
          }
        }
        print('getVote ${_voted.value}');
        completer.complete(res.result);
      },
    );
    return completer.future;
  }

  Widget _infoList() {
    return Obx(
      () {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _infos.length,
          itemBuilder: (_, i) {
            final info = _infos[i];
            return ListTile(
              leading: info.hasCover()
                  ? Image.memory(info.cover as Uint8List)
                  : null,
              title: Text(info.name),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoTable(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    rows: [
                      (UI.resolution.tr, '${info.width} x ${info.height}'),
                      (UI.layerCount.tr, info.contentLayerIdList.length),
                    ],
                  ),
                  UnlockProgressBar(
                    width: 300,
                    text: UI.unlock.tr,
                    value: getIlpInfoUnlock(info),
                  ),
                ],
              ),
              trailing: _ilp.value == null
                  ? null
                  : Wrap(
                      spacing: 10,
                      children: [
                        TextButton(
                          onPressed: () => PageGameEntry.play(
                            _ilp.value!,
                            index: i,
                          ),
                          child: Icon(Icons.play_arrow_rounded),
                        ),
                        TextButton(
                          child: Icon(Icons.save_outlined),
                          onPressed: () async {
                            Get.toNamed('/save', arguments: {
                              'info': info,
                              'layer': await _ilp.value!.layer(i),
                            });
                          },
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
