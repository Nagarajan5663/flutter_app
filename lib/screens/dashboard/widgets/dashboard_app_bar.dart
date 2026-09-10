import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const DashboardAppBar({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 1,
      titleSpacing: 12,

      // =============================================================
      // THREE LINE / MENU BUTTON
      // =============================================================
      leading: IconButton(
        tooltip: 'Menu',
        onPressed: onMenuPressed,
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 26,
        ),
      ),

      // =============================================================
      // LOGO
      // =============================================================
      title: const Text(
        'logo',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      

    actions: [
  const Text(
    'Welcome',
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  ),

  const SizedBox(width: 14),

  // PROFILE / SUPER ADMIN ICON
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Icon(
        Icons.admin_panel_settings_outlined,
        color: Colors.blue,
        size: 20,
      ),
    ),
  ),

  // POWER ICON
  IconButton(
    tooltip: 'Shutdown',
    onPressed: () {},
    icon: const Icon(
      Icons.power_settings_new_rounded,
      color: Colors.white,
    ),
  ),

  const SizedBox(width: 8),
],
  );
  }
}