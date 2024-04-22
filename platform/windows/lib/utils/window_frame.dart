import 'dart:ui';

import 'package:flutter/material.dart';

import 'top_bar.dart';

const double kTopBarHeight = 40;

class WindowFrame extends StatelessWidget {
  final Widget child;
  final bool pinTopBar;
  final String? title;
  final bool brightness;
  final bool settings;
  final bool backIcon;
  final List<Widget>? icons;

  const WindowFrame({
    super.key,
    required this.child,
    this.pinTopBar = true,
    this.title,
    this.brightness = true,
    this.settings = true,
    this.backIcon = true,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    Widget topBar = SizedBox(
      height: kTopBarHeight,
      child: TopBar(
        title: title,
        brightness: brightness,
        settings: settings,
        back: backIcon,
        icons: icons,
      ),
    );
    Widget body;
    if (pinTopBar) {
      body = Column(
        children: [
          topBar,
          Divider(height: 1),
          Expanded(child: child),
        ],
      );
    } else {
      body = Stack(
        children: [
          /// 内容垫底
          Positioned.fill(child: child),

          /// 标题栏
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: topBar,
              ),
            ),
          ),
        ],
      );
    }
    return Scaffold(body: body);
  }
}
