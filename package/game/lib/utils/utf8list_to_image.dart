import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

Future<ui.Image> utf8ListToImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}
