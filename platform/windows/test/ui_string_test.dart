import 'package:flutter_test/flutter_test.dart';
import 'package:windows/ui.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final ui = WindowsUI();
    final en = ui.keys['en_US']!;
    final cn = ui.keys['zh_CN']!;
    expect(en.keys, cn.keys);
  });
}
