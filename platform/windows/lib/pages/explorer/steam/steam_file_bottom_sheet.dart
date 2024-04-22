import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/bytes_size.dart';
import 'package:game/core.dart';
import 'package:game/data.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/game/unlock_progress_bar.dart';
import 'package:game/get_ilp_info_unlock.dart';
import 'package:game/info_table.dart';
import 'package:game/save_image/page_save_image_entry.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:steamworks/steamworks.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/datetime_format.dart';
import '../../../utils/steam_ex.dart';
import '../../../utils/steam_filter.dart';
import '../../../utils/steam_tags.dart';
import 'steam_file.dart';

class SteamFileBottomSheet<T extends SteamFilterController>
    extends StatefulWidget {
  final SteamFile file;
  final String? tag;

  const SteamFileBottomSheet({
    super.key,
    required this.file,
    this.tag,
  });

  static Future show<T extends SteamFilterController>(
    SteamFile file, {
    String? tag,
  }) {
    return showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SteamFileBottomSheet<T>(
        file: file,
        tag: tag,
      ),
    );
  }

  @override
  State<SteamFileBottomSheet> createState() => _SteamFileBottomSheetState<T>();
}

class _SteamFileBottomSheetState<T extends SteamFilterController>
    extends State<SteamFileBottomSheet<T>> {
  late final _voteUp = widget.file.voteUp.obs,
      _voteDown = widget.file.voteDown.obs;

  final _voted = RxnBool();
  late final _controller = Get.find<T>(tag: widget.tag);
  final _ilp = Rxn<ILP>();
  late ILPHeader _header;
  final _links = <(String, String)>[];
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
      _header = await _ilp.value!.header;
      _links.clear();
      for (var i = 0; i < _header.links.length; i += 2) {
        _links.add((_header.links[i], _header.links[i + 1]));
      }
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
      color: Colors.transparent,
      child: GetBuilder<T>(
        id: 'bottomSheet',
        tag: widget.tag,
        builder: (controller) => Column(
          children: [
            if (kDebugMode && env.isSteam)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('测试成就【强迫症玩家】'),
                    onPressed: () {
                      for (var ilp in widget.file.infos) {
                        var unlockedAll = ilp.contentLayerIdList
                            .every((id) => Data.layersId.contains(id));
                        print('unlockedAll $unlockedAll');
                      }
                    },
                  ),
                ],
              ),

            /// 标题栏
            ListTile(
              trailing: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    child: Icon(Icons.play_arrow_rounded),
                    onPressed: () async {
                      await PageGameEntry.play(
                        widget.file.type == TagType.file
                            ? [widget.file]
                            : widget.file.children,
                        id: 1,
                        mode: GameMode.gallery,
                      );
                      controller.update([widget.file.id, 'bottomSheet']);
                    },
                  ),
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
                  Tooltip(
                    message: UI.steamWatchComments.tr,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.comment_rounded),
                      label: Text(widget.file.comments.toString()),
                      onPressed: () {
                        SteamClient.instance.openUrl(
                            'https://steamcommunity.com/sharedfiles/filedetails/comments/${widget.file.id}');
                        // SteamClient.instance.openUrl(
                        //     'steam://url/CommunityFilePage/${widget.file.id}'
                        // );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(widget.file.isSubscribed
                        ? Icons.heart_broken_rounded
                        : Icons.favorite_border_rounded),
                    label: widget.file.isSubscribed
                        ? Text(UI.steamUnSubscribe.tr)
                        : Text(UI.steamSubscribe.tr),
                    onPressed: () async {
                      if (widget.file.isSubscribed) {
                        await widget.file.unSubscribe();
                      } else {
                        await widget.file.subscribe();
                      }
                      _controller.update([widget.file.id, 'bottomSheet']);
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
                          ...widget.file.styles
                              .map((e) => Chip(label: Text(e.value.tr))),
                          ...widget.file.shapes
                              .map((e) => Chip(label: Text(e.value.tr))),
                          Chip(label: Text(widget.file.ageRating!.value.tr)),
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
                    title: Text(UI.steamAuthorInfo.tr),
                    subtitle: Text(UI.openInSteam.tr),
                    trailing: FaIcon(FontAwesomeIcons.steam),
                    onTap: () {
                      // SteamClient.instance.steamFriends
                      //     .activateGameOverlayToUser(
                      //   'steamid'.toNativeUtf8(),
                      //   widget.file.steamIdOwner,
                      // );
                      SteamClient.instance.openUrl(
                          'steam://url/SteamIDPage/${widget.file.steamIdOwner}');
                    },
                  ),

                  /// 在steam打开这个文件页面
                  ListTile(
                    title: Text(UI.fileInfo.tr),
                    subtitle: Text(UI.openInSteam.tr),
                    trailing: FaIcon(FontAwesomeIcons.steam),
                    onTap: () {
                      SteamClient.instance.openUrl(
                          'steam://url/CommunityFilePage/${widget.file.id}');
                    },
                  ),

                  /// 作者其它文件
                  ListTile(
                    title: Text(UI.steamAuthorOtherFiles.tr),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _controller.userId = widget.file.steamIdOwner;
                      _controller.page = 1;
                      Get.back();
                    },
                  ),

                  /// 版本
                  if (widget.file.type == TagType.file)
                    ListTile(
                      title: Text(UI.ilpVersion.tr),
                      subtitle: Text(widget.file.version.toString()),
                    ),

                  /// 描述
                  ListTile(
                    title: Text(UI.ilpDesc.tr),
                    subtitle: Text(widget.file.description?.isNotEmpty == true
                        ? widget.file.description!
                        : UI.empty.tr),
                  ),

                  /// 文件大小
                  if (widget.file.type == TagType.file)
                    ListTile(
                      title: Text(UI.fileSize.tr),
                      subtitle: Text(bytesSize(widget.file.fileSize, 2)),
                    ),

                  /// 链接
                  if (widget.file.type == TagType.file)
                    ListTile(
                      title: Text(UI.link.tr),
                      subtitle: _links.isEmpty
                          ? Text(UI.empty.tr)
                          : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _links
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
                    title: Text(UI.publishTime.tr),
                    subtitle: Text(formatDate(widget.file.publishTime)),
                  ),

                  ListTile(
                    title: Text(UI.updateTime.tr),
                    subtitle: Text(formatDate(widget.file.updateTime)),
                  ),

                  /// image length
                  if (widget.file.type == TagType.file)
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

  _open(String url) {}

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
                            [widget.file],
                            id: 1,
                            mode: GameMode.gallery,
                            ilpIndex: i,
                          ),
                          child: Icon(Icons.play_arrow_rounded),
                        ),
                        TextButton(
                          child: Icon(Icons.save_outlined),
                          onPressed: () {
                            PageSaveImageEntry.open(widget.file, i, id: 1);
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
