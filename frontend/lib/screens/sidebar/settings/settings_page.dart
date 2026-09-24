import 'dart:ui';

import 'package:flutter/material.dart';

import '../../organization/organization_page.dart';
import '../../organization/settings/organization/general_settings_page.dart';
import '../../organization/settings/organization/manage_subscription_page.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onClose;

  const SettingsPage({
    super.key,
    this.onClose,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showOrganizationProfile = false;
  bool _showGeneralSettings = false;
  bool _showManageSubscription = false;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // OPEN ORGANIZATION PROFILE
  // ================================================================

  void _openOrganizationProfile() {
    setState(() {
      _showOrganizationProfile = true;
      _showGeneralSettings = false;
      _showManageSubscription = false;
    });
  }

  // ================================================================
  // OPEN GENERAL SETTINGS
  // ================================================================

  void _openGeneralSettings() {
    setState(() {
      _showOrganizationProfile = false;
      _showGeneralSettings = true;
      _showManageSubscription = false;
    });
  }

  // ================================================================
  // OPEN MANAGE SUBSCRIPTION
  // ================================================================

  void _openManageSubscription() {
    setState(() {
      _showOrganizationProfile = false;
      _showGeneralSettings = false;
      _showManageSubscription = true;
    });
  }

  // ================================================================
  // BACK TO ALL SETTINGS
  // ================================================================

  void _backToAllSettings() {
    setState(() {
      _showOrganizationProfile = false;
      _showGeneralSettings = false;
      _showManageSubscription = false;
    });
  }

  // ================================================================
  // COMING SOON MESSAGE
  // ================================================================

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - Coming Soon'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ================================================================
  // SEARCH MATCH
  // ================================================================

  bool _matches(String text) {
    if (_searchText.trim().isEmpty) {
      return true;
    }

    return text.toLowerCase().contains(
          _searchText.toLowerCase().trim(),
        );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    // ==============================================================
    // ORGANIZATION PROFILE PAGE
    // ==============================================================

    if (_showOrganizationProfile) {
      return OrganizationPage(
        onBack: _backToAllSettings,
      );
    }

    // ==============================================================
    // GENERAL SETTINGS PAGE
    // ==============================================================

    if (_showGeneralSettings) {
      return GeneralSettingsPage(
        onBack: _backToAllSettings,
      );
    }

    // ==============================================================
    // MANAGE SUBSCRIPTION PAGE
    // ==============================================================

    if (_showManageSubscription) {
      return ManageSubscriptionPage(
        onBack: _backToAllSettings,
      );
    }

    // ==============================================================
    // ALL SETTINGS PAGE
    // ==============================================================

    return GlassPageBackground(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // TOP HEADER
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                16,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white24,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 750;

                  if (isSmall) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: _buildSearchField(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTitle(),
                      ),

                      const SizedBox(width: 16),

                      SizedBox(
                        width: 220,
                        height: 38,
                        child: _buildSearchField(),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ======================================================
            // SETTINGS CONTENT
            // ======================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                26,
              ),
              child: GlassPanel(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    24,
                  ),
                  child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Organization Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),

                    const SizedBox(height: 18),

                    LayoutBuilder(
                      builder:
                          (context, constraints) {
                        // ==========================================
                        // DESKTOP - 4 COLUMNS
                        // ==========================================

                        if (constraints.maxWidth >=
                            1100) {
                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child:
                                    _organizationColumn(),
                              ),

                              const SizedBox(width: 26),

                              Expanded(
                                child:
                                    _usersAndTaxColumn(),
                              ),

                              const SizedBox(width: 26),

                              Expanded(
                                child:
                                    _setupColumn(),
                              ),

                              const SizedBox(width: 26),

                              Expanded(
                                child:
                                    _customizationColumn(),
                              ),
                            ],
                          );
                        }

                        // ==========================================
                        // TABLET - 2 COLUMNS
                        // ==========================================

                        if (constraints.maxWidth >=
                            600) {
                          final columnWidth =
                              (constraints.maxWidth -
                                      22) /
                                  2;

                          return Wrap(
                            spacing: 22,
                            runSpacing: 26,
                            children: [
                              SizedBox(
                                width: columnWidth,
                                child:
                                    _organizationColumn(),
                              ),

                              SizedBox(
                                width: columnWidth,
                                child:
                                    _usersAndTaxColumn(),
                              ),

                              SizedBox(
                                width: columnWidth,
                                child:
                                    _setupColumn(),
                              ),

                              SizedBox(
                                width: columnWidth,
                                child:
                                    _customizationColumn(),
                              ),
                            ],
                          );
                        }

                        // ==========================================
                        // MOBILE - SINGLE COLUMN
                        // ==========================================

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _organizationColumn(),

                            const SizedBox(height: 26),

                            _usersAndTaxColumn(),

                            const SizedBox(height: 26),

                            _setupColumn(),

                            const SizedBox(height: 26),

                            _customizationColumn(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TITLE
  // ================================================================

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'All Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 4),

        Text(
          'Manage your organization settings and preferences',
          style: TextStyle(
            color: Color(0xFFAAB4C4),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // SEARCH FIELD
  // ================================================================

  Widget _buildSearchField() {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: _searchController,
      style: const TextStyle(
        color: GlassSurface.inputText,
        fontSize: 13.5,
      ),
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search settings (/)',
        hintStyle: TextStyle(
          color: GlassSurface.hintText,
          fontSize: 13.5,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: GlassSurface.hintText,
        ),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: GlassSurface.hintText,
                ),
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchText = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: GlassSurface.fill(),
        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(7),
          borderSide: BorderSide(
            color: GlassSurface.border(),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(7),
          borderSide: BorderSide(
            color: GlassSurface.border(focused: true),
          ),
        ),
      ),
      ),
    );
  }

  // ================================================================
  // ORGANIZATION COLUMN
  // ================================================================

  Widget _organizationColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.business_rounded,
          iconColor:
              const Color(0xFF34A853),
          title: 'Organization',
        ),

        const SizedBox(height: 8),

        if (_matches('Profile'))
          _settingLink(
            title: 'Profile',
            onTap:
                _openOrganizationProfile,
          ),

        if (_matches('General'))
          _settingLink(
            title: 'General',
            onTap:
                _openGeneralSettings,
          ),

        if (_matches('Branding'))
          _settingLink(
            title: 'Branding',
            onTap: () {
              _showComingSoon(
                'Branding',
              );
            },
          ),

        if (_matches('Custom Domain'))
          _settingLink(
            title: 'Custom Domain',
            onTap: () {
              _showComingSoon(
                'Custom Domain',
              );
            },
          ),

        if (_matches('Locations'))
          _settingLink(
            title: 'Locations',
            onTap: () {
              _showComingSoon(
                'Locations',
              );
            },
          ),

        if (_matches(
            'Manage Subscription'))
          _settingLink(
            title: 'Manage Subscription',
            onTap:
                _openManageSubscription,
          ),
      ],
    );
  }

  // ================================================================
  // USERS AND TAX COLUMN
  // ================================================================

  Widget _usersAndTaxColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.groups_rounded,
          iconColor:
              const Color(0xFFE83E7E),
          title: 'Users & Roles',
        ),

        const SizedBox(height: 8),

        if (_matches('Users'))
          _settingLink(
            title: 'Users',
            onTap: () {
              _showComingSoon('Users');
            },
          ),

        if (_matches('Roles'))
          _settingLink(
            title: 'Roles',
            onTap: () {
              _showComingSoon('Roles');
            },
          ),

        if (_matches(
            'User Preferences'))
          _settingLink(
            title: 'User Preferences',
            onTap: () {
              _showComingSoon(
                'User Preferences',
              );
            },
          ),

        const SizedBox(height: 18),

        _sectionTitle(
          icon: Icons.shield_outlined,
          iconColor:
              const Color(0xFFE83E7E),
          title: 'Taxes & Compliance',
        ),

        const SizedBox(height: 8),

        if (_matches('Taxes'))
          _settingLink(
            title: 'Taxes',
            onTap: () {
              _showComingSoon('Taxes');
            },
          ),

        if (_matches('Direct Taxes'))
          _settingLink(
            title: 'Direct Taxes',
            onTap: () {
              _showComingSoon(
                'Direct Taxes',
              );
            },
          ),

        if (_matches('e-Way Bills'))
          _settingLink(
            title: 'e-Way Bills',
            onTap: () {
              _showComingSoon(
                'e-Way Bills',
              );
            },
          ),

        if (_matches('e-Invoicing'))
          _settingLink(
            title: 'e-Invoicing',
            onTap: () {
              _showComingSoon(
                'e-Invoicing',
              );
            },
          ),
      ],
    );
  }

  // ================================================================
  // SETUP COLUMN
  // ================================================================

  Widget _setupColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.tune_rounded,
          iconColor:
              const Color(0xFFF59A0A),
          title:
              'Setup & Configurations',
        ),

        const SizedBox(height: 8),

        if (_matches('Currencies'))
          _settingLink(
            title: 'Currencies',
            onTap: () {
              _showComingSoon(
                'Currencies',
              );
            },
          ),

        if (_matches(
            'Opening Balances'))
          _settingLink(
            title: 'Opening Balances',
            onTap: () {
              _showComingSoon(
                'Opening Balances',
              );
            },
          ),

        if (_matches('Reminders'))
          _settingLink(
            title: 'Reminders',
            onTap: () {
              _showComingSoon(
                'Reminders',
              );
            },
          ),

        if (_matches(
            'Customer Portal'))
          _settingLink(
            title: 'Customer Portal',
            onTap: () {
              _showComingSoon(
                'Customer Portal',
              );
            },
          ),

        if (_matches(
            'Vendor Portal'))
          _settingLink(
            title: 'Vendor Portal',
            onTap: () {
              _showComingSoon(
                'Vendor Portal',
              );
            },
          ),
      ],
    );
  }

  // ================================================================
  // CUSTOMIZATION COLUMN
  // ================================================================

  Widget _customizationColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.palette_outlined,
          iconColor:
              const Color(0xFF3478F6),
          title: 'Customization',
        ),

        const SizedBox(height: 8),

        if (_matches(
            'Transaction Number Series'))
          _settingLink(
            title:
                'Transaction Number Series',
            onTap: () {
              _showComingSoon(
                'Transaction Number Series',
              );
            },
          ),

        if (_matches('PDF Templates'))
          _settingLink(
            title: 'PDF Templates',
            onTap: () {
              _showComingSoon(
                'PDF Templates',
              );
            },
          ),

        if (_matches(
            'Email Notifications'))
          _settingLink(
            title:
                'Email Notifications',
            onTap: () {
              _showComingSoon(
                'Email Notifications',
              );
            },
          ),

        if (_matches(
            'SMS Notifications'))
          _settingLink(
            title:
                'SMS Notifications',
            onTap: () {
              _showComingSoon(
                'SMS Notifications',
              );
            },
          ),

        if (_matches(
            'Reporting Tags'))
          _settingLink(
            title: 'Reporting Tags',
            onTap: () {
              _showComingSoon(
                'Reporting Tags',
              );
            },
          ),

        if (_matches('Web Tabs'))
          _settingLink(
            title: 'Web Tabs',
            onTap: () {
              _showComingSoon(
                'Web Tabs',
              );
            },
          ),

        if (_matches(
            'Digital Signature'))
          _settingLink(
            title:
                'Digital Signature',
            onTap: () {
              _showComingSoon(
                'Digital Signature',
              );
            },
          ),
      ],
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius:
                BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // SETTING LINK
  // ================================================================

  Widget _settingLink({
    required String title,
    required VoidCallback onTap,
  }) {
    return GlassLinkTile(
      title: title,
      onTap: onTap,
    );
  }
}

// ============================================================================
// GLASS PAGE BACKGROUND (DARK VARIANT)
// ============================================================================

class GlassPageBackground extends StatelessWidget {
  final Widget child;

  const GlassPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10233A),
            Color(0xFF241B42),
            Color(0xFF152134),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -100,
            child: IgnorePointer(
              child: _blurOrb(
                size: 420,
                color: const Color(0xFF4F9FD6),
                alpha: 0.35,
              ),
            ),
          ),
          Positioned(
            bottom: -220,
            left: -150,
            child: IgnorePointer(
              child: _blurOrb(
                size: 430,
                color: const Color(0xFF9B6FD6),
                alpha: 0.30,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _blurOrb({
    required double size,
    required Color color,
    required double alpha,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS PANEL
// ============================================================================

class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS LINK TILE
// ============================================================================

class GlassLinkTile extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const GlassLinkTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<GlassLinkTile> createState() => _GlassLinkTileState();
}

class _GlassLinkTileState extends State<GlassLinkTile> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: hovering
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: hovering
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.transparent,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: TextStyle(
                color: hovering
                    ? const Color(0xFF9CC6FF)
                    : const Color(0xFF6FA8FF),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS SURFACE HELPERS
// ============================================================================

class GlassSurface {
  static Color fill({bool emphasized = false}) =>
      Colors.white.withValues(alpha: emphasized ? 0.16 : 0.10);

  static Color border({bool focused = false}) =>
      focused ? const Color(0xFF6FB6F2) : Colors.white.withValues(alpha: 0.28);

  static const Color labelText = Color(0xFFCBD5E1);
  static const Color inputText = Color(0xFFF1F5F9);
  static const Color hintText = Color(0xFF9AA7B8);
}