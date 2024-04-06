import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import '../get_ilp_info_unlock.dart';
import 'file.dart';

class ILPFile extends ExplorerFile {
  final File file;

  ILPConfigException? get exception => _exception.value;
  final Rxn<ILPConfigException> _exception = Rxn();

  final Rxn<ILP> _ilp = Rxn();

  @override
  ILP? get ilp => _ilp.value;

  set ilp(ILP? ilp) => _ilp.value = ilp;

  @override
  late String name;
  @override
  late Uint8List cover;
  @override
  late int version;
  @override
  late int fileSize;

  late int infoLength;

  ILPFile(this.file);

  @override
  Future<void> load({force = false}) async {
    if (force) _ilp.value = null;
    if (_ilp.value != null) return;
    try {
      fileSize = File(file.path).statSync().size;
      final ilp = await ILP.fromFile(file.path);
      final header = await ilp.header;
      version = header.version;
      final name = header.name;
      final cover = await ilp.cover;
      final infos = await ilp.infos;

      _ilp.value = ilp;
      this.cover = cover;
      this.name = name;
      infoLength = infos.length;
      unlock =
          infos.map((e) => getIlpInfoUnlock(e)).toList().sum / infos.length;
      _exception.value = null;
    } on ILPConfigException catch (e) {
      _ilp.value = null;
      _exception.value = e;
    }
  }
}
