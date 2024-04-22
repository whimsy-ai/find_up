import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/brightness_widget.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';
import 'package:window_manager/window_manager.dart';


class TopBar extends StatelessWidget {
  final String? title;
  final bool brightness;
  final bool settings;
  final bool back;
  final List<Widget>? icons;
  static const double _iconSize = 16;

  const TopBar({
    super.key,
    this.title,
    this.back = true,
    this.brightness = true,
    this.settings = true,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          if (back)
            Tooltip(
              message: UI.back.tr,
              child: InkWell(
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_circle_left_rounded,
                    size: _iconSize * 1.5,
                  ),
                ),
                onTap: () => Get.back(id: 1),
              ),
            ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _maximize,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: title == null ? SizedBox.expand() : Text(title!),
              ),
            ),
          ),
          Row(
            children: [
              if (icons != null) ...icons!,

              /// 光暗
              if (brightness)
                BrightnessWidget(
                  builder: (isDark, switcher) => InkWell(
                    onTap: switcher,
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: _iconSize,
                      ),
                    ),
                  ),
                ),

              /// 设置
              if (settings)
                InkWell(
                  onTap: () {
                    Get.toNamed('/settings', id: 1);
                  },
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      FontAwesomeIcons.gear,
                      size: _iconSize,
                    ),
                  ),
                ),
              if (settings || brightness) SizedBox(width: 10),

              /// minimize
              InkWell(
                onTap: () => windowManager.minimize(),
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.minimize_rounded,
                    size: _iconSize,
                  ),
                ),
              ),

              /// maximize
              InkWell(
                onTap: _maximize,
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.photo_size_select_small_rounded,
                    size: _iconSize,
                  ),
                ),
              ),

              /// close
              InkWell(
                onTap: () => exit(0),
                child: Container(
                  height: double.infinity,
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.close,
                    size: _iconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static _maximize() async {
    (await windowManager.isMaximized())
        ? windowManager.unmaximize()
        : windowManager.maximize();
  }
}
