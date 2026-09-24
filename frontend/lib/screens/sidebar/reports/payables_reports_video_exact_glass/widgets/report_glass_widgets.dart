import 'dart:ui';
import 'package:flutter/material.dart';

class ReportGlassColors {
  static const Color navy = Color(0xFF123456);
  static const Color primary = Color(0xFF194E75);
  static const Color primaryLight = Color(0xFF438CC0);

  static const Color background1 = Color(0xFFCADAE7);
  static const Color background2 = Color(0xFFD2D6E3);
  static const Color background3 = Color(0xFFC7DCD9);

  static const Color textPrimary = Color(0xFF203A4D);
  static const Color textSecondary = Color(0xFF718391);
}

class ReportGlassPageSurface extends StatelessWidget {
  final Widget child;

  const ReportGlassPageSurface({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        final bool enableTilt = constraints.maxWidth >= 850;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 700,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ReportGlassColors.background1,
                ReportGlassColors.background2,
                ReportGlassColors.background3,
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
              SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 14 : 30),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, animatedChild) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - value)),
                        child: animatedChild,
                      ),
                    );
                  },
                  child: ReportGlassTiltPanel(
                    enableTilt: enableTilt,
                    borderRadius: isMobile ? 20 : 28,
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 20 : 28),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReportGlassTiltPanel extends StatefulWidget {
  final Widget child;
  final bool enableTilt;
  final double borderRadius;

  const ReportGlassTiltPanel({
    super.key,
    required this.child,
    this.enableTilt = true,
    this.borderRadius = 28,
  });

  @override
  State<ReportGlassTiltPanel> createState() => _ReportGlassTiltPanelState();
}

class _ReportGlassTiltPanelState extends State<ReportGlassTiltPanel> {
  double rotateX = 0;
  double rotateY = 0;
  bool hovering = false;

  void _handleHover(PointerEvent event) {
    if (!widget.enableTilt) return;

    final RenderObject? object = context.findRenderObject();
    if (object is! RenderBox) return;

    final Size size = object.size;
    if (size.width == 0 || size.height == 0) return;

    final double x = (event.localPosition.dx / size.width) - 0.5;
    final double y = (event.localPosition.dy / size.height) - 0.5;

    const double tiltStrength = 0.025;

    setState(() {
      rotateY = x * tiltStrength;
      rotateX = -y * tiltStrength;
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
              color: const Color(0xFF173D59)
                  .withValues(alpha: hovering ? 0.18 : 0.10),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const ReportGlassCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 17,
  });

  @override
  State<ReportGlassCard> createState() => _ReportGlassCardState();
}

class _ReportGlassCardState extends State<ReportGlassCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: hovering ? 0.46 : 0.33,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: hovering ? 0.95 : 0.72,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163E5A)
                  .withValues(alpha: hovering ? 0.11 : 0.05),
              blurRadius: hovering ? 28 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

enum ReportGlassButtonType {
  back,
  pdf,
  excel,
}

class ReportGlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final ReportGlassButtonType type;

  const ReportGlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.type,
  });

  @override
  State<ReportGlassButton> createState() => _ReportGlassButtonState();
}

class _ReportGlassButtonState extends State<ReportGlassButton> {
  bool hovering = false;

  List<Color> _colors() {
    switch (widget.type) {
      case ReportGlassButtonType.pdf:
        return const [
          Color(0xFFE34D45),
          Color(0xFFF06459),
        ];
      case ReportGlassButtonType.excel:
        return const [
          Color(0xFF1FA95B),
          Color(0xFF30BE6C),
        ];
      case ReportGlassButtonType.back:
        return const [
          Color(0xFF70818B),
          Color(0xFF88969E),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 170),
        scale: hovering ? 1.025 : 1,
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: hovering ? 0.70 : 0.35,
                  ),
                ),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: colors.first.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 17,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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

class ReportTableHeader extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const ReportTableHeader(
    this.text, {
    super.key,
    this.flex = 1,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.25,
          fontWeight: FontWeight.w700,
          color: Color(0xFF506778),
        ),
      ),
    );
  }
}

class PayablesReportTable extends StatelessWidget {
  final List<Widget> headers;
  final String emptyText;
  final double minWidth;

  const PayablesReportTable({
    super.key,
    required this.headers,
    required this.emptyText,
    this.minWidth = 900,
  });

  @override
  Widget build(BuildContext context) {
    return ReportGlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double tableWidth =
              constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.30),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                    child: Row(
                      children: headers,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7A8994),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReportTitleActions extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const ReportTitleActions({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stack = constraints.maxWidth < 850;

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: ReportGlassColors.navy,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: actions,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: ReportGlassColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: actions,
            ),
          ],
        );
      },
    );
  }
}
