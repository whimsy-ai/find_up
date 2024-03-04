import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiscordLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(
          Icons.discord_rounded,
          color: Color.fromRGBO(114, 137, 218, 1),
        ),
        title: Text(UI.joinDiscord.tr),
        onTap: () => launchUrlString('https://discord.gg/cy6QTzSpJw'),
      );
}
