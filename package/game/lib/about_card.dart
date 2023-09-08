import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'data.dart';
import 'ui.dart';

class AboutCard extends StatelessWidget {
  final String version;

  const AboutCard({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('${UI.findUp.tr} v$version'),
            trailing: ElevatedButton.icon(
              onPressed: () =>
                  launchUrlString('https://github.com/whimsy-ai/find_up'),
              icon: FaIcon(FontAwesomeIcons.github),
              label: Text('Github'),
            ),
          ),
          Divider(),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.googlePlay),
            trailing: Icon(Icons.link),
            title: Text(UI.android.tr),
            subtitle: Text('Google Play'),
            onTap: () => launchUrlString(
                'https://play.google.com/store/apps/details?id=whimsy_ai.find_up'),
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.steam),
            trailing: Icon(Icons.link),
            title: Text(UI.steam.tr),
            subtitle: Text(UI.steamWorkShop.tr),
            onTap: () => launchUrlString(
                'https://store.steampowered.com/app/2550370/_/'),
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.microsoft),
            trailing: Icon(Icons.link),
            title: Text(UI.msStore.tr),
            onTap: () {
              launchUrlString(
                  'https://www.microsoft.com/store/productid/9N99R98Z0QR3?ocid=pdpshare');
            },
          ),
          Divider(),
          ListTile(
            title: Text(UI.contactMe.tr),
            trailing: Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.envelope),
                  label: Text('Email'),
                  onPressed: () => launchUrlString('mailto:gzlock88@gmail.com'),
                ),
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.github),
                  label: Text('Github'),
                  onPressed: () => launchUrlString('https://github.com/gzlock'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
