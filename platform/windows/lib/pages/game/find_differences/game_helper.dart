import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game/data.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

class GameHelper extends StatelessWidget {
  static Future show() => Get.dialog(
        AlertDialog(
          title: Text(UI.pcGameOperationInstructions.tr),
          content: GameHelper(),
          actions: [
            ElevatedButton(
              child: Text(UI.dontShowAgain.tr),
              onPressed: () {
                Data.showGameHelper = false;
                Get.back();
              },
            ),
          ],
        ),
      );
  final double width = 80, height = 60;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Wrap(
      direction: Axis.vertical,
      spacing: 20,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: SvgPicture.asset(
                'assets/mouse-left-click-icon.svg',
                semanticsLabel: 'mouse',
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(UI.clickToFind.tr),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: SvgPicture.asset(
                'assets/mouse-left-drag-icon.svg',
                semanticsLabel: 'mouse left button drag',
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(UI.dragToMove.tr),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: SvgPicture.asset(
                'assets/mouse-scroll-wheel-icon.svg',
                semanticsLabel: 'mouse',
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(UI.scrollToScale.tr),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: SvgPicture.asset(
                'assets/mouse-double-click-icon.svg',
                semanticsLabel: 'double click',
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(UI.doubleClickToReset.tr),
          ],
        ),
      ],
    );
  }

  @override
  Widget build1(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white, fontSize: 20),
        child: Center(
          child: SizedBox(
            width: 600,
            height: 500,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: 400,
                  height: 400,
                  child: SvgPicture.asset(
                    'assets/mouse.svg',
                    semanticsLabel: 'mouse',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primaryContainer,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 150,
                  top: 40,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 240,
                        child: DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          lineLength: double.infinity,
                          lineThickness: 8,
                          dashLength: 20,
                          dashGapLength: 4,
                          dashColor: Colors.white,
                          dashRadius: 8,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text([
                        UI.dragToMove.tr,
                        UI.clickToFind.tr,
                        UI.doubleClickToReset.tr,
                      ].join('\n')),
                    ],
                  ),
                ),
                Positioned(
                  left: 200,
                  top: 120,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          lineLength: double.infinity,
                          lineThickness: 8,
                          dashLength: 20,
                          dashGapLength: 4,
                          dashColor: Colors.white,
                          dashRadius: 8,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(UI.scrollToScale.tr),
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
