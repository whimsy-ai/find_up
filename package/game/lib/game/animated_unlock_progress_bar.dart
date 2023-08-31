import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'unlock_progress_bar.dart';

var _playing = false;

_playConfetti(
  BuildContext context,
  Duration duration, {
  double gravity = 0.1,
}) async {
  if (_playing) return;
  _playing = true;
  final controller = ConfettiController(duration: duration);
  final entry = OverlayEntry(
    builder: (_) {
      return Positioned.fill(
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
            gravity: gravity,
            colors: Colors.accents,
            blastDirectionality: BlastDirectionality.explosive,
          ),
        ),
      );
    },
  );
  Overlay.of(context).insert(entry);
  controller
    ..play()
    ..addListener(() {
      if (controller.state == ConfettiControllerState.stopped) {
        _playing = false;
      }
    });
}

class AnimatedUnlockProgressBar extends StatelessWidget {
  final double? width;
  final double height;
  final double from, to;
  final Duration duration;
  final bool showConfetti;
  final String text;

  AnimatedUnlockProgressBar({
    super.key,
    required this.text,
    this.width,
    double? height,
    double from = 0,
    required double to,
    this.showConfetti = false,
    this.duration = const Duration(milliseconds: 500),
  })  : height = height ?? 20,
        from = from.clamp(0.0, 1.0),
        to = to.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    if (showConfetti) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _playConfetti(context, duration);
      });
    }
    final child = TweenAnimationBuilder(
      duration: duration,
      tween: Tween<double>(
        begin: from,
        end: to,
      ),
      builder: (ctx, value, _) => UnlockProgressBar(
        width: width,
        value: value,
        text: text,
      ),
    );
    return !showConfetti
        ? child
        : GestureDetector(
            onTap: () => _playConfetti(context, duration),
            child: child,
          );
  }
}
