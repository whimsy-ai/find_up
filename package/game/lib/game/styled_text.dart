import 'dart:ui' as ui;

import 'package:flutter/material.dart';

///使用CustomPaint实现
class StyledText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;
  final Offset strokeOffset;

  const StyledText(
    this.text, {
    super.key,
    required this.style,
    required this.strokeWidth,
    required this.strokeColor,
    required this.strokeOffset,
  });

  @override
  Widget build(BuildContext context) {
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: style.fontFamily,
          fontSize: style.fontSize,
          letterSpacing: style.letterSpacing,
          wordSpacing: style.wordSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = painter.width + strokeOffset.dx,
        h = painter.height + strokeOffset.dy;
    painter.dispose();
    return CustomPaint(
      size: Size(w, h),
      painter: _Painter(
        txtWidth: w,
        text: text,
        style: style,
        strokeOffset: strokeOffset,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;
  final Offset strokeOffset;
  final double txtWidth;

  _Painter({
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
    /// layer 0
    var layer = _paragraphBuilder(true);
    canvas.drawParagraph(layer, strokeOffset);
    canvas.drawParagraph(layer, strokeOffset - Offset(0, 1));
    canvas.drawParagraph(layer, Offset.zero);

    /// layer 2
    canvas.drawParagraph(_paragraphBuilder(false), Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

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
