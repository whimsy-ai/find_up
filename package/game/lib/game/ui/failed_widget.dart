import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n/ui.dart';

import '../../explorer/ilp_info_bottom_sheet.dart';
import '../controller.dart';
import '../page_game_entry.dart';
import '../resources.dart';
import '../stroke_shadow.dart';

class FailedWidget extends GetView<GameController> {
  final double height;

  const FailedWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Color.fromRGBO(5, 13, 24, 0.5),
      alignment: Alignment.center,
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        children: [
          Container(
            color: Colors.red,
            child: StrokeShadow.text(
              UI.failed.tr,
              style: GoogleFonts.lilitaOne(fontSize: 24, letterSpacing: 1.5),
              stroke: Stroke(width: 2, color: Colors.black, offset: Offset(0, 2)),
            ),
          ),
          Wrap(
            children: [
              /// 重新玩
              Tooltip(
                message: UI.retry.tr,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    elevation: 0,
                    onPressed: () => controller.start(seed: controller.seed),
                    child: StrokeShadow.path(
                      Resources.iconRefresh,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              /// 重新玩
              Tooltip(
                message: UI.retry.tr,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    elevation: 0,
                    onPressed: () => controller.start(seed: controller.seed),
                    child: StrokeShadow.path(
                      Resources.iconRefresh,
                      color: Colors.white,
                    ),
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
          begin: -Get.width,
          end: 0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutQuart,
        );
  }
}
