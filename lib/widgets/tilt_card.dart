import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Wraps [child] with a cursor-driven 3D tilt (desktop/web) and a gentle
/// lift on hover. On touch devices where there's no mouse, it simply sits
/// flat — MouseRegion.onHover only fires for pointer devices.
///
/// Usage:
/// ```dart
/// TiltCard(
///   child: Container(...your card...),
/// )
/// ```
class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.06,
    this.lift = 4.0,
  });

  final Widget child;

  /// Max rotation in radians. Keep this small (0.04–0.10) for a subtle,
  /// premium feel rather than an obvious "gimmick" wobble.
  final double maxTilt;

  /// How far (in logical px) the card lifts toward the viewer on hover.
  final double lift;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _hovered = false;

  void _onHover(PointerHoverEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    final size = box.size;
    if (size.width == 0 || size.height == 0) return;
    final dx = (local.dx / size.width) - 0.5;
    final dy = (local.dy / size.height) - 0.5;
    setState(() {
      _rotateY = dx * widget.maxTilt;
      _rotateX = -dy * widget.maxTilt;
    });
  }

  void _reset() {
    setState(() {
      _hovered = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onHover: _onHover,
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // perspective
          ..rotateX(_rotateX)
          ..rotateY(_rotateY)
          ..translateByDouble(0.0, _hovered ? -widget.lift : 0.0, 0.0, 1.0),
        child: widget.child,
      ),
    );
  }
}