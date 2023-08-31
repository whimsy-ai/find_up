import 'package:ilp_file_codec/ilp_codec.dart';

import 'data.dart';

double getIlpInfoUnlock(ILPInfo info){
  final value =
      Data.layersId.intersection(info.contentLayerIdList.toSet()).length /
          (info.contentLayerIdList.length - 1);
  return double.parse(value.toStringAsFixed(2));
}