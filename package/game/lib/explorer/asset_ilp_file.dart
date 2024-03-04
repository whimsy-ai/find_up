import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../get_ilp_info_unlock.dart';
import 'file.dart';

class AssetILPFile implements ExplorerFile {
  final String assetPath;

  AssetILPFile(this.assetPath);

  @override
  late String name;
  @override
  late Uint8List cover;
  @override
  late int version;
  late int infoLength;
  @override
  late int fileSize;

  final Rxn<ILP> _ilp = Rxn();

  @override
  ILP? get ilp => _ilp.value;

  @override
  double unlock = 0;

  @override
  load({force = false}) async {
    if (force) _ilp.value = null;
    if (_ilp.value != null) return;
    final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
    fileSize = bytes.lengthInBytes;
    final ilp = _ilp.value = ILP.fromBytes(bytes);
    final header = await ilp.header;
    cover = await ilp.cover;
    name = header.name;
    version = header.version;
    final infos = await ilp.infos;
    infoLength = infos.length;
    unlock = infos.map((e) => getIlpInfoUnlock(e)).toList().sum / infos.length;
  }
}
