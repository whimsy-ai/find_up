import 'package:flutter/material.dart';
import 'package:game/about_card.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import '../../utils/version.dart';

class PageAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UI.about.tr),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: AboutCard(
            version: '${packageInfo.version}_${packageInfo.buildNumber}',
          ),
        ),
      ),
    );
  }
}
