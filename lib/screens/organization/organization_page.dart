import 'package:flutter/material.dart';

import 'settings/shared/glass_widgets.dart';
import 'settings/expense_settings_page.dart';
import 'settings/item_preferences_page.dart';
import 'settings/sales_order_preferences_page.dart';

// =====================================================================
// ORGANIZATION PAGE
// =====================================================================
//
// This page is now opened using Navigator.push() from DashboardPage.
//
// Therefore:
//
// Dashboard AppBar   -> NOT visible
// Dashboard Sidebar -> NOT visible
//
// Only OrganizationPage fills the screen.
//
// Close Settings will simply Navigator.pop() and return to Dashboard.
// =====================================================================

class OrganizationPage extends StatelessWidget {
  final String organizationName;

  final VoidCallback? onBack;

  const OrganizationPage({
    super.key,
    this.organizationName = 'test',
    this.onBack,
  });

  // ===================================================================
  // OPEN SETTINGS ITEM
  // ===================================================================

  void _openItem(
    BuildContext context,
    String label,
  ) {
    final normalizedLabel =
        label.trim().toLowerCase();

    // -----------------------------------------------------------------
    // ITEM PREFERENCES
    // -----------------------------------------------------------------

    if (normalizedLabel == 'items' ||
        normalizedLabel ==
            'item preferences') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const ItemPreferencesPage(),
        ),
      );

      return;
    }

    // -----------------------------------------------------------------
    // SALES ORDER PREFERENCES
    // -----------------------------------------------------------------

    if (normalizedLabel ==
            'sales orders' ||
        normalizedLabel ==
            'sales order preferences') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const SalesOrderPreferencesPage(),
        ),
      );

      return;
    }

    // -----------------------------------------------------------------
    // EXPENSE SETTINGS
    // -----------------------------------------------------------------

    if (normalizedLabel ==
            'expenses' ||
        normalizedLabel ==
            'expense settings') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const ExpenseSettingsPage(),
        ),
      );

      return;
    }

    // -----------------------------------------------------------------
    // COMING SOON
    // -----------------------------------------------------------------

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          '$label settings - coming soon',
        ),
      ),
    );
  }

  // ===================================================================
  // CLOSE ORGANIZATION
  // ===================================================================

  void _handleClose(
    BuildContext context,
  ) {
    if (onBack != null) {
      onBack!();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // ===================================================================
  // BUILD
  // ===================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassPageBackground(
      child: Scaffold(
        backgroundColor:
            Colors.transparent,

        // ------------------------------------------------------------
        // IMPORTANT
        // ------------------------------------------------------------
        //
        // No DashboardAppBar here.
        // No DashboardNavBar here.
        // Organization UI occupies complete route.
        // ------------------------------------------------------------

        body: SafeArea(
          child: Column(
            children: [
              // ======================================================
              // ORGANIZATION TOP BAR
              // ======================================================

              _buildTopBar(
                context,
              ),

              // ======================================================
              // CONTENT
              // ======================================================

              Expanded(
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // ===============================================
                      // ORGANIZATION SETTINGS
                      // ===============================================

                      _buildSection(
                        context: context,
                        title:
                            'Organization Settings',
                        columns:
                            _organizationSettingsColumns,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ===============================================
                      // MODULE SETTINGS
                      // ===============================================

                      _buildSection(
                        context: context,
                        title:
                            'Module Settings',
                        columns:
                            _moduleSettingsColumns,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ===============================================
                      // EXTENSION / DEVELOPER
                      // ===============================================

                      _buildSection(
                        context: context,
                        title:
                            'Extension and Developer Data',
                        columns:
                            _extensionSettingsColumns,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // ===============================================
                      // FOOTER
                      // ===============================================

                      Center(
                        child: Text(
                          '© ${DateTime.now().year} '
                          '$organizationName. '
                          'All Rights Reserved.',
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF9AA3AD,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // ORGANIZATION TOP BAR
  // ===================================================================

  Widget _buildTopBar(
    BuildContext context,
  ) {
    return GlassPanel(
      borderRadius:
          BorderRadius.zero,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          20,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            // =========================================================
            // TITLE
            // =========================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'All Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    organizationName,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      color: Color(
                        0xFFCBD5E1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================================================
            // SEARCH
            // =========================================================

            SizedBox(
              width: 260,
              height: 42,
              child: TextField(
                style:
                    const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration:
                    InputDecoration(
                  hintText:
                      'Search settings (/)',

                  hintStyle:
                      const TextStyle(
                    color: Color(
                      0xFF9AA7B8,
                    ),
                    fontSize: 14,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.search,
                    size: 20,
                    color: Color(
                      0xFF9AA7B8,
                    ),
                  ),

                  filled: true,

                  fillColor:
                      GlassSurface.fill(),

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 10,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          GlassSurface
                              .border(),
                    ),
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          GlassSurface
                              .border(),
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          GlassSurface
                              .border(
                        focused: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            // =========================================================
            // CLOSE
            // =========================================================

            ElevatedButton.icon(
              onPressed: () {
                _handleClose(
                  context,
                );
              },
              icon: const Icon(
                Icons.close,
                size: 18,
              ),
              label: const Text(
                'Close Settings',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    GlassSurface.fill(
                  emphasized: true,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // SECTION
  // ===================================================================

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<List<_SettingsGroup>>
        columns,
  }) {
    return GlassPanel(
      borderRadius:
          BorderRadius.circular(
        10,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color: Colors.white,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Divider(
              color: Colors.white
                  .withValues(
                alpha: 0.16,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Wrap(
              spacing: 36,
              runSpacing: 24,
              children:
                  columns.map(
                (
                  column,
                ) {
                  return SizedBox(
                    width: 210,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        for (
                          int i = 0;
                          i <
                              column
                                  .length;
                          i++
                        ) ...[
                          if (i > 0)
                            const SizedBox(
                              height: 22,
                            ),

                          _buildGroup(
                            context,
                            column[i],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // SETTINGS GROUP
  // ===================================================================

  Widget _buildGroup(
    BuildContext context,
    _SettingsGroup group,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration:
                  BoxDecoration(
                color: group.color,
                borderRadius:
                    BorderRadius
                        .circular(
                  7,
                ),
              ),
              child: Icon(
                group.icon,
                color: Colors.white,
                size: 16,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                group.title,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        for (
          final item
              in group.items
        )
          Padding(
            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),
            child: InkWell(
              onTap: () {
                _openItem(
                  context,
                  item,
                );
              },
              child: Text(
                item,
                style:
                    const TextStyle(
                  fontSize: 14,
                  color: Color(
                    0xFF9CC6FF,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ===================================================================
  // ORGANIZATION SETTINGS DATA
  // ===================================================================

  static final List<
          List<_SettingsGroup>>
      _organizationSettingsColumns = [
    [
      _SettingsGroup(
        icon: Icons.apartment,
        color:
            const Color(
          0xFF2FA84F,
        ),
        title: 'Organization',
        items: const [
          'Profile',
          'General',
          'Branding',
          'Custom Domain',
          'Locations',
          'Manage Subscription',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon: Icons.groups,
        color:
            const Color(
          0xFFE0397B,
        ),
        title:
            'Users & Roles',
        items: const [
          'Users',
          'Roles',
          'User Preferences',
        ],
      ),

      _SettingsGroup(
        icon:
            Icons.shield_outlined,
        color:
            const Color(
          0xFFE0397B,
        ),
        title:
            'Taxes & Compliance',
        items: const [
          'Taxes',
          'Direct Taxes',
          'e-Way Bills',
          'e-Invoicing',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon: Icons.tune,
        color:
            const Color(
          0xFFF39C12,
        ),
        title:
            'Setup & Configurations',
        items: const [
          'Currencies',
          'Opening Balances',
          'Reminders',
          'Customer Portal',
          'Vendor Portal',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon:
            Icons.palette_outlined,
        color:
            const Color(
          0xFF2D7FF9,
        ),
        title: 'Customization',
        items: const [
          'Transaction Number Series',
          'PDF Templates',
          'Email Notifications',
          'SMS Notifications',
          'Reporting Tags',
          'Web Tabs',
          'Digital Signature',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon:
            Icons.smart_toy_outlined,
        color:
            const Color(
          0xFFE0522D,
        ),
        title: 'Automation',
        items: const [
          'Workflow Rules',
          'Workflow Actions',
          'Workflow Logs',
        ],
      ),
    ],
  ];

  // ===================================================================
  // MODULE SETTINGS
  // ===================================================================

  static final List<
          List<_SettingsGroup>>
      _moduleSettingsColumns = [
    [
      _SettingsGroup(
        icon: Icons.grid_view,
        color:
            const Color(
          0xFF2FA84F,
        ),
        title: 'General',
        items: const [
          'Customers and Vendors',
          'Items',
          'Item Preferences',
          'Accountant',
          'Projects',
          'Timesheet',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon:
            Icons.inventory_2_outlined,
        color:
            const Color(
          0xFFE0397B,
        ),
        title: 'Inventory',
        items: const [
          'Inventory Adjustments',
        ],
      ),

      _SettingsGroup(
        icon: Icons.credit_card,
        color:
            const Color(
          0xFF2D7FF9,
        ),
        title:
            'Online Payments',
        items: const [
          'Customer Payments',
          'Vendor Payments',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon: Icons.show_chart,
        color:
            const Color(
          0xFF1F9254,
        ),
        title: 'Sales',
        items: const [
          'Estimates',
          'Sales Orders',
          'Delivery Challans',
          'Invoices',
          'Recurring Invoices',
          'Payments Received',
          'Credit Notes',
          'Delivery Notes',
          'Packing Slips',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon:
            Icons.shopping_cart_outlined,
        color:
            const Color(
          0xFF7B4FE0,
        ),
        title: 'Purchases',
        items: const [
          'Expenses',
          'Purchase Orders',
          'Bills',
          'Payments Made',
          'Vendor Credits',
        ],
      ),
    ],
  ];

  // ===================================================================
  // EXTENSION & DEVELOPER DATA
  // ===================================================================

  static final List<
          List<_SettingsGroup>>
      _extensionSettingsColumns = [
    [
      _SettingsGroup(
        icon:
            Icons.extension_outlined,
        color:
            const Color(
          0xFF2D7FF9,
        ),
        title:
            'Integrations & Market...',
        items: const [
          'Zoho Apps',
          'WhatsApp',
          'SMS Integrations',
          'Uber for Business',
          'Other Apps',
          'Marketplace',
        ],
      ),
    ],

    [
      _SettingsGroup(
        icon: Icons.code,
        color:
            const Color(
          0xFF7B4FE0,
        ),
        title:
            'Developer Data',
        items: const [
          'Incoming Webhooks',
          'Connections',
          'API Usage',
          'Data Management',
          'Deluge Components Usage',
          'Web Forms',
        ],
      ),
    ],
  ];
}

// =====================================================================
// SETTINGS GROUP MODEL
// =====================================================================

class _SettingsGroup {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> items;

  const _SettingsGroup({
    required this.icon,
    required this.color,
    required this.title,
    required this.items,
  });
}