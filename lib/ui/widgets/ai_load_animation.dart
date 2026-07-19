import 'dart:math' as math;

import 'package:flutter/material.dart';

class AiLoadAnimation extends StatefulWidget {
  const AiLoadAnimation({
    super.key,
    this.message = 'Oluşturuluyor...',
    this.size = 100,
    this.style = AiLoadStyle.dots,
  });

  final String message;
  final double size;
  final AiLoadStyle style;

  @override
  State<AiLoadAnimation> createState() => _AiLoadAnimationState();
}

enum AiLoadStyle { dots, lines, pulse, spinningLight }

class _AiLoadAnimationState extends State<AiLoadAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? Colors.white : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: switch (widget.style) {
            AiLoadStyle.dots => _DotsWidget(
                controller: _controller,
                color: dotColor,
              ),
            AiLoadStyle.lines => _LinesWidget(
                controller: _controller,
                color: dotColor,
              ),
            AiLoadStyle.pulse => _PulseWidget(
                controller: _controller,
                color: dotColor,
              ),
            AiLoadStyle.spinningLight => _SpinningLightWidget(
                controller: _controller,
                color: dotColor,
              ),
          },
        ),
        if (widget.message.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildMessage(dotColor),
        ],
      ],
    );
  }

  Widget _buildMessage(Color dotColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(_controller.value * math.pi * 2));
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              Text(
                widget.message,
                style: TextStyle(
                  color: dotColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lütfen bekleyin',
                style: TextStyle(
                  color: dotColor.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Dots (Professional wave) ───────────────────

class _DotsWidget extends StatelessWidget {
  const _DotsWidget({
    required this.controller,
    required this.color,
  });

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final t = (controller.value - i * 0.15) % 1.0;
            final bell = t < 0.5 ? t / 0.5 : (1.0 - t) / 0.5;
            final ease = bell * bell * (3 - 2 * bell);
            final scale = 0.3 + 0.7 * ease;
            final alpha = 0.1 + 0.9 * ease;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                width: 10 * scale,
                height: 10 * scale,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: alpha),
                  shape: BoxShape.circle,
                  boxShadow: ease > 0.6
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: ease * 0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Lines (Claude-style) ────────────────────────

class _LinesWidget extends StatelessWidget {
  const _LinesWidget({
    required this.controller,
    required this.color,
  });

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final phase = i / 5;
              final raw = (controller.value - phase + 1.0) % 1.0;
              final progress = 1.0 - (raw - 0.5).abs() * 2.0;
              final ease = progress.clamp(0.0, 1.0);
              final ease2 = ease * ease * (3 - 2 * ease);

              final barHeight = 12.0 + ease2 * 36;
              final alpha = 0.15 + 0.85 * ease2;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 5,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: alpha),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ── Spinning Light ────────────────────────

class _SpinningLightWidget extends StatelessWidget {
  const _SpinningLightWidget({
    required this.controller,
    required this.color,
  });

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final angle = controller.value * 2 * math.pi;

        return Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding ring pulses
                ...List.generate(3, (i) {
                  final t = (controller.value + i * 0.33) % 1.0;
                  final r = 10 + t * 30;
                  final alpha = (1.0 - t) * 0.25;
                  return Container(
                    width: r * 2,
                    height: r * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: alpha),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
                // Rotating light beam
                Transform.rotate(
                  angle: angle,
                  child: CustomPaint(
                    size: const Size(80, 80),
                    painter: _LightSweepPainter(color: color),
                  ),
                ),
                // Glow behind center
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
                // Center light orb
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        color.withValues(alpha: 0.8),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LightSweepPainter extends CustomPainter {
  final Color color;

  _LightSweepPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: -0.15,
        endAngle: 0.15,
        center: Alignment.center,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    final edgePaint = Paint()
      ..shader = SweepGradient(
        startAngle: -0.15,
        endAngle: -0.05,
        center: Alignment.center,
        colors: [
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, edgePaint);

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius * 0.85, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _LightSweepPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ── Pulse (Gemini-style) ────────────────────────

class _PulseWidget extends StatelessWidget {
  const _PulseWidget({
    required this.controller,
    required this.color,
  });

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(4, (i) {
                final t = (controller.value + i * 0.25) % 1.0;
                final r = t * 40;
                final alpha = (1.0 - t) * 0.4;
                final stroke = 1.5 + (1.0 - t) * 1.5;

                return Container(
                  width: r * 2,
                  height: r * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: alpha),
                      width: stroke,
                    ),
                  ),
                );
              }),
              Container(
                width: 6 + 2 * math.sin(controller.value * math.pi * 2),
                height: 6 + 2 * math.sin(controller.value * math.pi * 2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
