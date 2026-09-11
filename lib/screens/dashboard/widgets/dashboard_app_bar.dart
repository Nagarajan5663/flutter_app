import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback? onPowerPressed;

  const DashboardAppBar({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
    this.onPowerPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      toolbarHeight: 70,
      titleSpacing: 14,

      // ============================================================
      // LEFT SIDE
      // ============================================================

      title: Row(
        children: [
          // MENU ICON
          IconButton(
            onPressed: onMenuPressed,
            tooltip: 'Menu',
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF333333),
              size: 28,
            ),
          ),

          const SizedBox(width: 10),

          // ORGANIZATION LOGO TEXT
          const Text(
            'Organization Logo',
            style: TextStyle(
              color: Color(0xFF123653),
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(width: 45),

          // ========================================================
          // SEARCH BAR
          // ========================================================

          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFFDDDDDD),
              ),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9E9E9E),
                  size: 22,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),

      // ============================================================
      // RIGHT SIDE
      // ============================================================

      actions: [
        // WELCOME TEXT
        const Center(
          child: Text(
            'Welcome, ',
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const Center(
          child: Text(
            'nagarajanpandurangan2004',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ==========================================================
        // SUPER ADMIN ICON
        //
        // DIRECT CLICK -> PROFILE PAGE
        // NO POPUP MENU
        // ==========================================================

        IconButton(
          tooltip: 'Super Admin Profile',
          onPressed: onProfilePressed,
          icon: const Icon(
            Icons.admin_panel_settings_outlined,
            color: Color(0xFF2F80B9),
            size: 28,
          ),
        ),

        const SizedBox(width: 5),

        // ==========================================================
        // LOGOUT ICON
        // ==========================================================

        IconButton(
          tooltip: 'Logout',
          onPressed: onPowerPressed ?? () {},
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFFE6534E),
            size: 27,
          ),
        ),

        const SizedBox(width: 14),
      ],

      // ============================================================
      // BOTTOM BORDER
      // ============================================================

      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE5E5E5),
        ),
      ),
    );
  }
}