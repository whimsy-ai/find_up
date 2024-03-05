import 'package:borders/borders.dart';
import 'package:flutter/material.dart';
import 'package:game/game/ui/my_trapezium_border.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n/ui.dart';

import '../level_controller.dart';
import '../resources.dart';
import '../stroke_shadow.dart';

class ScoreBar<T extends LevelController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
        decoration: ShapeDecoration(
          color: Color.fromRGBO(4, 13, 23, 0.6),
          shape: MyTrapeziumBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              borderOffset: BorderOffset.vertical(
                bottom: Offset(30, 0),
              )),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Tooltip(
              message: UI.seed.tr,
              child: Wrap(
                spacing: 5,
                children: [
                  StrokeShadow.path(
                    Resources.iconKey,
                    color: Colors.white,
                    size: 20,
                    stroke: Stroke(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      width: 2,
                    ),
                  ),
                  StrokeShadow.text(
                    '${controller.seed}',
                    style: GoogleFonts.lilitaOne(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    stroke: Stroke(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      width: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Tooltip(
                  message: UI.timeLeft.tr,
                  child: Wrap(
                    children: [
                      StrokeShadow.path(
                        Resources.iconStopWatch,
                        color: Colors.white,
                        size: 40,
                        stroke: Stroke(
                          width: 4,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ),
                      GetBuilder<T>(
                        id: 'time',
                        builder: (_) => StrokeShadow.text(
                          '${controller.time} s',
                          style: GoogleFonts.lilitaOne(
                            fontSize: 30,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                          stroke: Stroke(
                            color: Colors.black,
                            offset: Offset(0, 4),
                            width: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Tooltip(
              message: UI.layerCount.tr,
              child: Wrap(
                spacing: 5,
                children: [
                  StrokeShadow.path(
                    Resources.iconStack,
                    color: Colors.white,
                    size: 20,
                    stroke: Stroke(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      width: 2,
                    ),
                  ),
                  StrokeShadow.text(
                    '${controller.foundLayers} / ${controller.allLayers}',
                    style: GoogleFonts.lilitaOne(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    stroke: Stroke(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      width: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
