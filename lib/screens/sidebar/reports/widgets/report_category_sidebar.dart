import 'package:flutter/material.dart';

class ReportCategorySidebar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const ReportCategorySidebar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categories = [
    'All Reports',
    'Business Overview',
    'Sales',
    'Inventory',
    'Receivables',
    'Payables',
    'Purchases and Expenses',
    'Accountant',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        15,
        20,
        15,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7EBEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 10,
              bottom: 14,
            ),
            child: Text(
              'REPORT CATEGORY',
              style: TextStyle(
                color: Color(0xFF929292),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),

          for (final category in categories)
            _CategoryItem(
              title: category,
              selected: selectedCategory == category,
              onTap: () {
                onCategorySelected(category);
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() =>
      _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: MouseRegion(
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

        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(7),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),

            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              color: widget.selected
                  ? const Color(0xFF2E69B3)
                  : _isHovered
                      ? const Color(0xFFF0F7FC)
                      : Colors.transparent,

              borderRadius: BorderRadius.circular(7),
            ),

            child: Text(
              widget.title,
              style: TextStyle(
                color: widget.selected
                    ? Colors.white
                    : const Color(0xFF444444),

                fontSize: 14,

                fontWeight: widget.selected
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}