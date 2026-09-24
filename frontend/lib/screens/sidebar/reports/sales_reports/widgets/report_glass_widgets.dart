import 'dart:ui';

import 'package:flutter/material.dart';

class ReportGlassTheme {
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
  final EdgeInsetsGeometry? padding;

  const ReportGlassPageSurface({
    super.key,
    required this.child,
    this.padding,
  });

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
            ReportGlassTheme.background1,
            ReportGlassTheme.background2,
            ReportGlassTheme.background3,
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
            padding: padding ?? EdgeInsets.all(isMobile ? 14 : 30),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
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
              child: ReportGlassTiltPanel(
                enableTilt: enableTilt,
                borderRadius: isMobile ? 20 : 28,
                child: child,
              ),
            ),
          ),
        ],
      ),
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

  void _onHover(PointerEvent event) {
    if (!widget.enableTilt) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;
    final size = renderObject.size;
    if (size.width == 0 || size.height == 0) return;

    final x = (event.localPosition.dx / size.width) - 0.5;
    final y = (event.localPosition.dy / size.height) - 0.5;
    const maxTilt = 0.025;

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
      onHover: _onHover,
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
              offset: Offset(rotateY * 120, 14 + (rotateX * 80)),
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

class ReportGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const ReportGlassCard({
    super.key,
    required this.child,
    this.padding,
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
        duration: const Duration(milliseconds: 230),
        width: double.infinity,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: hovering ? 0.43 : 0.31),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: hovering ? 0.95 : 0.72),
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
        child: widget.child,
      ),
    );
  }
}

class ReportGlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;
  final Color? backgroundColor;

  const ReportGlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.primary = true,
    this.backgroundColor,
  });

  @override
  State<ReportGlassButton> createState() => _ReportGlassButtonState();
}

class _ReportGlassButtonState extends State<ReportGlassButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final baseColor = widget.backgroundColor ?? ReportGlassTheme.primary;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled ? (_) => setState(() => hovering = true) : null,
      onExit: enabled ? (_) => setState(() => hovering = false) : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 170),
        scale: hovering && enabled ? 1.025 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: enabled
                    ? (widget.primary
                        ? baseColor.withValues(alpha: hovering ? 1.0 : 0.94)
                        : Colors.white.withValues(alpha: hovering ? 0.65 : 0.44))
                    : const Color(0xFFBFC8CE).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: enabled
                      ? (widget.primary
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: hovering ? 0.98 : 0.78))
                      : Colors.white.withValues(alpha: 0.42),
                ),
                boxShadow: hovering && enabled
                    ? [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 17,
                      color: widget.primary || !enabled
                          ? Colors.white
                          : const Color(0xFF526979),
                    ),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.primary || !enabled
                          ? Colors.white
                          : const Color(0xFF435968),
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

class ReportPageHeader extends StatelessWidget {
  final String title;
  final Widget? actions;

  const ReportPageHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 38,
        isMobile ? 24 : 34,
        isMobile ? 20 : 38,
        26,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 25 : 34,
                    fontWeight: FontWeight.w800,
                    color: ReportGlassTheme.navy,
                  ),
                ),
                if (actions != null) ...[
                  const SizedBox(height: 18),
                  actions!,
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: ReportGlassTheme.navy,
                    ),
                  ),
                ),
                if (actions != null) actions!,
              ],
            ),
    );
  }
}

class ReportDateFilterCard extends StatelessWidget {
  final String dateRange;
  final String dateFrom;
  final String dateTo;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onRunReport;

  const ReportDateFilterCard({
    super.key,
    required this.dateRange,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateRangeChanged,
    required this.onRunReport,
  });

  @override
  Widget build(BuildContext context) {
    return ReportGlassCard(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        spacing: 16,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _LabeledField(
            label: 'Date Range:',
            child: SizedBox(
              width: 145,
              child: DropdownButtonFormField<String>(
                initialValue: dateRange,
                items: const [
                  DropdownMenuItem(
                    value: 'Custom',
                    child: Text('Custom'),
                  ),
                ],
                onChanged: onDateRangeChanged,
                decoration: _fieldDecoration(),
                dropdownColor: const Color(0xFF263E54),
                style: const TextStyle(color: Color(0xFF263D4E), fontSize: 14),
                selectedItemBuilder: (context) => const [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Custom', style: TextStyle(color: Color(0xFF263D4E))),
                  ),
                ],
              ),
            ),
          ),
          _LabeledField(
            label: 'Date From:',
            child: SizedBox(
              width: 160,
              child: TextFormField(
                initialValue: dateFrom,
                readOnly: true,
                decoration: _fieldDecoration(
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 17),
                ),
              ),
            ),
          ),
          _LabeledField(
            label: 'Date To:',
            child: SizedBox(
              width: 160,
              child: TextFormField(
                initialValue: dateTo,
                readOnly: true,
                decoration: _fieldDecoration(
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 17),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: ReportGlassButton(
              label: 'Run Report',
              onPressed: onRunReport,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF35495A),
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

InputDecoration _fieldDecoration({Widget? suffixIcon}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.50),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    suffixIcon: suffixIcon,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFF5597C4), width: 1.4),
    ),
  );
}

class ReportTableHeaderText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const ReportTableHeaderText(
    this.text, {
    super.key,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5C7283),
      ),
    );
  }
}
