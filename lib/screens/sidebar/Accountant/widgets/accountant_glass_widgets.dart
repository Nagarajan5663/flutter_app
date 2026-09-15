import 'dart:ui';

import 'package:flutter/material.dart';

class AccountantGlassTheme {
  static const Color background1 = Color(0xFFCADAE7);
  static const Color background2 = Color(0xFFD2D6E3);
  static const Color background3 = Color(0xFFC7DCD9);
  static const Color navy = Color(0xFF17395C);
}

class AccountantGlassBackground extends StatelessWidget {
  final Widget child;

  const AccountantGlassBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AccountantGlassTheme.background1,
            AccountantGlassTheme.background2,
            AccountantGlassTheme.background3,
          ],
        ),
      ),
      child: Stack(
        children: [
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
              padding: EdgeInsets.all(isCompact ? 14 : 30),
              child: AccountantGlassTiltPanel(
                enableTilt: !isCompact && MediaQuery.of(context).size.width >= 850,
                borderRadius: isCompact ? 20 : 28,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountantGlassTiltPanel extends StatefulWidget {
  final Widget child;
  final bool enableTilt;
  final double borderRadius;

  const AccountantGlassTiltPanel({
    super.key,
    required this.child,
    this.enableTilt = true,
    this.borderRadius = 28,
  });

  @override
  State<AccountantGlassTiltPanel> createState() => _AccountantGlassTiltPanelState();
}

class _AccountantGlassTiltPanelState extends State<AccountantGlassTiltPanel> {
  double rotateX = 0;
  double rotateY = 0;
  bool hovering = false;

  void _handleHover(PointerEvent event) {
    if (!widget.enableTilt) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final Size size = renderObject.size;
    if (size.width == 0 || size.height == 0) return;

    final double x = (event.localPosition.dx / size.width) - 0.5;
    final double y = (event.localPosition.dy / size.height) - 0.5;
    const double maxTilt = 0.025;

    setState(() {
      rotateY = x * maxTilt;
      rotateX = -y * maxTilt;
    });
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      hovering = false;
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enableTilt) return;
        setState(() => hovering = true);
      },
      onHover: _handleHover,
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: hovering ? 90 : 340),
        curve: hovering ? Curves.linear : Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173D59).withValues(
                alpha: hovering ? 0.18 : 0.10,
              ),
              blurRadius: hovering ? 50 : 35,
              spreadRadius: hovering ? 2 : 0,
              offset: Offset(
                rotateY * 120,
                14 + (rotateX * 80),
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: hovering ? 0.66 : 0.56,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  width: 1.3,
                  color: Colors.white.withValues(
                    alpha: hovering ? 0.95 : 0.78,
                  ),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.child,
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
                                alpha: hovering ? 0.25 : 0.14,
                              ),
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
    );
  }
}

class AccountantGlassHoverCard extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;

  const AccountantGlassHoverCard({
    super.key,
    this.child,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.padding,
    this.alignment,
    this.decoration,
  });

  @override
  State<AccountantGlassHoverCard> createState() => _AccountantGlassHoverCardState();
}

class _AccountantGlassHoverCardState extends State<AccountantGlassHoverCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        width: widget.width,
        height: widget.height,
        constraints: widget.constraints,
        margin: widget.margin,
        padding: widget.padding,
        alignment: widget.alignment,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: hovering ? 0.43 : 0.31,
          ),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: hovering ? 0.95 : 0.72,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163E5A).withValues(
                alpha: hovering ? 0.11 : 0.05,
              ),
              blurRadius: hovering ? 28 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: widget.child,
        ),
      ),
    );
  }
}

class AccountantGlassDialogCard extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;

  const AccountantGlassDialogCard({
    super.key,
    this.child,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.padding,
    this.alignment,
    this.decoration,
  });

  @override
  State<AccountantGlassDialogCard> createState() => _AccountantGlassDialogCardState();
}

class _AccountantGlassDialogCardState extends State<AccountantGlassDialogCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: widget.width,
            height: widget.height,
            constraints: widget.constraints,
            margin: widget.margin,
            padding: widget.padding,
            alignment: widget.alignment,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: hovering ? 0.84 : 0.78),
                  Colors.white.withValues(alpha: hovering ? 0.66 : 0.58),
                  const Color(0xFFDDEAF3).withValues(alpha: 0.50),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                width: 1.3,
                color: Colors.white.withValues(
                  alpha: hovering ? 0.98 : 0.90,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF102A3E).withValues(alpha: 0.24),
                  blurRadius: 55,
                  spreadRadius: 2,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
