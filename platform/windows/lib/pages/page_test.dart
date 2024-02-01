import 'package:borders/borders.dart';
import 'package:flutter/material.dart';
import 'package:game/game/stroke_shadow.dart';
import 'package:game/game/ui/my_trapezium_border.dart';

class PageTest extends StatefulWidget {
  @override
  State<PageTest> createState() => _PageTestState();
}

class _PageTestState extends State<PageTest> {
  final _shadow = GlobalKey();
  var index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test')),
      body: Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: ShapeDecoration(
            color: Colors.black12.withOpacity(0.6),
            shape: MyTrapeziumBorder(
              w: 1,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
                bottom: Radius.circular(30),
              ),
              borderOffset: BorderOffset.vertical(
                bottom: Offset(10, 0),
              ),
            ),
          ),
          child: StrokeShadow.text('hi'),
        ),
      ),
    );
  }
}
