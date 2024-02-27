import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'ilp_editor_controller.dart';

class ILPInfoFile {
  final String file;
  final Rxn<ILPConfigException> _exception = Rxn();
  final Rxn<ILPInfoConfig> _config = Rxn();

  ILPInfoConfig? get config => _config.value;

  ILPConfigException? get exception => _exception.value;

  ILPInfoFile(this.file) {
    load();
  }

  load({force = false}) {
    if (force) _config.value = null;
    if (_config.value != null) return;
    try {
      _exception.value = null;
      _config.value = ILPInfoConfig.fromFileSync(file);
    } on ILPConfigException catch (e) {
      _config.value = null;
      _exception.value = e;
    }
    Get.find<ILPEditorController>().update([
      'cover',
    ]);
  }
}
