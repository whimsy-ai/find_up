import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../build_flavor.dart';
import '../explorer/ilp_info_bottom_sheet.dart';
import '../info_table.dart';
import '../ui.dart';
import 'controller.dart';
import 'page_game_entry.dart';

class GameBar extends StatefulWidget {
  final GameController controller;

  GameBar({super.key, required this.controller});

  @override
  State<GameBar> createState() => _GameBarState();
}

Offset? _fixed;
bool _allowDrag = true;

class _GameBarState extends State<GameBar> {
  final _key = GlobalKey();
  final _offset = Rx<Offset>(_fixed ?? Offset.zero)
    ..listen((val) {
      _fixed = val;
    });
  final _drag = _allowDrag.obs
    ..listen((val) {
      _allowDrag = val;
    });

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _toTopCenter();
    });
  }

  _toTopCenter() {
    if (_fixed != null) return;
    final renderBoxRed = _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBoxRed.size;
    _offset.value = Offset((Get.width - size.width) / 2, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Positioned(
        key: _key,
        top: _offset.value.dy,
        left: _offset.value.dx,
        child: GestureDetector(
          onPanUpdate: (detail) {
            if (!_drag.value) return;
            final renderBoxRed =
                _key.currentContext!.findRenderObject() as RenderBox;
            final size = renderBoxRed.size;
            final screen = Rect.fromLTWH(
              size.width,
              size.height,
              Get.width - size.width * 2,
              Get.height - size.height * 2,
            );
            final topLeft = _offset.value + detail.delta;
            final bar = Rect.fromLTWH(
              topLeft.dx,
              topLeft.dy,
              size.width,
              size.height,
            );
            if (screen.overlaps(bar)) {
              _offset.value = topLeft;
            }
          },
          child: Container(
            margin: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Colors.white,
                ],
                stops: [0.11, 0.11],
              ),
              borderRadius: BorderRadius.all(Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -30,
                  child: Transform.rotate(
                    angle: -0.65,
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/icon_transparent.png',
                        package: 'game',
                        width: 100,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  child: Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () => Get.back(),
                      ),

                      /// 信息
                      SizedBox(
                        width: 200,
                        child: InfoTable(
                          space: 10,
                          runSpace: 4,
                          rows: [
                            (UI.seed.tr, widget.controller.seed),
                            (UI.clicks.tr, widget.controller.clicks),
                            if (widget.controller.timeMode == TimeMode.up)
                              (UI.usedTime.tr, widget.controller.time),
                            if (widget.controller.timeMode == TimeMode.down)
                              (UI.timeLeft.tr, widget.controller.time),
                            (UI.unfound.tr, widget.controller.unTappedLayers),
                          ],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      /// 暂停
                      if (widget.controller.allowPause)
                        InkWell(
                          onTap: () => widget.controller.isStarted
                              ? widget.controller.pause()
                              : widget.controller.resume(),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              widget.controller.isStarted
                                  ? Icons.pause_circle_outline_rounded
                                  : Icons.play_circle_outline_outlined,
                            ),
                          ),
                        ),

                      /// 刷新
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.refresh),
                        ),
                        onTap: () => widget.controller.reStart(),
                      ),

                      /// debug
                      if (env.isDev || widget.controller.allowDebug)
                        InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              widget.controller.test
                                  ? Icons.bug_report_rounded
                                  : Icons.bug_report_outlined,
                            ),
                          ),
                          onTap: () {
                            widget.controller.test = !widget.controller.test;
                          },
                        ),

                      /// 是否允许拖动
                      InkWell(
                        onTap: () {
                          _drag.value = !_drag.value;
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: FaIcon(
                            FontAwesomeIcons.arrowsUpDownLeftRight,
                            size: 18,
                            color: _drag.value ? Colors.black : Colors.black12,
                          ),
                        ),
                      ),

                      /// 信息按钮
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.info_outline),
                        ),
                        onTap: () async {
                          final isStarted = widget.controller.isStarted;
                          widget.controller.pause();
                          await ILPInfoBottomSheet.show(
                            ilp: widget.controller.ilp,
                            currentInfo: widget.controller.info!,
                            onTapPlay: (index) {
                              /// 退出当前游戏才能再次打开游戏
                              Get.back(closeOverlays: true);
                              PageGameEntry.play(widget.controller.ilp,
                                  index: index);
                            },
                          );
                          if (isStarted) widget.controller.resume();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
