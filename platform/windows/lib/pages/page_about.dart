import 'package:flutter/material.dart';
import 'package:game/data.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../main.dart';
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
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('${UI.findUp.tr} v${packageInfo.version}'),
                    trailing: ElevatedButton(
                        onPressed: () => launchUrlString(
                            'https://github.com/whimsy-ai/find_up'),
                        child: Text('Github')),
                  ),
                  ListTile(
                    trailing: Icon(Icons.link),
                    title: Text(UI.android.tr),
                    subtitle: Text('Google Play'),
                    onTap: () => launchUrlString(
                        'https://play.google.com/store/apps/details?id=whimsy_ai.find_up'),
                  ),
                  ListTile(
                    trailing: Icon(Icons.link),
                    title: Text(UI.steam.tr),
                    subtitle: Text(UI.steamWorkShop.tr),
                    onTap: () => launchUrlString(
                        'https://store.steampowered.com/app/$steamAppId/_/'),
                  ),
                  ListTile(
                    trailing: Icon(Icons.link),
                    title: Text(UI.msStore.tr),
                    onTap: () {
                      final lan = Data.locale.toString().replaceAll('_', '-');
                      final name = lan.contains('zh') ? '找起来' : 'find_up';
                      launchUrlString(
                          'https://www.microsoft.com/$lan/p/$name/9n99r98z0qr3');
                    },
                  ),
                  ListTile(
                    title: Text(UI.contactMe.tr),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton(
                          child: Text('Email'),
                          onPressed: () =>
                              launchUrlString('mailto:gzlock88@gmail.com'),
                        ),
                        ElevatedButton(
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
