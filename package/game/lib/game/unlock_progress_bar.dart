import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:ui/ui.dart';

import '../convert_to_percentage.dart';
import '../get_ilp_info_unlock.dart';

class UnlockProgressBar extends StatelessWidget {
  final Color color;
  final double? width;
  final double height;
  final double value;

  UnlockProgressBar({
    super.key,
    this.width,
    double? height,
    this.color = Colors.blue,
    required double value,
  })  : height = height ?? 20,
        value = value.clamp(0.0, 1.0);

  factory UnlockProgressBar.byILPInfo(
    ILPInfo info, {
    double? width,
    double? height,
  }) {
    final v = getIlpInfoUnlock(info);
    return UnlockProgressBar(
      value: v,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      clipBehavior: Clip.antiAlias,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            SizedBox(height: height),
            LinearProgressIndicator(
              value: value,
              minHeight: height,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            Center(
              child: Text(
                '${UI.unlocked.tr} ${convertToPercentage(value)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return width == null
        ? child
        : SizedBox(
            width: width,
            child: child,
          );
  }
}
