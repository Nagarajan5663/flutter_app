import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A dark navy background with two soft, slowly drifting gradient blobs
/// and a field of gently floating "data" particles.
///
/// Wrap any auth screen body with this widget to get the same animated
/// look used on the Sign In / Create Account screens:
///
/// ```dart
/// Scaffold(
///   body: AnimatedAuthBackground(
///     child: YourFormHere(),
///   ),
/// )
/// ```
class AnimatedAuthBackground extends StatefulWidget {
  final Widget child;

  const AnimatedAuthBackground({super.key, required this.child});

  @override
  State<AnimatedAuthBackground> createState() =>
      _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with TickerProviderStateMixin {
  // Slow back-and-forth drift for the two big blobs.
  late final AnimationController _blobController;

  // Continuous loop that drives the floating particles.
  late final AnimationController _particleController;

  final List<_Particle> _particles = List.generate(
    26,
    (index) => _Particle.random(Random(index * 97)),
  );

  @override
  void initState() {
    super.initState();

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CodexiaColors.navyDark, CodexiaColors.navy],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Drifting blurred blobs, like the reference design.
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_blobController.value);

              return Stack(
                children: [
                  Positioned(
                    top: -260 + (t * 30),
                    left: -220 + (t * 40),
                    child: _Blob(
                      size: 620,
                      color: CodexiaColors.card.withValues(alpha: 0.55),
                    ),
                  ),
                  Positioned(
                    bottom: -260 - (t * 30),
                    right: -220 - (t * 40),
                    child: _Blob(
                      size: 620,
                      color: CodexiaColors.gold.withValues(alpha: 0.10),
                    ),
                  ),
                ],
              );
            },
          ),

          // Softly floating particles, evoking "digital" data / pages.
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  t: _particleController.value,
                ),
              );
            },
          ),

          // Actual screen content sits on top of the animation.
          widget.child,
        ],
      ),
    );
  }
}

/// A single large soft-edged circle used to build the drifting blobs.
class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

/// Data model for a single floating particle.
class _Particle {
  final double startX; // 0..1, fraction of width
  final double startY; // 0..1, fraction of height
  final double radius;
  final double speed; // how fast it drifts upward, 0..1 per loop
  final double sway; // horizontal wobble amount, in pixels
  final double phase; // offset so particles don't move in sync
  final double opacity;

  _Particle({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.speed,
    required this.sway,
    required this.phase,
    required this.opacity,
  });

  factory _Particle.random(Random rnd) {
    return _Particle(
      startX: rnd.nextDouble(),
      startY: rnd.nextDouble(),
      radius: 1.4 + rnd.nextDouble() * 2.4,
      speed: 0.4 + rnd.nextDouble() * 0.8,
      sway: 12 + rnd.nextDouble() * 22,
      phase: rnd.nextDouble() * 2 * pi,
      opacity: 0.15 + rnd.nextDouble() * 0.35,
    );
  }
}

/// Paints every particle drifting slowly upward and fading back in,
/// looping forever using the 0..1 animation value [t].
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticlePainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Loop progress for this particle (staggered by its own speed).
      final loopT = (t * p.speed + p.phase / (2 * pi)) % 1.0;

      // Drift from bottom to a bit above the top, then wrap around.
      final dy = size.height * (p.startY + 1.2) - loopT * size.height * 1.4;
      final wrappedDy = dy % (size.height + 120) - 60;

      final dx =
          size.width * p.startX + sin((loopT * 2 * pi) + p.phase) * p.sway;

      // Fade in/out near the top and bottom of the loop.
      final fade = sin(loopT * pi).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = CodexiaColors.gold.withValues(alpha: p.opacity * fade)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, wrappedDy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}