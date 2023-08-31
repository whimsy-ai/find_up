import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:ilp_file_codec/ilp_codec.dart';

import 'canvas.dart';

class DragAndScaleWidget extends StatefulWidget {
  final ILPLayer layer;
  final List<ILayerBuilder> layers;
  final bool debug;
  final double scaleStep;
  final double minScale;
  final double maxScale;

  const DragAndScaleWidget({
    super.key,
    required this.layer,
    required this.layers,
    this.scaleStep = 0.05,
    this.minScale = 0.2,
    this.maxScale = 4.0,
    this.debug = false,
  });

  @override
  DragAndScaleWidgetState createState() => DragAndScaleWidgetState();
}

class DragAndScaleWidgetState extends State<DragAndScaleWidget> {
  late Rect _moveBounds,
      _real = Rect.fromLTWH(
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
      _shift(Offset.zero);
      _scaleOffset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layers.isEmpty) return SizedBox.expand();
    Widget child = Row(
      children: [
        _halfWidget(LayerLayout.left),
        VerticalDivider(width: 2),
        _halfWidget(LayerLayout.right),
      ],
    );
    return GetPlatform.isMobile
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _scaleStart,
            onScaleUpdate: _scaleUpdate,
            onDoubleTap: reset,
            child: child,
          )
        : child;
  }

  Widget _halfWidget(LayerLayout layout) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constrains) {
          _moveBounds = Rect.fromLTWH(
            50,
            50,
            constrains.biggest.width - 100,
            constrains.biggest.height - 100,
          );
          Widget child = ILPCanvas(
            layout: layout,
            scale: _scale,
            layers: widget.layers,
            offsetX: _offsetX,
            offsetY: _offsetY,
            debug: widget.debug,
          );
          return GetPlatform.isMobile ? child : _forMouse(child);
        },
      ),
    );
  }

  /// 桌面平台
  Widget _forMouse(Widget child) {
    return Listener(
      /// 滚轮缩放
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _eventPosition = event.localPosition;
          final isZoomIn = event.scrollDelta.dy > 0;
          _scale = (_scale + (isZoomIn ? widget.scaleStep : -widget.scaleStep))
              .clamp(widget.minScale, widget.maxScale);
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
    if (details.pointerCount == 1) {
      // print('移动');
      final newRect = _real.shift(details.focalPointDelta);

      /// 不超出范围就移动内容
      if (_moveBounds.overlaps(newRect)) {
        setState(() {
          _real = newRect;
          _shift(details.focalPointDelta);
        });
      }
    } else if (details.pointerCount == 2) {
      _eventPosition = details.localFocalPoint;
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

  void _shift(Offset delta) {}
}
