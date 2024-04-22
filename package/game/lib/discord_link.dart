import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiscordLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
        child: Icon(
          Icons.discord_rounded,
          color: Color.fromRGBO(114, 137, 218, 1),
        ),
        onPressed: () => launchUrlString('https://discord.gg/cy6QTzSpJw'),
      );
}
