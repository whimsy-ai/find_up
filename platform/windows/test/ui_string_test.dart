import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    print('语言数量 ${UI.languages.length}');

    print(UI.languages.values.join('\n'));
  });
}
