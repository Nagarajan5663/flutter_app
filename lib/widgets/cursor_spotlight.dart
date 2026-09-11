import 'package:flutter/material.dart';

/// Wraps [child] and paints a soft radial "flashlight" glow that follows
/// the mouse cursor while it moves over the wrapped area.
class CursorSpotlight extends StatefulWidget {
  const CursorSpotlight({
    super.key,
    required this.child,
    this.color = const Color(0xFFFDBA5A),
    this.radius = 220,
    this.opacity = 0.16,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final Widget child;
  final Color color;
  final double radius;
  final double opacity;
  final BorderRadius borderRadius;

  @override
  State<CursorSpotlight> createState() => _CursorSpotlightState();
}

class _CursorSpotlightState extends State<CursorSpotlight> {
  Offset? _localPosition;

  void _updatePosition(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    setState(() => _localPosition = box.globalToLocal(event.position));
  }

  void _clear() => setState(() => _localPosition = null);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _updatePosition,
      onHover: _updatePosition,
      onExit: (_) => _clear(),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _localPosition == null ? 0 : 1,
                child: _localPosition == null
                    ? const SizedBox.shrink()
                    : Positioned.fill(
                        child: CustomPaint(
                          painter: _SpotlightPainter(
                            center: _localPosition!,
                            radius: widget.radius,
                            color: widget.color,
                            opacity: widget.opacity,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.center,
    required this.radius,
    required this.color,
    required this.opacity,
  });

  final Offset center;
  final double radius;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}