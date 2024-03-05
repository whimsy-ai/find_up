import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../loading_controller.dart';

class SteamDownloadIndicator<T extends LoadingController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.steam),
            Expanded(
              child: _Pointer(padding: 10),
            ),
            Icon(FontAwesomeIcons.computer),
          ],
        ),
        SizedBox(height: 10),
        Text('${controller.downloadedPercent} %'),
      ],
    );
  }
}

class _Pointer extends StatefulWidget {
  final double padding;

  const _Pointer({super.key, required this.padding});

  @override
  State<_Pointer> createState() => _PointerState();
}

class _PointerState extends State<_Pointer> {
  double _percent = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        _percent = double.parse((_percent + 0.05).toStringAsFixed(2));
      });
      if (_percent > 1) _percent = 0;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: CustomPaint(
        painter: _Painter(percent: _percent, divide: 15),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final double percent;
  final double radius;
  final int divide;
  final Color normal, active;
  late final _normalPaint = Paint()..color = normal;
  late final _activePaint = Paint()..color = active;

  _Painter({
    required this.percent,
    this.normal = Colors.black45,
    this.active = Colors.blueAccent,
    this.radius = 3,
    this.divide = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = (size.width ~/ divide).ceil();
    final activePoint = (total * percent).ceil();
    for (var i = 0; i <= total; i++) {
      var isActive = i == activePoint;
      canvas.drawCircle(
        Offset((i * divide).toDouble() + divide / 2, size.height / 2),
        isActive ? radius + 2 : radius,
        isActive ? _activePaint : _normalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
