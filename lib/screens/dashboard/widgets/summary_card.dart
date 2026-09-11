import 'package:flutter/material.dart';
import 'glass_container.dart';

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
        return const Color(0xFF38D66B);

      case 'Total Expenses':
        return const Color(0xFFFF5C70);

      case 'Cost of Goods':
        return const Color(0xFFFFA23A);

      case 'Net Cash Flow':
        return const Color(0xFF42D5E8);

      default:
        return Colors.white;
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,

        transform: Matrix4.translationValues(
          0,
          _isHovered ? -6 : 0,
          0,
        ),

        child: GlassContainer(
          opacity: _isHovered ? 0.24 : 0.16,
          blur: 18,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color: _mainColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: _mainColor.withValues(alpha: 0.35),
                  ),
                ),

                child: Icon(
                  widget.icon,
                  color: _mainColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.amount,

                      style: TextStyle(
                        color: _mainColor,
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
      ),
    );
  }
}