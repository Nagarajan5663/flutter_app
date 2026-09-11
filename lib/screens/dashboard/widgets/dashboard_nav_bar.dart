import 'package:flutter/material.dart';

class DashboardNavBar extends StatelessWidget {
  final bool isCollapsed;
  final ValueChanged<String> onPageSelected;

  const DashboardNavBar({
    super.key,
    required this.isCollapsed,
    required this.onPageSelected,
  });

  static const double expandedWidth = 270;
  static const double collapsedWidth = 80;

  void _selectPage(String page) {
    onPageSelected(page);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? collapsedWidth : expandedWidth,
      color: const Color(0xFF0D1B2A),
      child: Column(
        children: [
          // ============================================================
          // ORGANIZATION HEADER
          // ============================================================

          _buildOrganizationHeader(),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ======================================================
                // DASHBOARD
                // ======================================================

                _mainMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () => _selectPage('dashboard'),
                ),

                // ======================================================
                // ITEMS
                // ======================================================

                _buildExpansionMenu(
                  icon: Icons.inventory_2_outlined,
                  title: 'Items',
                  children: [
                    _subMenuItem(
                      'Items',
                      () => _selectPage('items'),
                    ),
                    _subMenuItem(
                      'Parts',
                      () => _selectPage('parts'),
                    ),
                  ],
                ),

                // ======================================================
                // INVENTORY
                // ======================================================

                _buildExpansionMenu(
                  icon: Icons.warehouse_outlined,
                  title: 'Inventory',
                  children: [
                    _subMenuItem(
                      'Current Stock',
                      () => _selectPage('current-stock'),
                    ),
                    _subMenuItem(
                      'Inventory Adjustments',
                      () => _selectPage('inventory-adjustments'),
                    ),
                    _subMenuItem(
                      'Returnable Assets',
                      () => _selectPage('returnable-assets'),
                    ),
                  ],
                ),

                // ======================================================
                // SALES
                // ======================================================

                _buildExpansionMenu(
                  icon: Icons.trending_up,
                  title: 'Sales',
                  children: [
                    _subMenuItem(
                      'Customers',
                      () => _selectPage('customers'),
                    ),
                    _subMenuItem(
                      'Estimates',
                      () => _selectPage('estimates'),
                    ),
                    _subMenuItem(
                      'Sales Order',
                      () => _selectPage('sales-order'),
                    ),
                    _subMenuItem(
                      'Invoices',
                      () => _selectPage('invoices'),
                    ),
                    _subMenuItem(
                      'Delivery Challans',
                      () => _selectPage('delivery-challans'),
                    ),
                    _subMenuItem(
                      'Payment Received',
                      () => _selectPage('payment-received'),
                    ),
                    _subMenuItem(
                      'Credit Notes',
                      () => _selectPage('credit-notes'),
                    ),
                  ],
                ),

                // ======================================================
                // PURCHASE
                // ======================================================

                _buildExpansionMenu(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Purchase',
                  children: [
                    _subMenuItem(
                      'Vendors',
                      () => _selectPage('vendors'),
                    ),
                    _subMenuItem(
                      'Purchase Orders',
                      () => _selectPage('purchase-orders'),
                    ),
                    _subMenuItem(
                      'Bills',
                      () => _selectPage('bills'),
                    ),
                    _subMenuItem(
                      'Payment Made',
                      () => _selectPage('payment-made'),
                    ),
                    _subMenuItem(
                      'Vendor Credit Notes',
                      () => _selectPage('vendor-credit-notes'),
                    ),
                  ],
                ),

                // ======================================================
                // ACCOUNTS
                // ======================================================

                _buildExpansionMenu(
                  icon: Icons.account_balance_outlined,
                  title: 'Accounts',
                  children: [
                    _subMenuItem(
                      'Expenses',
                      () => _selectPage('expenses'),
                    ),
                    _subMenuItem(
                      'Reimbursements',
                      () => _selectPage('reimbursements'),
                    ),
                    _subMenuItem(
                      'Travel Allowance',
                      () => _selectPage('travel-allowance'),
                    ),
                    _subMenuItem(
                      'Other Claims',
                      () => _selectPage('other-claims'),
                    ),
                    _subMenuItem(
                      'Investments',
                      () => _selectPage('investments'),
                    ),
                    _subMenuItem(
                      'Loans',
                      () => _selectPage('loans'),
                    ),
                  ],
                ),

                const Divider(
                  color: Color(0xFF334155),
                  height: 24,
                ),

                // ======================================================
                // REPORTS
                // ======================================================

                _mainMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Reports',
                  onTap: () => _selectPage('reports'),
                ),

                // ======================================================
                // FLUXA HUB
                // ======================================================

                _mainMenuItem(
                  icon: Icons.hub_outlined,
                  title: 'Fluxa Hub',
                  onTap: () => _selectPage('fluxa-hub'),
                ),

                // ======================================================
                // SETTINGS
                // ======================================================

                _mainMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => _selectPage('settings'),
                ),

                // ======================================================
                // MY ACCOUNT
                // ======================================================

                _mainMenuItem(
                  icon: Icons.account_circle_outlined,
                  title: 'My Account',
                  onTap: () => _selectPage('my-account'),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORGANIZATION HEADER
  // ============================================================

  Widget _buildOrganizationHeader() {
    return InkWell(
      onTap: () => _selectPage('organization'),
      hoverColor: Colors.white10,
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF123A5C),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.business,
              color: Colors.white,
              size: 30,
            ),

            if (!isCollapsed) ...[
              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Organization',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN MENU ITEM
  // ============================================================

  Widget _mainMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.white10,
      mouseCursor: SystemMouseCursors.click,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            SizedBox(
              width: collapsedWidth,
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            if (!isCollapsed)
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EXPANSION MENU
  // ============================================================

  Widget _buildExpansionMenu({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    if (isCollapsed) {
      return InkWell(
        onTap: () {},
        hoverColor: Colors.white10,
        mouseCursor: SystemMouseCursors.click,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 80,
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        children: children,
      ),
    );
  }

  // ============================================================
  // SUB MENU ITEM
  // ============================================================

  Widget _subMenuItem(
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.white10,
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        height: 42,
        padding: const EdgeInsets.only(
          left: 92,
          right: 16,
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}