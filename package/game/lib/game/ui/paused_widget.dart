import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n/ui.dart';

import '../../explorer/ilp_info_bottom_sheet.dart';
import '../../explorer/test_ilp_file.dart';
import '../../utils/textfield_number_formatter.dart';
import '../level_controller.dart';
import '../level_find_differences.dart';
import '../puzzle/level_puzzle.dart';
import '../resources.dart';
import '../stroke_shadow.dart';
import 'levels_indicator.dart';

class PausedWidget<T extends LevelController> extends GetView<T> {
  final String? title;
  final double height;

  const PausedWidget({super.key, this.title, required this.height});

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel!;
    final isTestFile = level.file is TestILPFile;
    var title = isTestFile ? UI.test.tr : this.title;
    if (controller.isPaused && title == null) {
      final level = controller.currentLevel;
      if (level is LevelPuzzle) {
        title = UI.findPuzzles.tr;
      } else if (level is LevelFindDifferences) {
        title = level.type == LevelDifferentType.single
            ? UI.findOneLayer.tr
            : UI.findAllLayers.tr;
      }
    }
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
                title,
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
                      if (!controller.isCompleted) {
                        final foundLayers = controller.foundLayers;
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
                            } catch (e) {}
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
              if (!isTestFile)
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
                          'file': controller.currentLevel!.file,
                          'index': controller.current,
                        });
                      },
                    ),
                  ),
                ),

              /// 图片信息
              if (!isTestFile)
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
                          file: controller.currentLevel!.file,
                          ilp: controller.currentLevel!.ilp!,
                          currentInfo: controller.currentLevel!.info!,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          if (controller.levels.length > 1)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: LevelsIndicator<T>(itemSize: 30),
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
