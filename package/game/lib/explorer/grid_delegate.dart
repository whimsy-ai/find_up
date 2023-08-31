import 'package:flutter/rendering.dart';

class SliverGridDelegateWithFixedSize extends SliverGridDelegate {
  final double width;
  final double height;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  SliverGridDelegateWithFixedSize({
    required this.width,
    required this.height,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    int crossAxisCount = constraints.crossAxisExtent ~/ width;
    double spacing = (constraints.crossAxisExtent - width * crossAxisCount) /
        (crossAxisCount - 1);

    while (spacing < crossAxisSpacing) {
      crossAxisCount -= 1;
      spacing = (constraints.crossAxisExtent - width * crossAxisCount) /
          (crossAxisCount - 1);
    }

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: height + mainAxisSpacing,
      crossAxisStride: width + crossAxisSpacing,
      childMainAxisExtent: height,
      childCrossAxisExtent: width,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedSize oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing;
  }
}
