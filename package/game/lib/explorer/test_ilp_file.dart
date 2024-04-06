import 'package:ilp_file_codec/ilp_codec.dart';

import 'file.dart';

class TestILPFile extends ExplorerFile {
  @override
  final ILP? ilp;

  TestILPFile({required this.ilp});

  @override
  Future<void> load({force = false}) => Future.value();

  @override
  get cover => throw UnimplementedError();

  @override
  int get fileSize => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  int get version => throw UnimplementedError();
}
