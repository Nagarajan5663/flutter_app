import 'package:flutter/material.dart';

class SummaryCard extends StatefulWidget {
  final String title;
  final String amount;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _isHovered = false;

  Color get _mainColor {
    switch (widget.title) {
      case 'Total Revenue':
        return const Color(0xFF22C55E);

      case 'Total Expenses':
        return const Color(0xFFEF4444);

      case 'Cost of Goods':
        return const Color(0xFFF59E0B);

      case 'Net Cash Flow':
        return const Color(0xFF3B82F6);

      default:
        return const Color(0xFF64748B);
    }
  }

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
                ? _mainColor.withValues(alpha: 0.45)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered ? 0.15 : 0.06,
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
            // ICON
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: _mainColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),

              child: Icon(
                widget.icon,
                color: _mainColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    widget.amount,

                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 20,
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