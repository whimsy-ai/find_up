import 'package:flutter/material.dart';

class SteamCachedImage extends StatelessWidget {
  final String url;

  const SteamCachedImage(this.url, {super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          if (url.isEmpty) {
            return Container(
              constraints: BoxConstraints(minHeight: c.maxWidth),
              color: Colors.grey,
              child: Center(
                child: Icon(Icons.image_outlined),
              ),
            );
          }
          return Image.network(
            url,
            width: c.maxWidth,
            fit: BoxFit.fitWidth,
          );
        },
      );
}
