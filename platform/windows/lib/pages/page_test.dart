import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:game/game/mask_widget.dart';
import 'package:window_manager/window_manager.dart';

class PageTest extends StatefulWidget {
  @override
  State<PageTest> createState() => _PageTestState();
}

class _PageTestState extends State<PageTest> with WindowListener {
  final _buttonKey = GlobalKey();
  double _opacity = 0.4, _x = 0, _y = 0,_scale =1;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test')),
      backgroundColor: Colors.blueGrey,
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Text('透明度'),
                Slider(
                  value: _opacity,
                  min: 0.2,
                  max: 1,
                  onChanged: (val) {
                    setState(() {
                      _opacity = val;
                    });
                  },
                ),
                SizedBox(height: 20),
                Text('x 偏移 $_x'),
                Slider(
                  value: _x,
                  min: -100,
                  max: 100,
                  onChanged: (val) {
                    setState(() {
                      _x = val.ceilToDouble();
                    });
                  },
                ),
                Text('y 偏移 $_y'),
                Slider(
                  value: _y,
                  min: -100,
                  max: 100,
                  onChanged: (val) {
                    setState(() {
                      _y = val.ceilToDouble();
                    });
                  },
                ),
                SizedBox(height: 20),
                Text('缩放 $_scale'),
                Slider(
                  value: _scale,
                  min: 1,
                  max: 5,
                  onChanged: (val) {
                    setState(() {
                      _scale = val.ceilToDouble();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  return Mask(
                    scale: _scale,
                    data: MaskData(
                      color: Colors.black.withOpacity(_opacity),
                      radius: 70,
                      center: Offset(
                        constraints.maxWidth / 2 + _x,
                        constraints.maxHeight / 2 + _y,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _tapUp(TapUpDetails details) async {
    final RenderObject? renderObject =
        _buttonKey.currentContext?.findRenderObject();
    final RenderBox? renderBox =
        renderObject is RenderBox ? renderObject : null;
    final hitTestResult = BoxHitTestResult();
    renderBox?.hitTest(hitTestResult,
        position: Offset(renderBox.size.width / 2, renderBox.size.height / 2));

    //get BoxHitTestEntry

    BoxHitTestEntry entry = hitTestResult.path
        .firstWhere((element) => element is BoxHitTestEntry) as BoxHitTestEntry;

    //create Events and get GestureBinding Instance

    GestureBinding instance = GestureBinding.instance;
    var event2 = PointerUpEvent(
        position: renderBox!.localToGlobal(
            Offset(renderBox.size.width / 2, renderBox.size.height / 2)));

    //dispatch and handle events using GestureBinding

    instance.dispatchEvent(event2, hitTestResult);
    instance.handleEvent(event2, entry);
  }
}
