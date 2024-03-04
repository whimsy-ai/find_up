import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

Future<ui.Color?> getPixel(List<int> bytes, int x, int y) async {
  final c = Completer<ui.Color?>();
  ui.decodeImageFromList(bytes as Uint8List, (ui.Image img) async {
    final int rowStride = img.width * 4;
    final int position = y * rowStride + x * 4;
    final data = (await img.toByteData())!;
    print('data length ${data.lengthInBytes}, position $position');
    if (position < 0 || position > data.lengthInBytes) return c.complete();
    final pixel = data.getUint32(position);
    c.complete(ui.Color((pixel << 24) | (pixel >> 8)));
  });
  return c.future;
}

Future<bool> isTransparentPixel(
  Uint8List bytes, {
  required int x,
  required int y,
}) =>
    getPixel(bytes, x, y).then((value) {
      return value == null || value.alpha == 0;
    });
