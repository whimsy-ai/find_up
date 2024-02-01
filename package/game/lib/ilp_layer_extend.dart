import 'package:ilp_file_codec/ilp_codec.dart';

extension ILPLayerEx on ILPLayer {
  Iterable<ILPLayer> flat() {
    final list = <ILPLayer>[];
    loop(ILPLayer group) {
      for (var layer in group.layers) {
        if (layer.layers.isNotEmpty) {
          list.add(layer);
        }
      }
    }

    for (var layer in layers) {
      if (layer.hasContent()) {
        list.add(layer);
      } else if (layer.layers.isNotEmpty) {
        loop(layer);
      }
    }

    return list;
  }
}
