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

enum AiLoadStyle { dots, lines, pulse }

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
          },
        ),
        const SizedBox(height: 24),
        _buildMessage(dotColor),
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

// ── Dots (ChatGPT-style) ────────────────────────

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
          children: List.generate(3, (i) {
            final t = (controller.value + i * 0.18) % 1.0;
            final bounce = _bounceOut(t);
            final scale = 1.0 - 0.25 * bounce;
            final alpha = 0.5 + 0.5 * (1.0 - bounce);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Transform.translate(
                offset: Offset(0, -bounce * 28),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: alpha),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _bounceOut(double t) {
    if (t < 0.5) {
      final p = t / 0.5;
      return p * p * (3 - 2 * p);
    }
    final p = (t - 0.5) / 0.5;
    return 1.0 - p * p * (3 - 2 * p);
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
