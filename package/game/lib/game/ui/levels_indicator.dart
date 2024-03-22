import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../level.dart';
import '../level_controller.dart';

class LevelsIndicator<T extends LevelController> extends GetView<T> {
  final double itemSize;

  const LevelsIndicator({super.key, this.itemSize = 60});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: controller.levels
          .mapIndexed((index, e) => _level(context, index, e.state))
          .toList(),
    );
  }

  Widget _level(BuildContext context, int index, LevelState state) {
    final iconSize = itemSize / 1.2;
    Widget? icon = switch (state) {
      LevelState.completed => Icon(
          Icons.check_rounded,
          color: Colors.green,
          size: iconSize,
        ),
      LevelState.failed => Icon(
          Icons.close_rounded,
          color: Colors.red,
          size: iconSize,
        ),
      _ => null,
    };
    final double borderWidth = itemSize >= 60 ? 4 : 2;
    BoxBorder? border = switch (state) {
      LevelState.completed => Border.all(
          width: borderWidth,
          color: Colors.green,
          style: BorderStyle.solid,
        ),
      LevelState.failed => Border.all(
          width: borderWidth,
          color: Colors.red,
          style: BorderStyle.solid,
        ),
      _ => null,
    };
    final textColor =
        index == controller.current ? Colors.black87 : Colors.black26;
    const bgColor = Colors.white;
    return Container(
      width: itemSize,
      height: itemSize,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(itemSize)),
        border: border,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (icon != null) Positioned.fill(child: icon),
          Positioned.fill(
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: GoogleFonts.lilitaOne(
                  fontSize: itemSize / 1.5,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
