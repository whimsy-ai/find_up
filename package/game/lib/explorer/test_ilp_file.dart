import 'package:ilp_file_codec/ilp_codec.dart';

import 'file.dart';

class TestILPFile extends ExplorerFile {
  @override
  final ILP? ilp;

  TestILPFile({required this.ilp});

  @override
  Future<void> load({force = false}) => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
