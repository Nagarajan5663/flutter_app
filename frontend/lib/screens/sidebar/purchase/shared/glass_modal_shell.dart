import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// GLASS MODAL SHELL
//
// Shared glassmorphism wrapper used by every "Add ..." dialog in the
// Purchase module (Vendors, Bills, Purchase Orders, Vendor Credit Notes).
// Drop this around a dialog's existing content in place of the old
// `Dialog(...)` widget — it does not know or care about what's inside it.
// ============================================================================

class GlassModalShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeight;

  const GlassModalShell({
    super.key,
    required this.child,
    this.maxWidth = 700,
    this.maxHeight = 850,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND BLUR
          // ======================================================

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const SizedBox.expand(),
          ),

          // ======================================================
          // CENTER POPUP
          // ======================================================

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 30,
                vertical: isMobile ? 14 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // ========================================
                          // GLASS BACKGROUND
                          // ========================================

                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.78),
                              Colors.white.withValues(alpha: 0.58),
                              const Color(0xFFDDEAF3).withValues(alpha: 0.50),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(26),

                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.92),
                            width: 1.3,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF102A3E)
                                  .withValues(alpha: 0.24),
                              blurRadius: 55,
                              spreadRadius: 2,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // ======================================
                            // BLUE GLASS ORB
                            // ======================================

                            Positioned(
                              top: -100,
                              right: -80,
                              child: IgnorePointer(
                                child: Container(
                                  width: 260,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF438BC0)
                                            .withValues(alpha: 0.22),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // PURPLE GLASS ORB
                            // ======================================

                            Positioned(
                              bottom: -120,
                              left: -80,
                              child: IgnorePointer(
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF7A67B7)
                                            .withValues(alpha: 0.14),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // TOP GLASS SHINE
                            // ======================================

                            Positioned(
                              top: 0,
                              left: 30,
                              right: 30,
                              child: IgnorePointer(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withValues(alpha: 0.95),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // CONTENT
                            // ======================================

                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class GlassDialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onClose;

  const GlassDialogHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.subtitle,
    this.icon = Icons.add_box_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // HEADER ICON
        // ========================================================

        Container(
          width: isMobile ? 44 : 50,
          height: isMobile ? 44 : 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF153F5F), Color(0xFF438CC0)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D557D).withValues(alpha: 0.23),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: isMobile ? 22 : 25),
        ),

        const SizedBox(width: 14),

        // ========================================================
        // TITLE
        // ========================================================

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 21 : 26,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF123456),
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF718391),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 10),

        // ========================================================
        // CLOSE BUTTON
        // ========================================================

        _GlassCloseButton(onPressed: onClose),
      ],
    );
  }
}

// ============================================================================
// CLOSE BUTTON
// ============================================================================

class _GlassCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _GlassCloseButton({required this.onPressed});

  @override
  State<_GlassCloseButton> createState() => _GlassCloseButtonState();
}

class _GlassCloseButtonState extends State<_GlassCloseButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: hovering ? 1.08 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(11),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hovering
                    ? const Color(0xFFFFE9E9).withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: hovering
                      ? const Color(0xFFE9AAAA)
                      : Colors.white.withValues(alpha: 0.75),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 21,
                color: hovering
                    ? const Color(0xFFC55151)
                    : const Color(0xFF71808C),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BUTTON
// ============================================================================

class GlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  const GlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
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
      cursor: disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering && !disabled ? 1.025 : 1,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
              decoration: BoxDecoration(
                gradient: widget.primary
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          disabled
                              ? const Color(0xFF6E93A9)
                              : hovering
                                  ? const Color(0xFF245F8B)
                                  : const Color(0xFF153F61),
                          disabled
                              ? const Color(0xFF8FB4CC)
                              : hovering
                                  ? const Color(0xFF438FC4)
                                  : const Color(0xFF2D709F),
                        ],
                      )
                    : null,
                color: widget.primary
                    ? null
                    : Colors.white.withValues(alpha: hovering ? 0.62 : 0.42),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.primary
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: hovering ? 0.95 : 0.75),
                ),
                boxShadow: hovering && !disabled
                    ? [
                        BoxShadow(
                          color: widget.primary
                              ? const Color(0xFF174D72).withValues(alpha: 0.25)
                              : const Color(0xFF17394F).withValues(alpha: 0.09),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.primary
                        ? Colors.white
                        : const Color(0xFF526979),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.primary
                          ? Colors.white
                          : const Color(0xFF435968),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
// GLASS PAGE BACKGROUND
//
// Wraps an entire page's content (filter bar + table, etc.) with a soft
// gradient backdrop and a couple of large, blurred color blobs — the same
// decorative language as the modal shell — so the frosted GlassPanel cards
// below have something to visually "float" over.
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
            Color(0xFFEAF2F8),
            Color(0xFFF1EEF8),
            Color(0xFFEFF4F8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF438BC0).withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -110,
            child: IgnorePointer(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7A67B7).withValues(alpha: 0.13),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ============================================================================
// GLASS PANEL
//
// Frosted-glass replacement for the plain white bordered `Container`s used
// for filter bars and table cards across the Purchase pages. Drop existing
// content straight in as `child` — layout/content is untouched.
// ============================================================================

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.66),
                Colors.white.withValues(alpha: 0.42),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16324A).withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
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
// GLASS SURFACE HELPERS
//
// Small, purely-cosmetic helpers so each dialog's existing text field /
// dropdown / date field decorations can be tinted to match the frosted
// glass shell without touching field logic, validators, or layout.
// ============================================================================

class GlassSurface {
  /// Translucent fill used inside inputs, date pickers and read-only
  /// "amount" boxes so they sit naturally on top of the blurred glass card.
  static Color fill({bool emphasized = false}) =>
      Colors.white.withValues(alpha: emphasized ? 0.55 : 0.40);

  /// Soft white border that matches the shell's own border treatment.
  static Color border({bool focused = false}) => focused
      ? const Color(0xFF5597C4)
      : Colors.white.withValues(alpha: 0.75);
}
