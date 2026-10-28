import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A quiet broadcast-style Republic Day ident, confined to the home page.
class RepublicDayBanner extends StatefulWidget {
  const RepublicDayBanner({super.key});

  @override
  State<RepublicDayBanner> createState() => _RepublicDayBannerState();
}

class _RepublicDayBannerState extends State<RepublicDayBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: '29 Ekim Cumhuriyet Bayramımız kutlu olsun. 1923, sonsuza dek.',
        child: ExcludeSemantics(
            child: Container(
          height: 68,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xFF650A19), Color(0xFFBC1530), Color(0xFF790C20)],
          )),
          child: LayoutBuilder(
              builder: (context, constraints) => Center(
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                              animation: _motion,
                              builder: (context, _) => Transform(
                                    alignment: Alignment.centerLeft,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(math.sin(
                                              _motion.value * math.pi * 2) *
                                          0.14),
                                    child: CustomPaint(
                                        size: const Size(78, 52),
                                        painter: TurkishFlagPainter(
                                            phase: _motion.value)),
                                  )),
                          const SizedBox(width: 16),
                          const Text('29',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  height: 1)),
                          const SizedBox(width: 9),
                          const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('EKİM',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        letterSpacing: 4)),
                                Text('CUMHURİYET BAYRAMIMIZ KUTLU OLSUN',
                                    style: TextStyle(
                                        color: Color(0xFFFFE4D8),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5)),
                              ]),
                          if (constraints.maxWidth > 640) ...[
                            const SizedBox(width: 32),
                            const Text('1923 — SONSUZA DEK',
                                style: TextStyle(
                                    color: Color(0xFFFFD9B0),
                                    fontSize: 11,
                                    letterSpacing: 2)),
                          ],
                        ],
                      )))),
        )),
      );
}

class TurkishFlagPainter extends CustomPainter {
  const TurkishFlagPainter({this.phase = 0});
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 150, size.height / 100);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 150, 100),
        Paint()..color = const Color(0xFFE30A17));
    final crescent = Path.combine(
        PathOperation.difference,
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 25)),
        Path()
          ..addOval(
              Rect.fromCircle(center: const Offset(56.25, 50), radius: 20)));
    canvas.drawPath(crescent, Paint()..color = Colors.white);
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + math.pi / 10 + i * math.pi / 5;
      final radius = i.isEven ? 12.5 : 4.775;
      final point =
          Offset(86 + math.cos(angle) * radius, 50 + math.sin(angle) * radius);
      if (i == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(star..close(), Paint()..color = Colors.white);
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, 150, 100),
        Paint()
          ..shader = LinearGradient(
              begin: Alignment(-1 + phase * 2, -1),
              end: Alignment(1 + phase * 2, 1),
              colors: const [
                Color(0x30000000),
                Color(0x18FFFFFF),
                Color(0x30000000)
              ]).createShader(const Rect.fromLTWH(0, 0, 150, 100)));
    canvas.restore();
  }

  @override
  bool shouldRepaint(TurkishFlagPainter oldDelegate) =>
      phase != oldDelegate.phase;
}
