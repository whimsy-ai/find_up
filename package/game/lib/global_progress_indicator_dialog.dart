import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui.dart';

class GlobalProgressIndicatorDialog extends StatelessWidget {
  final String text;

  const GlobalProgressIndicatorDialog._(this.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: 20),
          Text(text),
        ],
      ),
    );
  }

  static Future show([String? text]) {
    return Get.dialog(
      GlobalProgressIndicatorDialog._(text ?? UI.wait.tr),
      barrierDismissible: false,
    );
  }
}
