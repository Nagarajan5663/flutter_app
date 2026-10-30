import 'package:flutter/material.dart';

import 'purchase_dropdown_style.dart';

class PurchaseActionMenuItem {
  const PurchaseActionMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final bool destructive;
}

class PurchaseActionMenu extends StatelessWidget {
  const PurchaseActionMenu({
    super.key,
    required this.actions,
    this.iconColor = const Color(0xFF42474D),
    this.iconBackgroundColor,
  });

  final List<PurchaseActionMenuItem> actions;
  final Color iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PurchaseActionMenuItem>(
      tooltip: 'More actions',
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      offset: Offset.zero,
      color: PurchaseDropdownStyle.menuColor,
      surfaceTintColor: Colors.transparent,
      shape: PurchaseDropdownStyle.menuShape,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 220),
      onSelected: (action) => action.onPressed(),
      itemBuilder: (context) => actions
          .map(
            (action) => PopupMenuItem<PurchaseActionMenuItem>(
              value: action,
              enabled: action.enabled,
              height: 42,
              child: Row(
                children: [
                  Icon(
                    action.icon,
                    size: 18,
                    color: action.destructive
                        ? const Color(0xFFAB2A2A)
                        : const Color(0xFF7A8490),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    action.label,
                    style: TextStyle(
                      color: action.destructive
                          ? const Color(0xFFAB2A2A)
                          : const Color(0xFF42474D),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}
