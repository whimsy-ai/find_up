import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n/ui.dart';

import '../../explorer/ilp_info_bottom_sheet.dart';
import '../../utils/textfield_number_formatter.dart';
import '../controller.dart';
import '../page_game_entry.dart';
import '../resources.dart';
import '../stroke_shadow.dart';

class PausedWidget extends GetView<GameController> {
  final String? title;
  final double height;

  const PausedWidget({super.key, this.title, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Color.fromRGBO(5, 13, 24, 0.5),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null)
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: StrokeShadow.text(
                title!,
                style: GoogleFonts.lilitaOne(fontSize: 24, letterSpacing: 1.5),
                stroke: Stroke(
                  width: 2,
                  color: Colors.black,
                  offset: Offset(0, 2),
                ),
              ),
            ),
          Wrap(
            spacing: 40,
            children: [
              /// 继续游戏
              if (controller.isPaused)
                Tooltip(
                  message: UI.resume.tr,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: FloatingActionButton(
                      backgroundColor: ColorScheme.light().tertiaryContainer,
                      elevation: 0,
                      onPressed: () => controller.resume(),
                      child: StrokeShadow.path(
                        Resources.iconPlay,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              /// 重新开始游戏
              if (controller.isFailed)
                Tooltip(
                  message: UI.retry.tr,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: FloatingActionButton(
                      backgroundColor: ColorScheme.light().tertiaryContainer,
                      elevation: 0,
                      onPressed: () => controller.start(seed: controller.seed),
                      child: StrokeShadow.path(
                        Resources.iconRefresh,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              /// 随机种子，重新开始
              SizedBox(
                width: 80,
                height: 80,
                child: Tooltip(
                  message: UI.gameBarRestart.tr,
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    child: StrokeShadow.path(
                      Resources.iconDice,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final foundLayers =
                          controller.allLayers - controller.unTappedLayers;
                      if (foundLayers > 0) {
                        final sure = await Get.dialog(AlertDialog(
                          title: Text(UI.restartConfirm
                              .trArgs([foundLayers.toString()])),
                          actions: [
                            TextButton(
                                onPressed: () => Get.back(),
                                child: Text(UI.cancel.tr)),
                            ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                child: Text(UI.confirm.tr)),
                          ],
                        ));
                        if (sure != true) return;
                      }
                      controller.start();
                    },
                  ),
                ),
              ),

              /// 手动输入种子
              SizedBox(
                width: 80,
                height: 80,
                child: Tooltip(
                  message: UI.gameBarChangeSeed.tr,
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    child: StrokeShadow.path(
                      Resources.iconKey,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      var seed = controller.seed;
                      final sure = await Get.dialog(AlertDialog(
                        title: Text(UI.inputTheSeed.tr),
                        content: TextField(
                          controller:
                              TextEditingController(text: seed.toString()),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [NumberFormatter],
                          onChanged: (v) {
                            try {
                              seed = int.parse(v);
                            } on Exception catch (e) {}
                          },
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(),
                              child: Text(UI.cancel.tr)),
                          ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              child: Text(UI.confirm.tr)),
                        ],
                      ));
                      if (controller.isPaused && seed == controller.seed) {
                        return;
                      }
                      print('输了，修改种子 $seed');
                      if (sure == true) controller.start(seed: seed);
                    },
                  ),
                ),
              ),

              /// 保存图片
              SizedBox(
                width: 80,
                height: 80,
                child: Tooltip(
                  message: UI.saveImage.tr,
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    child: StrokeShadow.path(
                      Resources.iconSave,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      Get.toNamed('/save', arguments: {
                        'info': controller.info,
                        'layer': controller.layer,
                      });
                    },
                  ),
                ),
              ),

              /// 图片信息
              SizedBox(
                width: 80,
                height: 80,
                child: Tooltip(
                  message: UI.fileInfo.tr,
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    child: StrokeShadow.path(
                      Resources.iconInfo,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ILPInfoBottomSheet.show(
                        ilp: controller.ilp,
                        currentInfo: controller.info!,
                        onTapPlay: (index) => PageGameEntry.replace(
                          controller.ilp,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().moveX(
          begin: Get.width,
          end: 0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutQuart,
        );
  }
}
