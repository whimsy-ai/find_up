import 'package:flutter/material.dart';

/// todo
class SteamCachedImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final double? width, height;

  const SteamCachedImage(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) => Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
      );
}
