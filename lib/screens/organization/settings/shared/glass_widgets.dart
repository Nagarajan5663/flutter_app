import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// GLASS PAGE BACKGROUND (DARK VARIANT)
//
// Identical treatment to My Account's dark backdrop: gradient + two large
// blurred color blobs, so the frosted GlassPanel content reads clearly.
// ============================================================================

class GlassPageBackground extends StatelessWidget {
  final Widget child;

  const GlassPageBackground({super.key, required this.child});

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
            Color(0xFF10233A),
            Color(0xFF241B42),
            Color(0xFF152134),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -100,
            child: IgnorePointer(
              child: _blurOrb(
                size: 420,
                color: const Color(0xFF4F9FD6),
                alpha: 0.35,
              ),
            ),
          ),
          Positioned(
            bottom: -220,
            left: -150,
            child: IgnorePointer(
              child: _blurOrb(
                size: 430,
                color: const Color(0xFF9B6FD6),
                alpha: 0.30,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _blurOrb({
    required double size,
    required Color color,
    required double alpha,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS PANEL
// ============================================================================

class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS LINK TILE
//
// Replaces the old Material+InkWell setting link with a proper animated
// glass hover: a soft translucent pill fades in behind the label on hover.
// ============================================================================

class GlassLinkTile extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const GlassLinkTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<GlassLinkTile> createState() => _GlassLinkTileState();
}

class _GlassLinkTileState extends State<GlassLinkTile> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: hovering
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: hovering
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: TextStyle(
                color: hovering
                    ? const Color(0xFF9CC6FF)
                    : const Color(0xFF6FA8FF),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS SURFACE HELPERS
// ============================================================================

class GlassSurface {
  static Color fill({bool emphasized = false}) =>
      Colors.white.withValues(alpha: emphasized ? 0.16 : 0.10);

  static Color border({bool focused = false}) =>
      focused ? const Color(0xFF6FB6F2) : Colors.white.withValues(alpha: 0.28);

  static const Color labelText = Color(0xFFCBD5E1);
  static const Color inputText = Color(0xFFF1F5F9);
  static const Color hintText = Color(0xFF9AA7B8);
}
