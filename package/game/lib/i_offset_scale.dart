import 'package:get/get.dart';

abstract class IOffsetScaleController extends GetxController {
  static const double padding = 50;
  double offsetX = 0, offsetY = 0, scale = 1;

  double get minScale;

  double get maxScale;

  void resetScaleAndOffset();
}
