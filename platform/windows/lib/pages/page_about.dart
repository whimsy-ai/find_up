import 'package:flutter/material.dart';
import 'package:game/about_card.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import '../utils/update_window_title.dart';

class PageAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buildNumber = packageInfo.buildNumber.isEmpty?'':'_${packageInfo.buildNumber}';
    return Scaffold(
      appBar: AppBar(
        title: Text(UI.about.tr),
      ),
      body: Center(
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
