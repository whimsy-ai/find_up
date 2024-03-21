import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    double l = -5, t = 0, w = 10, h = 0;
    final rect = Rect.fromLTWH(l, t, w, h);
    print(rect.right);
  });
}
