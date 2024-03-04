import 'package:flutter/material.dart';
import 'package:game/build_flavor.dart';
import 'package:game/duration_extension.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n/ui.dart';
import 'package:oktoast/oktoast.dart';

import '../level_controller.dart';
import '../resources.dart';
import '../stroke_shadow.dart';

class TipToolWidget<T extends LevelController> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: UI.gameBarTip.tr,
      child: GetBuilder<T>(
          id: 'tip',
          builder: (controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (controller.nextHintTime.inMilliseconds > 0)
                  StrokeShadow.text(
                    controller.nextHintTime.toSemanticString(),
                    style: GoogleFonts.lilitaOne(
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                    stroke: Stroke(
                      width: 2,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (env.isDev)
                      ElevatedButton(
                        onPressed: controller.setFail,
                        child: Text('测试失败'),
                      ),
                    FloatingActionButton(
                      onPressed: () {
                        if (controller.showHint(controller.currentLevel)) {
                          showToast(UI.showATip.tr);
                        }
                      },
                      child: StrokeShadow.path(
                        Resources.iconFocus,
                        color: controller.nextHintTime.inMilliseconds > 0
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}

class DurationPainter extends CustomPainter {
  final Duration duration;

  DurationPainter(this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: formatDuration(duration),
        style: GoogleFonts.lilitaOne(
          fontSize: 16,
          letterSpacing: 1.5,
          color: Colors.red,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    double x = (size.width - textPainter.width) / 2;
    double y = (size.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(DurationPainter oldDelegate) {
    return oldDelegate.duration != duration;
  }
}

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds.remainder(60);
  int milliseconds = duration.inMilliseconds.remainder(1000);

  return '$minutes:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}';
}
