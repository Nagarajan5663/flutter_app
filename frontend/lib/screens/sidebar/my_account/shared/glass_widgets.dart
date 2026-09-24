import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// GLASS PAGE BACKGROUND (DARK VARIANT)
//
// Same decorative language as the Purchase module's GlassPageBackground —
// gradient backdrop + two large blurred color blobs — but noticeably darker,
// so the translucent white GlassPanel cards read clearly as "glass" instead
// of blending into a near-white page.
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
//
// Frosted glass replacement for the flat white `Container` cards (Profile
// Information, Change Password). Drop existing content in as `child` —
// nothing about the layout/content changes.
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
// GLASS FOOTER BAR
//
// Replacement for the flat `0xFFFCFCFC` footer strips that hold the
// Save/Update buttons at the bottom of each card.
// ============================================================================

class GlassFooterBar extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const GlassFooterBar({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.vertical(bottom: Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: borderRadius,
        border: const Border(
          top: BorderSide(color: Colors.white24),
        ),
      ),
      child: child,
    );
  }
}

// ============================================================================
// GLASS BUTTON
// ============================================================================

class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering && !disabled ? 1.03 : 1,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                gradient: widget.primary
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          disabled
                              ? const Color(0xFF4C6E93)
                              : hovering
                                  ? const Color(0xFF2E8FE0)
                                  : const Color(0xFF1687E8),
                          disabled
                              ? const Color(0xFF5C4E8F)
                              : hovering
                                  ? const Color(0xFF8460D6)
                                  : const Color(0xFF6A4FC0),
                        ],
                      )
                    : null,
                color: widget.primary
                    ? null
                    : Colors.white.withValues(alpha: hovering ? 0.22 : 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.primary
                      ? Colors.white.withValues(alpha: 0.30)
                      : Colors.white.withValues(alpha: hovering ? 0.55 : 0.35),
                ),
                boxShadow: hovering && !disabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: Colors.white),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
//
// Tints for text fields / dropdowns so they sit naturally on top of the
// darker, more visible glass cards.
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
