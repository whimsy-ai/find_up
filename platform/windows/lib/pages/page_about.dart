import 'package:flutter/material.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
          width: 400,
          height: 300,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text('${UI.findUp.tr} v${packageInfo.version}'),
                    subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () => launchUrlString(
                              'https://github.com/whimsy-ai/find_up'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link),
                              Text('Github'),
                            ],
                          )),
                    ),
                  ),
                  ListTile(
                    title: Text(UI.contactDeveloper.tr),
                    subtitle: Wrap(
                      spacing: 10,
                      children: [
                        TextButton(
                          child: Text('Email'),
                          onPressed: () =>
                              launchUrlString('mailto:gzlock88@gmail.com'),
                        ),
                        TextButton(
                          child: Text('Github'),
                          onPressed: () =>
                              launchUrlString('https://github.com/gzlock'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
