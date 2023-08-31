import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../ui.dart';

class GameHelper extends StatelessWidget {
  static Future show() => Get.dialog(GameHelper());

  @override
  Widget build(BuildContext context) {
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
                        WindowsUI.dragToMove.tr,
                        WindowsUI.clickToFind.tr,
                        WindowsUI.doubleClickToReset.tr,
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
                      Text(WindowsUI.scrollToScale.tr),
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
