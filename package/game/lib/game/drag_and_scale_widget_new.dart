import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mouse_controller.dart';
import 'offset_scale_controller.dart';

typedef DragAndScaleBuilder = Widget Function(BuildContext context);

class NewDragAndScaleWidget<T extends OffsetScaleController>
    extends StatefulWidget {
  final bool debug;
  final double scaleStep;
  final DragAndScaleBuilder builder;

  const NewDragAndScaleWidget({
    super.key,
    required this.builder,
    this.scaleStep = 0.05,
    this.debug = false,
  });

  @override
  DragAndScaleWidgetState createState() => DragAndScaleWidgetState<T>();
}

class DragAndScaleWidgetState<T extends OffsetScaleController>
    extends State<NewDragAndScaleWidget> {
  final controller = Get.find<T>();
  Offset _eventPosition = Offset.zero;

  /// for scale delta
  double _lastScale = 1;

  reset() {
    setState(() {
      controller.resetScaleAndOffset();
      _lastScale = 1;
      _eventPosition = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _scaleStart,
      onScaleUpdate: _scaleUpdate,
      onDoubleTap: reset,
      child: widget.builder(context),
    );

    return GetPlatform.isMobile ? child : _forDesk(child);
  }

  /// 桌面平台
  Widget _forDesk(Widget child) {
    return Listener(
      /// 滚轮缩放
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          // final half = Get.width / 2;
          // final pos = event.localPosition;
          _eventPosition = controller.onScalePosition(event.localPosition);
          final isZoomIn = event.scrollDelta.dy > 0;
          final step = widget.scaleStep * (isZoomIn ? -1 : 1);
          _lastScale = controller.scale;
          controller.scale = (controller.scale + step)
              .clamp(controller.minScale, controller.maxScale);
          // print('滚轮 ${controller.scale}');
          _scaleOffset();
        }
      },
      child: child,
    );
  }

  void _scaleStart(ScaleStartDetails details) {
    _lastScale = 1;
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    // print('onScaleUpdate ${details.pointerCount}');
    controller.offsetX += details.focalPointDelta.dx;
    controller.offsetY += details.focalPointDelta.dy;

    /// 单指移动，包括鼠标
    if (details.pointerCount == 1 &&controller is MouseController) {
      (controller as MouseController).position += details.focalPointDelta;
    }

    /// 双指缩放
    else if (details.pointerCount == 2) {
      _eventPosition = controller.onScalePosition(details.localFocalPoint);
      // _eventPosition = widget.scaleEvent?.call(details.localFocalPoint) ??
      //     details.localFocalPoint;
      if (GetPlatform.isMobile) {
        /// todo
      }

      _lastScale = controller.scale;
      controller.scale = (controller.scale + (details.scale - _lastScale))
          .clamp(controller.minScale, controller.maxScale);
      // print('缩放 $_eventPosition');
      _scaleOffset();
    }
  }

  void _scaleOffset() {
    final original = Size(controller.width, controller.height);
    final oldSize = original * _lastScale;
    final newSize = original * controller.scale;
    final xRatio = ((_eventPosition.dx - controller.offsetX) / oldSize.width);
    final yRatio = ((_eventPosition.dy - controller.offsetY) / oldSize.height);

    controller.offsetX += (oldSize.width - newSize.width) * xRatio;
    controller.offsetY += (oldSize.height - newSize.height) * yRatio;
    controller.update(['ui']);
  }
}
