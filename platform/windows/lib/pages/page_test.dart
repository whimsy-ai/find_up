import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageTest extends StatelessWidget {
  final ConfettiController controller = ConfettiController(
    duration: Duration(milliseconds: 500),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          Positioned.fill(
            top: -150,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: controller,
                blastDirection: math.pi / 2,
                maxBlastForce: 50,
                // set a lower max blast force
                minBlastForce: 20,
                // set a lower min blast force
                emissionFrequency: 0.1,
                numberOfParticles: 20,
                gravity: 0.1,
                // a lot of particles at once
                colors: Colors.accents,
                blastDirectionality: BlastDirectionality.explosive,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('F'),
        onPressed: () {
          controller
            ..stop()
            ..play();
        },
      ),
    );
  }
}
