import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<Uint8List> compressImage(File file, {int max = 200}) async {
  final bytes = await file.readAsBytes();
  final c = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, (result) {
    c.complete(result);
  });
  final img = await c.future;
  if (math.max(img.width, img.height) <= max) return bytes;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final scale = (max) / math.max(img.width, img.height);
  paintImage(
    canvas: canvas,
    scale: scale,
    rect: Rect.fromLTWH(0, 0, img.width * scale, img.height * scale),
    image: img,
  );

  final picture = recorder.endRecording();
  final imageFile = await picture.toImage(
    (img.width * scale).ceil(),
    (img.height * scale).ceil(),
  );
  final byteData = await imageFile.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
