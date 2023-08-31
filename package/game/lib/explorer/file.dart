import 'package:ilp_file_codec/ilp_codec.dart';

abstract class ExplorerFile {
  String get name;

  double get unlock;

  dynamic get cover;

  int get version;

  int get fileSize;

  ILP? get ilp;
}
