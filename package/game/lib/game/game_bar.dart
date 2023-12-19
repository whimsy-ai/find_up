import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/utils/textfield_number_formatter.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import '../build_flavor.dart';
import '../explorer/ilp_info_bottom_sheet.dart';
import '../info_table.dart';
import 'controller.dart';
import 'page_game_entry.dart';

class GameBar extends StatefulWidget {
  final GameController controller;
  final TextStyle? textStyle;

  const GameBar({
    super.key,
    required this.controller,
    this.textStyle,
  });

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
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(kRadialReactionRadius)),
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
                Material(
                  child: Table(
                    textDirection: TextDirection.ltr,
                    defaultColumnWidth: IntrinsicColumnWidth(),
                    border: TableBorder.all(
                      width: 0,
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                          Radius.circular(kRadialReactionRadius)),
                    ),
                    children: [
                      TableRow(
                        children: _list(),
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

  List<Widget> _list() {
    final list = <Widget>[];
    <Widget>[
      InkWell(
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Tooltip(
            message: UI.back.tr,
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
            ),
          ),
        ),
        onTap: () => Get.back(),
      ),

      /// 信息
      SizedBox(
        width: 180,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: GetPlatform.isMobile ? 2 : 4),
          child: InfoTable(
            runSpace: GetPlatform.isMobile ? 0 : 4,
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
            ).copyWith(
              fontSize: widget.textStyle?.fontSize,
              color: widget.textStyle?.color,
            ),
          ),
        ),
      ),

      /// 暂停
      if (widget.controller.allowPause)
        InkWell(
          onTap: () => widget.controller.isStarted
              ? widget.controller.pause()
              : widget.controller.resume(),
          child: Tooltip(
            message: UI.gameBarPause.tr,
            child: Icon(
              widget.controller.isStarted
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_outlined,
            ),
          ),
        ),

      /// 输入种子
      InkWell(
        child: Tooltip(
            message: UI.gameBarChangeSeed.tr,
            child: Icon(Icons.keyboard_outlined)),
        onTap: () async {
          widget.controller.pause();
          var seed = widget.controller.seed;
          final sure = await Get.dialog(AlertDialog(
            title: Text(UI.inputTheSeed.tr),
            content: TextField(
              controller: TextEditingController(text: seed.toString()),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                NumberFormatter,
              ],
              onChanged: (v) {
                try {
                  seed = int.parse(v);
                } on Exception catch (e) {}
              },
            ),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
              ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: Text(UI.confirm.tr)),
            ],
          ));
          if (sure != true || seed == widget.controller.seed) {
            widget.controller.resume();
            return;
          }
          await widget.controller.start(seed: seed);
        },
      ),

      /// 提示
      InkWell(
        onTap: () => widget.controller.showTip(),
        child: Tooltip(
          message: UI.gameBarTip.tr,
          child: Icon(Icons.tips_and_updates_outlined),
        ),
      ),

      /// 刷新
      InkWell(
        child: Tooltip(
          message: UI.gameBarRestart.tr,
          child: Icon(Icons.refresh),
        ),
        onTap: () async {
          final foundLayers =
              widget.controller.allLayers - widget.controller.unTappedLayers;
          if (foundLayers > 0) {
            final sure = await Get.dialog(AlertDialog(
              title: Text(UI.restartConfirm.trArgs([foundLayers.toString()])),
              actions: [
                TextButton(
                    onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
                ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(UI.confirm.tr)),
              ],
            ));
            if (sure != true) return;
          }
          widget.controller.reStart();
        },
      ),

      /// debug
      if (env.isDev || widget.controller.allowDebug)
        InkWell(
          child: Icon(
            widget.controller.test
                ? Icons.bug_report_rounded
                : Icons.bug_report_outlined,
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
        child: Tooltip(
          message: UI.gameBarDrag.tr,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.arrowsUpDownLeftRight,
              size: 18,
              color: _drag.value ? Colors.black : Colors.black26,
            ),
          ),
        ),
      ),

      /// 信息按钮
      InkWell(
        child: Tooltip(
          message: UI.gameBarInfo.tr,
          child: Icon(Icons.info_outline),
        ),
        onTap: () async {
          final isStarted = widget.controller.isStarted;
          widget.controller.pause();
          await ILPInfoBottomSheet.show(
            ilp: widget.controller.ilp,
            currentInfo: widget.controller.info!,
            onTapPlay: (index) => PageGameEntry.replace(
              widget.controller.ilp,
              index: index,
            ),
          );
          if (isStarted) widget.controller.resume();
        },
      ),
    ].forEachIndexed((index, e) {
      final isInfoTable = e is SizedBox;
      if (index == 0) {
        e = SizedBox(width: kToolbarHeight, child: e);
      }
      if (e is InkWell) {
        e = SizedBox(width: 50, child: e);
      }
      if (index > 0) {
        e = ColoredBox(color: Colors.white, child: e);
      }
      if (isInfoTable) {
        e = TableCell(child: e);
      } else {
        e = TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: e,
        );
      }
      list.add(e);
      list.add(TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: ColoredBox(
          color: Colors.white,
          child: SizedBox(
            width: 10,
            child: index > 0 ? VerticalDivider() : null,
          ),
        ),
      ));
    });
    list
      ..removeAt(list.length - 1)
      ..add(TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: ColoredBox(color: Colors.white, child: SizedBox(width: 10)),
      ));

    return list;
  }
}
