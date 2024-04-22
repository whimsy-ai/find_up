import 'package:flutter/material.dart';
import 'package:game/about_card.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

import '../utils/update_window_title.dart';
import '../utils/window_frame.dart';

class PageAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buildNumber =
        packageInfo.buildNumber.isEmpty ? '' : '_${packageInfo.buildNumber}';
    return WindowFrame(
      title: UI.about.tr,
      settings: false,
      child: Center(
        child: SizedBox(
          width: 500,
          child: AboutCard(
            version: '${packageInfo.version}$buildNumber',
          ),
        ),
      ),
    );
  }
}
