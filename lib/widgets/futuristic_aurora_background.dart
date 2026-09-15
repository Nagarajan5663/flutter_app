import 'dart:math' as math;

import 'package:flutter/material.dart';

class FuturisticAuroraBackground extends StatefulWidget {
  final Widget child;

  const FuturisticAuroraBackground({
    super.key,
    required this.child,
  });

  @override
  State<FuturisticAuroraBackground> createState() =>
      _FuturisticAuroraBackgroundState();
}

class _FuturisticAuroraBackgroundState
    extends State<FuturisticAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020712),
            Color(0xFF06101F),
            Color(0xFF0A1730),
            Color(0xFF040814),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ============================================================
          // AURORA WAVES
          // ============================================================

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AuroraPainter(
                  animation: _controller,
                ),
              ),
            ),
          ),

          // ============================================================
          // MOVING LIGHT ORBS
          // ============================================================

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (
                  context,
                  child,
                ) {
                  final t =
                      _controller.value *
                          math.pi *
                          2;

                  return Stack(
                    children: [
                      Positioned(
                        top:
                            30 +
                            math.sin(t) *
                                35,
                        left:
                            20 +
                            math.cos(
                                  t * 0.8,
                                ) *
                                35,
                        child: const _GlowOrb(
                          size: 360,
                          color:
                              Color(
                                0xFF008CFF,
                              ),
                          opacity:
                              0.14,
                        ),
                      ),

                      Positioned(
                        right:
                            10 +
                            math.sin(
                                  t * 0.7,
                                ) *
                                35,
                        top:
                            140 +
                            math.cos(
                                  t * 0.9,
                                ) *
                                35,
                        child: const _GlowOrb(
                          size: 420,
                          color:
                              Color(
                                0xFF765CFF,
                              ),
                          opacity:
                              0.12,
                        ),
                      ),

                      Positioned(
                        left:
                            220 +
                            math.sin(
                                  t * 0.55,
                                ) *
                                30,
                        bottom:
                            40 +
                            math.cos(
                                  t * 0.65,
                                ) *
                                35,
                        child: const _GlowOrb(
                          size: 290,
                          color:
                              Color(
                                0xFFD4AF37,
                              ),
                          opacity:
                              0.06,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ============================================================
          // VIGNETTE
          // ============================================================

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center:
                        Alignment.center,
                    radius: 1.08,
                    colors: [
                      Colors.transparent,
                      Colors.black
                          .withOpacity(
                            0.06,
                          ),
                      Colors.black
                          .withOpacity(
                            0.38,
                          ),
                    ],
                    stops: const [
                      0.25,
                      0.72,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),

          widget.child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(
              opacity,
            ),
            color.withOpacity(
              opacity * 0.35,
            ),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _AuroraPainter
    extends CustomPainter {
  final Animation<double> animation;

  _AuroraPainter({
    required this.animation,
  }) : super(
          repaint: animation,
        );

  static const Color blue =
      Color(
        0xFF119DFF,
      );

  static const Color cyan =
      Color(
        0xFF00D9FF,
      );

  static const Color violet =
      Color(
        0xFF765CFF,
      );

  static const Color purple =
      Color(
        0xFFA147FF,
      );

  static const Color pink =
      Color(
        0xFFFF4FCB,
      );

  static const Color gold =
      Color(
        0xFFD4AF37,
      );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final phase =
        animation.value *
        math.pi *
        2;

    // BLUE / CYAN WAVE

    _drawRibbon(
      canvas: canvas,
      size: size,
      baseY:
          size.height * 0.17,
      amplitude: 55,
      frequency: 1.0,
      phase:
          phase * 0.65,
      thickness: 125,
      colors: [
        Colors.transparent,
        cyan.withOpacity(
          0.22,
        ),
        blue.withOpacity(
          0.28,
        ),
        violet.withOpacity(
          0.18,
        ),
        Colors.transparent,
      ],
    );

    // VIOLET / PURPLE WAVE

    _drawRibbon(
      canvas: canvas,
      size: size,
      baseY:
          size.height * 0.43,
      amplitude: 75,
      frequency: 0.88,
      phase:
          -phase * 0.50 +
          1.4,
      thickness: 160,
      colors: [
        Colors.transparent,
        violet.withOpacity(
          0.22,
        ),
        purple.withOpacity(
          0.20,
        ),
        pink.withOpacity(
          0.09,
        ),
        Colors.transparent,
      ],
    );

    // LOWER BLUE / GOLD WAVE

    _drawRibbon(
      canvas: canvas,
      size: size,
      baseY:
          size.height * 0.76,
      amplitude: 62,
      frequency: 1.10,
      phase:
          phase * 0.42 +
          2.3,
      thickness: 120,
      colors: [
        Colors.transparent,
        blue.withOpacity(
          0.14,
        ),
        violet.withOpacity(
          0.15,
        ),
        gold.withOpacity(
          0.08,
        ),
        Colors.transparent,
      ],
    );
  }

  void _drawRibbon({
    required Canvas canvas,
    required Size size,
    required double baseY,
    required double amplitude,
    required double frequency,
    required double phase,
    required List<Color> colors,
    required double thickness,
  }) {
    final Path path =
        Path();

    for (
      double x = -50;
      x <= size.width + 50;
      x += 8
    ) {
      final normalized =
          x / size.width;

      final primary =
          math.sin(
            normalized *
                    math.pi *
                    2 *
                    frequency +
                phase,
          );

      final secondary =
          math.sin(
            normalized *
                    math.pi *
                    4 *
                    frequency +
                phase *
                    0.60,
          );

      final y =
          baseY +
          primary *
              amplitude +
          secondary *
              amplitude *
              0.16;

      if (x == -50) {
        path.moveTo(
          x,
          y,
        );
      } else {
        path.lineTo(
          x,
          y,
        );
      }
    }

    final bounds =
        Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    // LARGE BLOOM

    final Paint glow =
        Paint()
          ..style =
              PaintingStyle
                  .stroke
          ..strokeWidth =
              thickness
          ..strokeCap =
              StrokeCap.round
          ..shader =
              LinearGradient(
                colors:
                    colors,
              ).createShader(
                bounds,
              )
          ..maskFilter =
              const MaskFilter.blur(
                BlurStyle.normal,
                38,
              );

    canvas.drawPath(
      path,
      glow,
    );

    // INNER AURORA

    final Paint inner =
        Paint()
          ..style =
              PaintingStyle
                  .stroke
          ..strokeWidth =
              thickness *
              0.25
          ..strokeCap =
              StrokeCap.round
          ..shader =
              LinearGradient(
                colors:
                    colors,
              ).createShader(
                bounds,
              )
          ..maskFilter =
              const MaskFilter.blur(
                BlurStyle.normal,
                14,
              );

    canvas.drawPath(
      path,
      inner,
    );
  }

  @override
  bool shouldRepaint(
    covariant _AuroraPainter
        oldDelegate,
  ) {
    return false;
  }
}