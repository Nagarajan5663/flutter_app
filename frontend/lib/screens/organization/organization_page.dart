import 'package:flutter/material.dart';

import 'settings/shared/glass_widgets.dart';
import 'settings/purchases/expanse_settings_page.dart';
import 'settings/general/item_preferences_page.dart';
import 'settings/organization/general_settings_page.dart';
import 'settings/organization/manage_subscription_page.dart';
import 'settings/sales/sales_order_preferences_page.dart';
import 'settings/organization/organization_profile_page.dart';
import 'settings/users/manage_roles_page.dart';
import 'settings/users/manage_users_page.dart';
import 'settings/taxes/manage_taxes_page.dart';
import 'settings/customization/transaction_number_series_page.dart';
import 'settings/customization/pdf_templates/pdf_templates_page.dart';

// =====================================================================
// ORGANIZATION PAGE (All Settings hub)
//
// Full-screen settings hub, opened by tapping the "Organization" header
// block at the top of the sidebar (see DashboardNavBar). This page
// intentionally covers the whole screen (no sidebar/topbar) to match
// the recorded behaviour, and is closed via the "Close Settings" button
// which either calls onBack (when supplied by a parent that is
// swapping this view in/out, e.g. SettingsPage) or falls back to
// popping the Navigator (when this page was pushed as a route).
// =====================================================================

class OrganizationPage extends StatelessWidget {
  /// Shown under the "All Settings" title. Wire this up to the real
  /// signed-in organization name once that data is available; 'test'
  /// matches the placeholder organization used in the recording.
  final String organizationName;

  /// Called when the user taps "Close Settings". Wired up by the
  /// parent SettingsPage to switch back to the "All Settings" view.
  /// If null, falls back to Navigator.pop.
  final VoidCallback? onBack;

  const OrganizationPage({
    super.key,
    this.organizationName = 'test',
    this.onBack,
  });

  void _openItem(BuildContext context, String label) {
    final normalizedLabel = label.trim().toLowerCase();

    if (normalizedLabel == 'items' ||
        normalizedLabel == 'item preferences') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ItemPreferencesPage(),
        ),
      );
      return;
    }

    if (normalizedLabel == 'profile') {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => OrganizationProfilePage(
        onBack: () =>
            Navigator.of(context).pop(),
      ),
    ),
  );
  return;
}

    if (normalizedLabel == 'general') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GeneralSettingsPage(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }

    if (normalizedLabel == 'manage subscription') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ManageSubscriptionPage(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }

    if (normalizedLabel == 'users') {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ManageUsersPage(
        onBack: () => Navigator.of(context).pop(),
      ),
    ),
  );
  return;
}

    if (normalizedLabel == 'roles') {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ManageRolesPage(
        onBack: () => Navigator.of(context).pop(),
      ),
    ),
  );
  return;
}

if (normalizedLabel == 'taxes') {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ManageTaxesPage(
        onBack: () => Navigator.of(context).pop(),
      ),
    ),
  );
  return;
}

if (normalizedLabel == 'transaction number series') {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          TransactionNumberSeriesPage(
        onBack: () =>
            Navigator.of(context).pop(),
      ),
    ),
  );
  return;
}
if (normalizedLabel == 'pdf templates') {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PdfTemplatesPage(
        onBack: () => Navigator.of(context).pop(),
      ),
    ),
  );
  return;
}

    if (normalizedLabel == 'sales orders' ||
        normalizedLabel == 'sales order preferences') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SalesOrderPreferencesPage(),
        ),
      );
      return;
    }

    if (normalizedLabel == 'expenses' ||
        normalizedLabel == 'expense settings') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ExpenseSettingsPage(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label settings - coming soon'),
      ),
    );
  }

  void _handleClose(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
        children: [
          _buildTopBar(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context: context,
                    title: 'Organization Settings',
                    columns: _organizationSettingsColumns,
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    context: context,
                    title: 'Module Settings',
                    columns: _moduleSettingsColumns,
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    context: context,
                    title: 'Extension and Developer Data',
                    columns: _extensionSettingsColumns,
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      '© ${DateTime.now().year} $organizationName. All Rights Reserved.',
                      style: const TextStyle(
                        color: Color(0xFF9AA3AD),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ==================================================================
  // TOP BAR
  // ==================================================================

  Widget _buildTopBar(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  organizationName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 260,
            height: 42,
            child: TextField(
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search settings (/)',
                hintStyle: const TextStyle(
                  color: Color(0xFF9AA7B8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF9AA7B8),
                ),
                filled: true,
                fillColor: GlassSurface.fill(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: GlassSurface.border()),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: GlassSurface.border()),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: GlassSurface.border(focused: true)),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          ElevatedButton.icon(
            onPressed: () => _handleClose(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassSurface.fill(emphasized: true),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // ==================================================================
  // SECTION CARD (white card with a title + a wrap of columns)
  // ==================================================================

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<List<_SettingsGroup>> columns,
  }) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          Divider(color: Colors.white.withValues(alpha: 0.16)),

          const SizedBox(height: 16),

          Wrap(
            spacing: 36,
            runSpacing: 24,
            children: columns.map(
              (column) {
                return SizedBox(
                  width: 210,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < column.length; i++) ...[
                        if (i > 0) const SizedBox(height: 22),
                        _buildGroup(context, column[i]),
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

  // ==================================================================
  // ONE ICON + TITLE + LINK LIST GROUP
  // ==================================================================

  Widget _buildGroup(BuildContext context, _SettingsGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: group.color,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                group.icon,
                color: Colors.white,
                size: 16,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                group.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        for (final item in group.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _openItem(context, item),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CC6FF),
                ),
              ),
            ),
          ),
        ],
    );
  }

  // ==================================================================
  // DATA - ORGANIZATION SETTINGS
  // ==================================================================

  static final List<List<_SettingsGroup>> _organizationSettingsColumns = [
    [
      _SettingsGroup(
        icon: Icons.apartment,
        color: const Color(0xFF2FA84F),
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
        color: const Color(0xFFE0397B),
        title: 'Users & Roles',
        items: const [
          'Users',
          'Roles',
          'User Preferences',
        ],
      ),
      _SettingsGroup(
        icon: Icons.shield_outlined,
        color: const Color(0xFFE0397B),
        title: 'Taxes & Compliance',
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
        color: const Color(0xFFF39C12),
        title: 'Setup & Configurations',
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
        icon: Icons.palette_outlined,
        color: const Color(0xFF2D7FF9),
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
        icon: Icons.smart_toy_outlined,
        color: const Color(0xFFE0522D),
        title: 'Automation',
        items: const [
          'Workflow Rules',
          'Workflow Actions',
          'Workflow Logs',
        ],
      ),
    ],
  ];

  // ==================================================================
  // DATA - MODULE SETTINGS
  // ==================================================================

  static final List<List<_SettingsGroup>> _moduleSettingsColumns = [
    [
      _SettingsGroup(
        icon: Icons.grid_view,
        color: const Color(0xFF2FA84F),
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
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFFE0397B),
        title: 'Inventory',
        items: const [
          'Inventory Adjustments',
        ],
      ),
      _SettingsGroup(
        icon: Icons.credit_card,
        color: const Color(0xFF2D7FF9),
        title: 'Online Payments',
        items: const [
          'Customer Payments',
          'Vendor Payments',
        ],
      ),
    ],
    [
      _SettingsGroup(
        icon: Icons.show_chart,
        color: const Color(0xFF1F9254),
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
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFF7B4FE0),
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

  // ==================================================================
  // DATA - EXTENSION AND DEVELOPER DATA
  // ==================================================================

  static final List<List<_SettingsGroup>> _extensionSettingsColumns = [
    [
      _SettingsGroup(
        icon: Icons.extension_outlined,
        color: const Color(0xFF2D7FF9),
        title: 'Integrations & Market...',
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
        color: const Color(0xFF7B4FE0),
        title: 'Developer Data',
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

// ===================================================================
// SETTINGS GROUP (icon + title + list of link labels)
// ===================================================================

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