import 'package:flutter/material.dart';

class DashboardMetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;

  final Color iconColor;
  final Color iconBackground;
  final Color valueColor;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.valueColor,
  });

  @override
  State<DashboardMetricCard> createState() =>
      _DashboardMetricCardState();
}

class _DashboardMetricCardState extends State<DashboardMetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,

        // Hover lift
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -5 : 0,
          0,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: _isHovered
                ? widget.iconColor.withValues(alpha: 0.45)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered ? 0.15 : 0.05,
              ),
              blurRadius: _isHovered ? 18 : 8,
              offset: Offset(
                0,
                _isHovered ? 8 : 3,
              ),
            ),
          ],
        ),

        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // Title and value
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    widget.value,
                    maxLines: 1,
                    style: TextStyle(
                      color: widget.valueColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// RESPONSIVE WEB GRID
// ==================================================================

class DashboardMetricGrid extends StatelessWidget {
  final List<Widget> children;

  const DashboardMetricGrid({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Web
        if (constraints.maxWidth >= 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              children.length,
              (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == children.length - 1 ? 0 : 16,
                    ),
                    child: SizedBox(
                      height: 110,
                      child: children[index],
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Tablet
        if (constraints.maxWidth >= 550) {
          const double gap = 14;

          final double cardWidth =
              (constraints.maxWidth - gap) / 2;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: children.map((card) {
              return SizedBox(
                width: cardWidth,
                height: 110,
                child: card,
              );
            }).toList(),
          );
        }

        // Mobile
        return Column(
          children: List.generate(
            children.length,
            (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == children.length - 1 ? 0 : 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 110,
                  child: children[index],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================================
// REUSABLE HOVER PANEL
// ============================================================================

class DashboardHoverPanel extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry padding;

  const DashboardHoverPanel({
    super.key,
    required this.child,
    required this.accentColor,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<DashboardHoverPanel> createState() =>
      _DashboardHoverPanelState();
}

class _DashboardHoverPanelState extends State<DashboardHoverPanel> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,

        transform: Matrix4.translationValues(
          0,
          _isHovered ? -5 : 0,
          0,
        ),

        padding: widget.padding,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.45)
                : const Color(0xFFE5E7EB),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered ? 0.14 : 0.05,
              ),
              blurRadius: _isHovered ? 18 : 8,
              offset: Offset(
                0,
                _isHovered ? 8 : 3,
              ),
            ),
          ],
        ),

        child: widget.child,
      ),
    );
  }
}