import 'package:flutter/material.dart';
import 'package:game/about_card.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import '../utils/update_window_title.dart';

class PageAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UI.about.tr),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: AboutCard(
            version: '${packageInfo.version}_${packageInfo.buildNumber}',
          ),
        ),
      ),
    );
  }
}
