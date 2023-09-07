import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'canvas.dart';

typedef DragAndScaleBuilder = Widget Function(
  BuildContext context, {
  required double scale,
  required double minScale,
  required double maxScale,
  required double x,
  required double y,
});

class DragAndScaleWidget extends StatefulWidget {
  final ILPLayer layer;
  final List<ILayerBuilder> layers;
  final bool debug;
  final double scaleStep;
  final double minScale;
  final double maxScale;
  final DragAndScaleBuilder builder;
  final Offset Function(Offset original)? scaleEvent;

  const DragAndScaleWidget({
    super.key,
    required this.layer,
    required this.layers,
    required this.builder,
    required this.minScale,
    this.scaleEvent,
    this.scaleStep = 0.05,
    this.maxScale = 4.0,
    this.debug = false,
  });

  @override
  DragAndScaleWidgetState createState() => DragAndScaleWidgetState();
}

class DragAndScaleWidgetState extends State<DragAndScaleWidget> {
  late Rect _real = Rect.fromLTWH(
    0,
    0,
    widget.layer.width.toDouble(),
    widget.layer.height.toDouble(),
  );
  Offset _eventPosition = Offset.zero;
  double _offsetX = 0, _offsetY = 0, _scale = 1;

  /// for scale delta
  double _lastScale = 1;

  reset() {
    setState(() {
      _offsetX = _offsetY = 0;
      _scale = 1;
      _real = Rect.fromLTWH(
        0,
        0,
        widget.layer.width.toDouble(),
        widget.layer.height.toDouble(),
      );
      _scaleOffset();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.builder(
      context,
      scale: _scale,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      x: _offsetX,
      y: _offsetY,
    );

    return GetPlatform.isMobile
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _scaleStart,
            onScaleUpdate: _scaleUpdate,
            onDoubleTap: reset,
            child: child,
          )
        : _forMouse(child);
  }

  // Widget _halfWidget(LayerLayout layout) {
  //   return Expanded(
  //     child: LayoutBuilder(
  //       builder: (context, constrains) {
  //         _moveBounds = Rect.fromLTWH(
  //           50,
  //           50,
  //           constrains.biggest.width - 100,
  //           constrains.biggest.height - 100,
  //         );
  //         Widget child = ILPCanvas(
  //           layout: layout,
  //           scale: _scale,
  //           layers: widget.layers,
  //           offsetX: _offsetX,
  //           offsetY: _offsetY,
  //           debug: widget.debug,
  //         );
  //         return GetPlatform.isMobile ? child : _forMouse(child);
  //       },
  //     ),
  //   );
  // }

  /// 桌面平台
  Widget _forMouse(Widget child) {
    return Listener(
      /// 滚轮缩放
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final half = Get.width / 2;
          final pos = event.localPosition;
          _eventPosition = widget.scaleEvent?.call(event.localPosition) ??
              event.localPosition;
          final isZoomIn = event.scrollDelta.dy > 0;
          final step = widget.scaleStep * (isZoomIn ? 1 : -1);
          _scale = (_scale + step).clamp(widget.minScale, widget.maxScale);
          _scaleOffset();
        }
      },

      /// 鼠标移动
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onDoubleTap: reset,
        child: child,
      ),
    );
  }

  void _scaleStart(ScaleStartDetails details) {
    _lastScale = 1;
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    // print('onScaleUpdate ${details.pointerCount}');
    _offsetX += details.focalPointDelta.dx;
    _offsetY += details.focalPointDelta.dy;

    /// 单指移动，包括鼠标
    if (details.pointerCount == 1) {
      _eventPosition = details.focalPoint;
      // print('鼠标移动');
      final newRect = _real.shift(details.focalPointDelta);

      setState(() {
        _real = newRect;
      });
    }

    /// 双指缩放
    else if (details.pointerCount == 2) {
      _eventPosition = widget.scaleEvent?.call(details.localFocalPoint) ??
          details.localFocalPoint;
      if (GetPlatform.isMobile) {
        /// todo
      }

      _scale = (_scale + (details.scale - _lastScale))
          .clamp(widget.minScale, widget.maxScale);
      // print('缩放 $_eventPosition');
      _scaleOffset();
      _lastScale = details.scale;
    }
  }

  void _scaleOffset() {
    // print('_scaleOffset $_scale');
    final newWidth = widget.layer.width * _scale;
    final newHeight = widget.layer.height * _scale;
    final xRatio = ((_eventPosition.dx - _offsetX) / _real.width);
    final yRatio = ((_eventPosition.dy - _offsetY) / _real.height);
    setState(() {
      _offsetX += (_real.width - newWidth) * xRatio;
      _offsetY += (_real.height - newHeight) * yRatio;

      _real = Rect.fromLTWH(
        _offsetX,
        _offsetY,
        newWidth,
        newHeight,
      );
    });
  }
}
