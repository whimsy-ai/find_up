import 'package:flutter/material.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      UI.findUp.tr,
                      style: TextStyle(fontSize: 24),
                    ),
                    subtitle: Text('v ${packageInfo.version}.${packageInfo.buildNumber}'),
                    trailing: TextButton(
                      onPressed: () => launchUrlString(
                          'https://github.com/whimsy-ai/find_up'),
                      child: Text('Github'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
