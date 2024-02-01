import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Stroke {
  final double width;
  final Color color;
  final Offset offset;

  Stroke({
    required this.width,
    required this.color,
    this.offset = Offset.zero,
  });
}

class StrokeShadow extends StatelessWidget {
  final String? _text;
  final Path? _path;
  final Color? pathColor;
  final TextStyle? style;
  final Stroke? stroke;

  const StrokeShadow._({
    super.key,
    String? text,
    Path? path,
    this.pathColor,
    this.style,
    this.stroke,
  })  : _text = text,
        _path = path;

  static Widget text(
    String text, {
    TextStyle? style,
    Stroke? stroke,
  }) {
    style ??= DefaultTextStyle.of(Get.context!).style;
    return StrokeShadow._(
      text: text,
      stroke: stroke,
      style: style,
    );
  }

  static Widget path(
    Path path, {
    double? size,
    Color? color,
    Stroke? stroke,
  }) {
    color ??= Theme.of(Get.context!).textTheme.displayMedium!.color;
    final child = StrokeShadow._(
      path: path,
      pathColor: color,
      stroke: stroke,
    );
    return size != null
        ? SizedBox(width: size, height: size, child: child)
        : child;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        late double w, h, tightW, tightH;
        final strokeWidth = stroke?.width ?? 0;
        final strokeOffset = stroke?.offset ?? Offset.zero;
        final strokeColor = stroke?.color ?? Colors.black;
        if (_text != null) {
          TextPainter painter = TextPainter(
            text: TextSpan(text: _text, style: style),
            textDirection: TextDirection.ltr,
          )..layout();
          w = painter.width + strokeWidth + strokeOffset.dx;
          h = painter.height + strokeWidth + strokeOffset.dy;
          painter.dispose();
        } else {
          final rect = _path!.getBounds();
          w = rect.width + strokeWidth + strokeOffset.dx;
          h = rect.height + strokeWidth + strokeOffset.dy;
        }
        if (constraint.isTight) {
          tightW = constraint.constrainWidth();
          tightH = constraint.constrainHeight();
        } else {
          tightW = w;
          tightH = h;
        }
        return CustomPaint(
          size: Size(tightW, tightH),
          painter: _text != null
              ? _TextPainter(
                  txtWidth: w,
                  text: _text!,
                  style: style!,
                  strokeOffset: strokeOffset,
                  strokeColor: strokeColor,
                  strokeWidth: strokeWidth,
                )
              : _PathPainter(
                  width: w,
                  height: h,
                  path: _path!,
                  pathColor: pathColor!,
                  strokeOffset: strokeOffset,
                  strokeColor: strokeColor,
                  strokeWidth: strokeWidth,
                ),
        );
      },
    );
  }
}

class _TextPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;
  final Offset strokeOffset;
  final double txtWidth;

  _TextPainter({
    super.repaint,
    required this.text,
    required this.txtWidth,
    required this.style,
    required this.strokeWidth,
    required this.strokeColor,
    required this.strokeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth > 0) {
      /// layer 0
      var layer = _paragraphBuilder(true);
      canvas.drawParagraph(layer, strokeOffset);
      canvas.drawParagraph(layer, strokeOffset - Offset(0, 1));
      canvas.drawParagraph(layer, Offset.zero);
    }

    /// layer 2
    canvas.drawParagraph(_paragraphBuilder(false), Offset.zero);
  }

  @override
  bool shouldRepaint(_TextPainter oldDelegate) => true;

  ui.Paragraph _paragraphBuilder(bool isStroke) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
    ui.TextStyle style;
    if (isStroke) {
      style = ui.TextStyle(
        fontSize: this.style.fontSize,
        fontFamily: this.style.fontFamily,
        letterSpacing: this.style.letterSpacing,
        wordSpacing: this.style.wordSpacing,
        foreground: Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
      );
    } else {
      style = ui.TextStyle(
        fontSize: this.style.fontSize,
        fontFamily: this.style.fontFamily,
        letterSpacing: this.style.letterSpacing,
        wordSpacing: this.style.wordSpacing,
        color: this.style.color,
      );
    }
    builder
      ..pushStyle(style)
      ..addText(text);
    final constraints = ui.ParagraphConstraints(width: txtWidth);
    return builder.build()..layout(constraints);
  }
}

class _PathPainter extends CustomPainter {
  static double _standardWidth = 513;
  final Path path;
  final double width, height;
  final double strokeWidth;
  final Color strokeColor, pathColor;
  final Offset strokeOffset;

  _PathPainter({
    super.repaint,
    required this.path,
    required this.width,
    required this.height,
    required this.pathColor,
    required this.strokeWidth,
    required this.strokeOffset,
    required this.strokeColor,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    double scale = math.min(
        math.min(size.width, _standardWidth) /
            math.max(size.width, _standardWidth),
        math.min(size.height, _standardWidth) /
            math.max(size.height, _standardWidth));
    final transform = Matrix4.identity()..scale(scale);
    var path = this.path.transform(transform.storage);

    if (strokeWidth != 0) {
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      /// shadow
      canvas.drawPath(path.shift(strokeOffset), strokePaint);
      canvas.drawPath(path.shift((strokeOffset - Offset(0, 1))), strokePaint);

      /// outline
      canvas.drawPath(path, strokePaint);
    }

    /// raw path
    canvas.drawPath(path, Paint()..color = pathColor);
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) {
    // print('path shouldRepaint ${oldDelegate.path != path}');
    return oldDelegate.path != path;
  }
}
