import 'package:flutter/material.dart';

/// One-shot fade + slide entrance. Plays once on first build.
/// Uses the Interval trick: total = [delay] + [duration], animation starts
/// at the fraction where [delay] ends, so the widget is invisible until then.
class AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideY;
  final double slideX;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.slideY = 22.0,
    this.slideX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final totalMs = delay.inMilliseconds + duration.inMilliseconds;
    final startFraction =
        totalMs > 0 ? delay.inMilliseconds / totalMs : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(startFraction, 1.0, curve: Curves.easeOutCubic),
      child: child,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(slideX * (1 - v), slideY * (1 - v)),
          child: child,
        ),
      ),
    );
  }
}

/// Scale + fade entrance — great for cards, stats, badges.
class AnimatedScaleEntrance extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double fromScale;

  const AnimatedScaleEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
    this.fromScale = 0.88,
  });

  @override
  Widget build(BuildContext context) {
    final totalMs = delay.inMilliseconds + duration.inMilliseconds;
    final startFraction =
        totalMs > 0 ? delay.inMilliseconds / totalMs : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(startFraction, 1.0, curve: Curves.easeOutBack),
      child: child,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: fromScale + (1.0 - fromScale) * v,
          child: child,
        ),
      ),
    );
  }
}
