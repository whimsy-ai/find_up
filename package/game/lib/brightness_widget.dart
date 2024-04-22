import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data.dart';

class BrightnessWidget extends StatelessWidget {
  static final isDark = Get.isDarkMode.obs;
  final Widget Function(bool isDark, void Function() switcher) builder;

  BrightnessWidget({super.key, required this.builder});

  void switcher() {
    isDark.toggle();
    Data.isDark = isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) => Obx(
        () => builder(isDark.value, switcher),
      );
}
