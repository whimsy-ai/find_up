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
}
