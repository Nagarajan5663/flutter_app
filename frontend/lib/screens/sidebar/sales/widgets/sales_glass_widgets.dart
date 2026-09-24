import 'dart:ui';

import 'package:flutter/material.dart';

/// Visual-only glass treatment for the existing Sales module.
///
/// IMPORTANT:
/// - Does not contain Sales business data.
/// - Does not add/remove page content.
/// - Does not change table structure.
/// - Does not change popup fields/options.
///
/// The values below intentionally match the Items/Parts + Inventory glass UI.
class SalesGlassPageFrame extends StatefulWidget {
  const SalesGlassPageFrame({super.key, required this.child});

  final Widget child;

  @override
  State<SalesGlassPageFrame> createState() => _SalesGlassPageFrameState();
}

class _SalesGlassPageFrameState extends State<SalesGlassPageFrame> {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _hovering = false;

  void _onHover(PointerEvent event) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || renderObject.size.isEmpty) return;

    final size = renderObject.size;
    final x = (event.localPosition.dx / size.width) - 0.5;
    final y = (event.localPosition.dy / size.height) - 0.5;

    // Exact same subtle tilt strength used in the Inventory panel.
    const double tiltStrength = 0.025;

    setState(() {
      _rotateY = x * tiltStrength;
      _rotateX = -y * tiltStrength;
    });
  }

  void _resetTilt() {
    if (!mounted) return;
    setState(() {
      _hovering = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final enableTilt = width >= 850;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCADAE7),
            Color(0xFFD2D6E3),
            Color(0xFFC7DCD9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Blue orb - same Inventory values.
          Positioned(
            top: -110,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3984BA).withValues(alpha: 0.32),
                      const Color(0xFF3984BA).withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Purple orb - same Inventory values.
          Positioned(
            bottom: -170,
            left: 20,
            child: IgnorePointer(
              child: Container(
                width: 440,
                height: 440,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7563AD).withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Green orb - same Inventory values.
          Positioned(
            top: 270,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF45B6A1).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 30),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: MouseRegion(
                  onEnter: (_) {
                    if (!enableTilt) return;
                    setState(() => _hovering = true);
                  },
                  onHover: enableTilt ? _onHover : null,
                  onExit: (_) => _resetTilt(),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: _hovering ? 90 : 340),
                    curve: _hovering ? Curves.linear : Curves.easeOutCubic,
                    transformAlignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(enableTilt ? _rotateX : 0)
                      ..rotateY(enableTilt ? _rotateY : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF173D59).withValues(
                            alpha: _hovering ? 0.18 : 0.10,
                          ),
                          blurRadius: _hovering ? 50 : 35,
                          spreadRadius: _hovering ? 2 : 0,
                          offset: Offset(
                            _rotateY * 120,
                            14 + (_rotateX * 80),
                          ),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: _hovering ? 0.66 : 0.56,
                            ),
                            borderRadius:
                                BorderRadius.circular(isMobile ? 20 : 28),
                            border: Border.all(
                              width: 1.3,
                              color: Colors.white.withValues(
                                alpha: _hovering ? 0.95 : 0.78,
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(child: widget.child),

                              // Main panel glass shine.
                              Positioned(
                                top: -120,
                                right: -70,
                                child: IgnorePointer(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 320,
                                    height: 320,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white.withValues(
                                            alpha: _hovering ? 0.25 : 0.14,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Top edge highlight.
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
                            ],
                          ),
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

/// Drop-in visual replacement for the original Dialog widgets.
/// Existing form content, fields, validations and buttons remain untouched.
class SalesGlassDialog extends StatefulWidget {
  const SalesGlassDialog({
    super.key,
    required this.child,
    this.insetPadding,
    this.backgroundColor,
    this.shape,
  });

  final Widget child;
  final EdgeInsets? insetPadding;
  final Color? backgroundColor;
  final ShapeBorder? shape;

  @override
  State<SalesGlassDialog> createState() => _SalesGlassDialogState();
}

class _SalesGlassDialogState extends State<SalesGlassDialog> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: widget.insetPadding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.004 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF102A3E).withValues(
                    alpha: _hovering ? 0.30 : 0.26,
                  ),
                  blurRadius: _hovering ? 60 : 55,
                  spreadRadius: _hovering ? 3 : 2,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(
                          alpha: _hovering ? 0.84 : 0.80,
                        ),
                        Colors.white.withValues(
                          alpha: _hovering ? 0.66 : 0.61,
                        ),
                        const Color(0xFFDDEAF3).withValues(alpha: 0.54),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      width: 1.3,
                      color: Colors.white.withValues(
                        alpha: _hovering ? 0.98 : 0.94,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      widget.child,

                      // Same blue glass highlight used in Inventory popups.
                      Positioned(
                        top: -100,
                        right: -70,
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

                      // Same purple glass highlight used in Inventory popups.
                      Positioned(
                        bottom: -130,
                        left: -80,
                        child: IgnorePointer(
                          child: Container(
                            width: 290,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF7967B4)
                                      .withValues(alpha: 0.14),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

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
                                  Colors.white.withValues(alpha: 0.96),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

