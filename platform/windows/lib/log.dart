import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _format = DateFormat('y-MM-dd hh:mm:ss');

class _Log {
  final DateTime _time;
  final String text;

  const _Log(this.text, this._time);

  String get time => _format.format(_time);
}

class Log {
  static final list = RxList<_Log>();

  Log._();

  static void add(String log) {
    list.insert(0, _Log(log, DateTime.now()));
  }

  static clear() {
    list.clear();
  }
}
