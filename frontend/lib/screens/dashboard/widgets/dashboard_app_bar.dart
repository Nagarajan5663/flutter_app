import 'dart:typed_data';

import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const _workspaceOptions = <({
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String? badge,
  })>[
    (
      title: 'Admin Console',
      subtitle: 'ArkSync • FluxaHub • HRpod',
      icon: Icons.admin_panel_settings_outlined,
      color: Color(0xFFECE5F3),
      badge: null,
    ),
    (
      title: 'FluxaHub',
      subtitle: 'Sales & Revenue CRM',
      icon: Icons.hub_outlined,
      color: Color(0xFFE4EAF5),
      badge: null,
    ),
    (
      title: 'HRpod',
      subtitle: 'Active Workspace',
      icon: Icons.badge_outlined,
      color: Color(0xFFE0EFF2),
      badge: 'CURRENT',
    ),
    (
      title: 'Codexia Books',
      subtitle: 'Coming Soon',
      icon: Icons.menu_book_outlined,
      color: Color(0xFFECE5F3),
      badge: 'SOON',
    ),
    (
      title: 'Codexia POS',
      subtitle: 'Coming Soon',
      icon: Icons.point_of_sale_outlined,
      color: Color(0xFFE2F0E8),
      badge: 'SOON',
    ),
    (
      title: 'Codexia Resto',
      subtitle: 'Coming Soon',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFF4E8E1),
      badge: 'SOON',
    ),
    (
      title: 'Codexia Med',
      subtitle: 'Coming Soon',
      icon: Icons.medical_services_outlined,
      color: Color(0xFFE2F0E8),
      badge: 'SOON',
    ),
  ];

  final VoidCallback onProfilePressed;
  final VoidCallback? onPowerPressed;
  final String welcomeName;
  final bool canOpenProfile;
  final Uint8List? organizationLogoBytes;

  const DashboardAppBar({
    super.key,
    required this.onProfilePressed,
    required this.welcomeName,
    required this.canOpenProfile,
    this.organizationLogoBytes,
    this.onPowerPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      toolbarHeight: 70,
      titleSpacing: 24,

      // ============================================================
      // LEFT SIDE
      // ============================================================

      title: Row(
        children: [
          if (organizationLogoBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                organizationLogoBytes!,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(width: 14),

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
        Center(
          child: Text(
            'Welcome, $welcomeName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 12),

        IconButton(
          tooltip: canOpenProfile
              ? 'Organization Settings'
              : 'Settings are not available for your role',
          onPressed: canOpenProfile ? onProfilePressed : null,
          icon: Image.asset(
            'assets/images/organization_settings.png',
            width: 34,
            height: 38,
            fit: BoxFit.contain,
          ),
        ),

        // ==========================================================
        // The existing admin icon opens the workspace menu.
        // ==========================================================

        PopupMenuButton<String>(
          tooltip: 'Workspace options',
          position: PopupMenuPosition.under,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints.tightFor(width: 320),
          onSelected: (_) {},
          itemBuilder: (context) => [
            for (final option in _workspaceOptions)
              PopupMenuItem<String>(
                value: option.title,
                enabled: option.badge != 'SOON',
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: option.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        option.icon,
                        color: const Color(0xFF3C3F57),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF27293A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF737586),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (option.badge != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        option.badge!,
                        style: TextStyle(
                          color: option.badge == 'CURRENT'
                              ? const Color(0xFF315B9A)
                              : const Color(0xFFB47A31),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFF2F80B9),
              size: 28,
            ),
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
    );
  }
}
