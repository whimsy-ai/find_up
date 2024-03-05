import 'dart:convert';

import 'package:flutter/services.dart';

import 'explorer/asset_ilp_file.dart';

Future<List<AssetILPFile>> getBundleFiles() async {
  final Map<String, dynamic> assets =
      jsonDecode(await rootBundle.loadString('AssetManifest.json'));
  final assetFiles = <String>[];
  assets.forEach((key, value) {
    if (key.endsWith('.ilp')) {
      final String file = value.first;
// print('file $file');
      assetFiles.add(file);
    }
  });
  print('files $assetFiles');
  return assetFiles.map((e) => AssetILPFile(e)).toList();
}
