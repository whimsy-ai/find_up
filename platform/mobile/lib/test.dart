import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State {
  final min = 0.5, max = 4.0;
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.network(
            'https://img1.baidu.com/it/u=1546227440,2897989905&fm=253&fmt=auto&app=138&f=JPEG?w=889&h=500',
            scale: 1 / _scale,
          ),
          Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Text('$_scale'),
                    Text('1 / $_scale = ${1 / _scale}'),
                    Slider(
                      min: min,
                      max: max,
                      value: _scale,
                      onChanged: (val) {
                        setState(() {
                          _scale = val;
                        });
                      },
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
