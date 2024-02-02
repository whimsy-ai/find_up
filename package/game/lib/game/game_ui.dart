import 'package:flutter/material.dart';
import 'package:game/game/ui/tip_tool_widget.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import 'controller.dart';
import 'resources.dart';
import 'stroke_shadow.dart';
import 'ui/completed_widget.dart';
import 'ui/failed_widget.dart';
import 'ui/paused_widget.dart';
import 'ui/score_bar.dart';

class GameUI extends StatefulWidget {
  final GameController controller;

  const GameUI({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _GameUI();
}

class _GameUI extends State<GameUI> {
  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
            SizedBox(height: 10),
            Text(UI.loading.tr),
          ],
        ),
      );
    } else if (widget.controller.isLoadError) {
      return LayoutBuilder(builder: (context, constrains) {
        return Center(
          child: AlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                  color: Colors.amber,
                ),
                Text(UI.loadingError.tr),
              ],
            ),
            content: Text(widget.controller.error ?? UI.unKnowError.tr),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.refresh),
                label: Text(UI.retry.tr),
                onPressed: () => widget.controller.start(),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.chevron_left_rounded),
                label: Text(UI.back.tr),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        );
      });
    }
    return Stack(
      children: [
        /// 时间栏
        /// 得分栏
        if (widget.controller.state.value > GameState.already.value)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: TopBar(),
            ),
          ),

        /// 左上
        /// 返回按钮
        Positioned(
          top: 10,
          left: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () => Get.back(),
                  elevation: 0,
                  child: StrokeShadow.path(
                    Resources.iconLeft,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 右上
        /// 暂停按钮
        if (widget.controller.state == GameState.started)
          Positioned(
              top: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      elevation: 0,
                      child: StrokeShadow.path(
                        Resources.iconPause,
                      ),
                      onPressed: () {
                        if (widget.controller.isStarted) {
                          widget.controller.pause();
                        } else if (widget.controller.isPaused) {
                          widget.controller.resume();
                        }
                      },
                    ),
                  ),
                ],
              )),

        /// 左下
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   child: Text('bottom left'),
        // ),

        /// 右下
        /// 提示功能
        if (widget.controller.isStarted)
          Positioned(
            bottom: 10,
            right: 10,
            child: TipToolWidget(),
          ),

        /// 暂停界面
        if (widget.controller.isPaused)
          Positioned(
            bottom: Get.height / 2 - 100,
            left: 0,
            right: 0,
            child: PausedWidget(height: 200),
          ),

        /// 失败界面
        if (widget.controller.isFailed)
          Positioned(
            bottom: Get.height / 2 - 100,
            left: 0,
            right: 0,
            child: PausedWidget(title: UI.failed.tr, height: 200),
          ),

        /// 完成界面
        // if (widget.controller.isCompleted)
        //   Positioned(
        //     bottom: Get.height / 2 - 100,
        //     left: 0,
        //     right: 0,
        //     child: CompletedWidget(height: 200),
        //   ),
      ],
    );
  }
}

// class GameBar1 extends StatefulWidget {
//   final GameController controller;
//   final TextStyle? textStyle;
//
//   const GameBar1({
//     super.key,
//     required this.controller,
//     this.textStyle,
//   });
//
//   @override
//   State<GameBar1> createState() => _GameBarState();
// }
//
// class _GameBarState extends State<GameBar1> {
//   final _key = GlobalKey();
//   var _offset = Offset.zero;
//
//   set offset(val) {
//     setState(() {
//       _offset = val;
//     });
//   }
//
//   final double _miniWidth = 200;
//   double? _fullWidth, _width;
//   late final GlobalKey _containerKey = GlobalKey();
//   Tweener? _widthTweener;
//
//   @override
//   void dispose() {
//     _widthTweener?.stop();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _widthTweener?.stop();
//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//       _calcWidth();
//       _toTopCenter();
//     });
//   }
//
//   void _calcWidth() {
//     final renderBoxRed = _containerKey.currentContext?.findRenderObject();
//     final sizeRed = renderBoxRed?.paintBounds.size;
//     _width = _fullWidth = sizeRed!.width;
//     print("_fullWidth $_fullWidth");
//     _tweenTo(_miniWidth);
//   }
//
//   void _tweenTo(double width, [Duration? delay]) {
//     print('tween width $_width to $width');
//     _widthTweener?.stop();
//     _widthTweener = Tweener({'w': _width})
//         .to({'w': width}, 200)
//         .delay(delay?.inMilliseconds ?? 0)
//         .easing(Ease.quint.easeOut)
//         .onUpdate((obj) {
//           setState(() {
//             _width = obj['w'];
//             // print('tween updated $_width');
//           });
//         })
//         .start();
//   }
//
//   _toTopCenter() {
//     final renderBoxRed = _key.currentContext!.findRenderObject() as RenderBox;
//     final size = renderBoxRed.size;
//     offset = Offset((Get.width - size.width) / 2, 10);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       key: _key,
//       top: _offset.dy,
//       left: _offset.dx,
//       child: MouseRegion(
//         onEnter: (_) {
//           _tweenTo(_fullWidth!);
//         },
//         onExit: (_) {
//           _tweenTo(_miniWidth, Duration(milliseconds: 200));
//         },
//         child: Container(
//           key: _containerKey,
//           width: _width,
//           margin: EdgeInsets.all(10),
//           clipBehavior: Clip.antiAlias,
//           padding: EdgeInsets.zero,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius:
//                 BorderRadius.all(Radius.circular(kRadialReactionRadius)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black45,
//                 blurRadius: 3,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Material(
//             child: Table(
//               textDirection: TextDirection.ltr,
//               defaultColumnWidth: IntrinsicColumnWidth(),
//               border: TableBorder.all(
//                 width: 0,
//                 color: Colors.white,
//                 borderRadius:
//                     BorderRadius.all(Radius.circular(kRadialReactionRadius)),
//               ),
//               children: [
//                 TableRow(children: _list()),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _list() {
//     final list = <Widget>[];
//     <Widget>[
//       InkWell(
//         child: Container(
//           color: Theme.of(context).colorScheme.primary,
//           child: Tooltip(
//             message: UI.back.tr,
//             child: Icon(
//               Icons.chevron_left_rounded,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         onTap: () => Get.back(),
//       ),
//
//       /// 信息
//       SizedBox(
//         width: 120,
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: GetPlatform.isMobile ? 2 : 4),
//           child: DefaultTextStyle(
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.black54,
//               fontFamily: 'LilitaOne',
//             ).copyWith(
//               fontSize: widget.textStyle?.fontSize,
//               color: widget.textStyle?.color,
//             ),
//             child: Wrap(
//               runSpacing: 4,
//               children: [
//                 Tooltip(
//                   message: UI.seed.tr,
//                   child: Row(children: [
//                     Icon(Icons.key, size: 20),
//                     SizedBox(width: 10),
//                     Text(widget.controller.seed.toString())
//                   ]),
//                 ),
//                 Tooltip(
//                   message: UI.usedTime.tr,
//                   child: Row(children: [
//                     Icon(Icons.timer_sharp, size: 20),
//                     SizedBox(width: 10),
//                     Text('${widget.controller.time} s')
//                   ]),
//                 ),
//                 Tooltip(
//                   message: UI.unfounded.tr,
//                   child: Row(children: [
//                     Icon(Icons.image_search_rounded, size: 20),
//                     SizedBox(width: 10),
//                     Text(widget.controller.unTappedLayers.toString())
//                   ]),
//                 ),
//               ],
//             ),
//           ),
//           // child: Table(
//           //   children: [
//           //     TableRow(
//           //       children: [
//           //         SizedBox(
//           //           height: 30,
//           //           child: Icon(Icons.vpn_key, size: 20),
//           //         ),
//           //         Text(widget.controller.seed.toString())
//           //       ],
//           //     ),
//           //     TableRow(children: [
//           //       SizedBox(
//           //         height: 30,
//           //         child: Icon(Icons.timer_sharp, size: 20),
//           //       ),
//           //       Text(widget.controller.time.toString())
//           //     ]),
//           //     TableRow(children: [
//           //       SizedBox(
//           //         height: 30,
//           //         child: Icon(Icons.image_search_rounded,
//           //             size: 20),
//           //       ),
//           //       Text(widget.controller.unTappedLayers.toString())
//           //     ]),
//           //     // TableRow(),
//           //   ],
//           // ),
//           // child: InfoTable(
//           //   runSpace: GetPlatform.isMobile ? 0 : 4,
//           //   rows: [
//           //     (UI.seed.tr, widget.controller.seed),
//           //     (UI.clicks.tr, widget.controller.clicks),
//           //     if (widget.controller.timeMode == TimeMode.up)
//           //       (UI.usedTime.tr, widget.controller.time),
//           //     if (widget.controller.timeMode == TimeMode.down)
//           //       (UI.timeLeft.tr, widget.controller.time),
//           //     (UI.unfound.tr, widget.controller.unTappedLayers),
//           //   ],
//           //   style: TextStyle(
//           //     fontSize: 14,
//           //     color: Colors.black54,
//           //   ).copyWith(
//           //     fontSize: widget.textStyle?.fontSize,
//           //     color: widget.textStyle?.color,
//           //   ),
//           // ),
//         ),
//       ),
//
//       /// 暂停
//       if (widget.controller.allowPause)
//         InkWell(
//           onTap: () => widget.controller.isStarted
//               ? widget.controller.pause()
//               : widget.controller.resume(),
//           child: Tooltip(
//             message: UI.gameBarPause.tr,
//             child: Icon(
//               widget.controller.isStarted
//                   ? Icons.pause_circle_outline_rounded
//                   : Icons.play_circle_outline_outlined,
//             ),
//           ),
//         ),
//
//       /// 输入种子
//       InkWell(
//         child: Tooltip(
//             message: UI.gameBarChangeSeed.tr,
//             child: Icon(Icons.keyboard_outlined)),
//         onTap: () async {
//           widget.controller.pause();
//           var seed = widget.controller.seed;
//           final sure = await Get.dialog(AlertDialog(
//             title: Text(UI.inputTheSeed.tr),
//             content: TextField(
//               controller: TextEditingController(text: seed.toString()),
//               keyboardType: TextInputType.phone,
//               inputFormatters: [
//                 NumberFormatter,
//               ],
//               onChanged: (v) {
//                 try {
//                   seed = int.parse(v);
//                 } on Exception catch (e) {}
//               },
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
//               ElevatedButton(
//                   onPressed: () => Get.back(result: true),
//                   child: Text(UI.confirm.tr)),
//             ],
//           ));
//           if (sure != true || seed == widget.controller.seed) {
//             widget.controller.resume();
//             return;
//           }
//           await widget.controller.start(seed: seed);
//         },
//       ),
//
//       /// 提示
//       InkWell(
//         onTap: () => widget.controller.showTip(),
//         child: Tooltip(
//           message: UI.gameBarTip.tr,
//           child: Icon(Icons.tips_and_updates_outlined),
//         ),
//       ),
//
//       /// 刷新
//       InkWell(
//         child: Tooltip(
//           message: UI.gameBarRestart.tr,
//           child: Icon(Icons.refresh),
//         ),
//         onTap: () async {
//           final foundLayers =
//               widget.controller.allLayers - widget.controller.unTappedLayers;
//           if (foundLayers > 0) {
//             final sure = await Get.dialog(AlertDialog(
//               title: Text(UI.restartConfirm.trArgs([foundLayers.toString()])),
//               actions: [
//                 TextButton(
//                     onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
//                 ElevatedButton(
//                     onPressed: () => Get.back(result: true),
//                     child: Text(UI.confirm.tr)),
//               ],
//             ));
//             if (sure != true) return;
//           }
//           widget.controller.reStart();
//         },
//       ),
//
//       /// debug
//       if (env.isDev || widget.controller.allowDebug)
//         InkWell(
//           child: Icon(
//             widget.controller.test
//                 ? Icons.bug_report_rounded
//                 : Icons.bug_report_outlined,
//           ),
//           onTap: () {
//             widget.controller.test = !widget.controller.test;
//           },
//         ),
//
//       /// 信息按钮
//       InkWell(
//         child: Tooltip(
//           message: UI.gameBarInfo.tr,
//           child: Icon(Icons.info_outline),
//         ),
//         onTap: () async {
//           final isStarted = widget.controller.isStarted;
//           widget.controller.pause();
//           await ILPInfoBottomSheet.show(
//             ilp: widget.controller.ilp,
//             currentInfo: widget.controller.info!,
//             onTapPlay: (index) => PageGameEntry.replace(
//               widget.controller.ilp,
//               index: index,
//             ),
//           );
//           if (isStarted) widget.controller.resume();
//         },
//       ),
//     ].forEachIndexed((index, e) {
//       final isInfoTable = e is SizedBox;
//       if (index == 0) {
//         e = SizedBox(width: kToolbarHeight, child: e);
//       }
//       if (e is InkWell) {
//         e = SizedBox(width: 50, child: e);
//       }
//       if (index > 0) {
//         e = ColoredBox(color: Colors.white, child: e);
//       }
//       if (isInfoTable) {
//         e = TableCell(child: e);
//       } else {
//         e = TableCell(
//           verticalAlignment: TableCellVerticalAlignment.fill,
//           child: e,
//         );
//       }
//       list.add(e);
//       list.add(TableCell(
//         verticalAlignment: TableCellVerticalAlignment.fill,
//         child: ColoredBox(
//           color: Colors.white,
//           child: SizedBox(
//             width: 10,
//             child: index > 0 ? VerticalDivider() : null,
//           ),
//         ),
//       ));
//     });
//     list
//       ..removeAt(list.length - 1)
//       ..add(TableCell(
//         verticalAlignment: TableCellVerticalAlignment.fill,
//         child: ColoredBox(color: Colors.white, child: SizedBox(width: 10)),
//       ));
//
//     return list;
//   }
// }
