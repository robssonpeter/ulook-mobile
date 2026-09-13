import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A single continuous vine/paisley flourish — the yuluk mark. Drawn as one
/// open stroke so it can be animated as "ink being applied", and reused
/// statically (progress = 1) as the app icon glyph.
///
/// Coordinates are authored on a 100x100 box and scaled to [size].
Path buildHennaFlourishPath(Size size) {
  final s = size.width / 100;
  final path = Path()
    ..moveTo(22 * s, 76 * s)
    ..cubicTo(13 * s, 54 * s, 24 * s, 28 * s, 50 * s, 19 * s)
    ..cubicTo(69 * s, 12 * s, 87 * s, 22 * s, 83 * s, 39 * s)
    ..cubicTo(80.5 * s, 50 * s, 67 * s, 52 * s, 60 * s, 43 * s)
    ..cubicTo(55.5 * s, 37 * s, 59 * s, 29 * s, 66 * s, 31 * s)
    ..cubicTo(71 * s, 32.5 * s, 70 * s, 38 * s, 64.5 * s, 37.5 * s);
  return path;
}

class HennaFlourishPainter extends CustomPainter {
  final double progress;
  final double glowOpacity;
  final Color strokeColor;
  final Color glowColor;
  final double strokeWidth;

  HennaFlourishPainter({
    required this.progress,
    this.glowOpacity = 0,
    this.strokeColor = const Color(0xFFC99A3F),
    this.glowColor = const Color(0xFFC99A3F),
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = buildHennaFlourishPath(size);

    if (glowOpacity > 0) {
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(glowOpacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 28);
      canvas.drawCircle(
        Offset(size.width * 0.52, size.height * 0.45),
        size.width * 0.46,
        glowPaint,
      );
    }

    if (progress <= 0) return;

    final metric = fullPath.computeMetrics().first;
    final drawPath = metric.extractPath(0, metric.length * progress.clamp(0, 1));

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * (size.width / 100)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(drawPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant HennaFlourishPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.glowOpacity != glowOpacity ||
      oldDelegate.strokeColor != strokeColor;
}

/// Plays the flourish "drawing itself" once, with a soft glow washing in
/// behind it. Set [autoplay] to false to render the mark fully-drawn and
/// static (e.g. as a small logo elsewhere in the app).
class AnimatedHennaMark extends StatefulWidget {
  final double size;
  final Color strokeColor;
  final Color glowColor;
  final bool autoplay;
  final Duration duration;

  const AnimatedHennaMark({
    super.key,
    this.size = 96,
    this.strokeColor = const Color(0xFFC99A3F),
    this.glowColor = const Color(0xFFC99A3F),
    this.autoplay = true,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<AnimatedHennaMark> createState() => _AnimatedHennaMarkState();
}

class _AnimatedHennaMarkState extends State<AnimatedHennaMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _strokeProgress;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _strokeProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.85, curve: Curves.easeInOutCubic),
    );
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.22), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    ));
    if (widget.autoplay) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: HennaFlourishPainter(
            progress: widget.autoplay ? _strokeProgress.value : 1,
            glowOpacity: widget.autoplay ? _glowOpacity.value : 0,
            strokeColor: widget.strokeColor,
            glowColor: widget.glowColor,
          ),
        ),
      ),
    );
  }
}
