import 'package:flutter/material.dart';

class DashboardNavBar extends StatefulWidget {
  final bool isCollapsed;
  final String selectedMenu;
  final ValueChanged<String> onMenuSelected;

  const DashboardNavBar({
    super.key,
    required this.isCollapsed,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  State<DashboardNavBar> createState() => _DashboardNavBarState();
}

class _DashboardNavBarState extends State<DashboardNavBar> {
  String? _openSection;

  bool get isCollapsed => widget.isCollapsed;

  String get selectedMenu => widget.selectedMenu;

  ValueChanged<String> get onMenuSelected => widget.onMenuSelected;

  @override
  void didUpdateWidget(covariant DashboardNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isCollapsed && widget.isCollapsed) {
      setState(() {
        _openSection = null;
      });
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 270,
      height: double.infinity,
      color: const Color(0xFF123653),
      child: Column(
        children: [
          // =========================================================
          // ORGANIZATION HEADER
          // =========================================================

          _buildOrganizationHeader(),

          // =========================================================
          // MENU
          // =========================================================

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 8 : 14,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // =================================================
                    // DASHBOARD
                    // =================================================

                    _menuItem(
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      selected: _isSelected('dashboard'),
                      onTap: () {
                        onMenuSelected('dashboard');
                      },
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // ITEMS
                    // =================================================

                    _sectionMenu(
                      icon: Icons.inventory_2_outlined,
                      title: 'Items',
                      sectionKey: 'items',
                      children: const [
                        'Items',
                        'Parts',
                      ],
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // INVENTORY
                    // =================================================

                    _sectionMenu(
                      icon: Icons.warehouse_outlined,
                      title: 'Inventory',
                      sectionKey: 'inventory',
                      children: const [
                        'Current Stock',
                        'Inventory Adjustments',
                        'Returnable Assets',
                      ],
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // SALES
                    // =================================================

                    _sectionMenu(
                      icon: Icons.show_chart_rounded,
                      title: 'Sales',
                      sectionKey: 'sales',
                      children: const [
                        'Customers',
                        'Estimates',
                        'Sales Order',
                        'Invoices',
                        'Delivery Challans',
                        'Payment Received',
                        'Credit Notes',
                      ],
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // PURCHASE
                    // =================================================

                    _sectionMenu(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Purchase',
                      sectionKey: 'purchase',
                      children: const [
                        'Vendors',
                        'Purchase Orders',
                        'Bills',
                        'Payment Made',
                        'Vendor Credit Notes',
                      ],
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // ACCOUNTANT
                    // =================================================

                    _sectionMenu(
                      icon: Icons.calculate_outlined,
                      title: 'Accountant',
                      sectionKey: 'accountant',
                      children: const [
                        'Expense',
                        'Reimbursements',
                        'Travel Allowance',
                        'Other Claims',
                        'Investments',
                        'Loans',
                      ],
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // REPORTS
                    // =================================================

                    _menuItem(
                      icon: Icons.description_outlined,
                      title: 'Reports',
                      selected: _isSelected('reports'),
                      onTap: () {
                        onMenuSelected('reports');
                      },
                    ),

                    const SizedBox(height: 20),

                    const Divider(
                      color: Color(0xFF31516F),
                      thickness: 1,
                      height: 1,
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // FLUXA HUB
                    // =================================================

                    _menuItem(
                      icon: Icons.hub_outlined,
                      title: 'Fluxa Hub',
                      selected: _isSelected('fluxa hub'),
                      onTap: () {
                        onMenuSelected('fluxa hub');
                      },
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // SETTINGS
                    // =================================================

                    _menuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      selected: _isSelected('settings'),
                      onTap: () {
                        onMenuSelected('settings');
                      },
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // MY ACCOUNT
                    // =================================================

                    _menuItem(
                      icon: Icons.account_circle_outlined,
                      title: 'My Account',
                      selected: _isSelected('my account'),
                      onTap: () {
                        onMenuSelected('my account');
                      },
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // HELP
                    // =================================================

                    _menuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help',
                      selected: _isSelected('help'),
                      onTap: () {
                        onMenuSelected('help');
                      },
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ORGANIZATION HEADER
  // ===============================================================

  Widget _buildOrganizationHeader() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onMenuSelected('organization');
        },
        hoverColor: Colors.white10,
        mouseCursor: SystemMouseCursors.click,
        child: Container(
          height: 88,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF123A5C),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.business_outlined,
                color: Colors.white,
                size: 28,
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
      ),
    );
  }

  // ===============================================================
  // CHECK SELECTED MENU
  // ===============================================================

  bool _isSelected(String menu) {
    final current = selectedMenu.toLowerCase().trim();
    final value = menu.toLowerCase().trim();

    if (current == value) {
      return true;
    }

    // -------------------------------------------------------------
    // ITEMS SECTION
    // -------------------------------------------------------------

    if (value == 'items') {
      return current == 'items' || current == 'parts';
    }

    // -------------------------------------------------------------
    // INVENTORY SECTION
    // -------------------------------------------------------------

    if (value == 'inventory') {
      return current == 'inventory' ||
          current == 'current stock' ||
          current == 'inventory adjustments' ||
          current == 'returnable assets' ||
          current == 'current-stock' ||
          current == 'inventory-adjustments' ||
          current == 'returnable-assets';
    }

    // -------------------------------------------------------------
    // SALES SECTION
    // -------------------------------------------------------------

    if (value == 'sales') {
      return [
        'sales',
        'customers',
        'estimates',
        'sales order',
        'sales-order',
        'invoices',
        'delivery challans',
        'delivery-challans',
        'payment received',
        'payment-received',
        'credit notes',
        'credit-notes',
      ].contains(current);
    }

    // -------------------------------------------------------------
    // PURCHASE SECTION
    // -------------------------------------------------------------

    if (value == 'purchase') {
      return [
        'purchase',
        'vendors',
        'purchase orders',
        'purchase-orders',
        'bills',
        'payment made',
        'payment-made',
        'vendor credit notes',
        'vendor-credit-notes',
      ].contains(current);
    }

    // -------------------------------------------------------------
    // ACCOUNTANT SECTION
    // -------------------------------------------------------------

    if (value == 'accountant') {
      return [
        'accountant',
        'expense',
        'expenses',
        'reimbursements',
        'travel allowance',
        'travel-allowance',
        'other claims',
        'other-claims',
        'investments',
        'loans',
      ].contains(current);
    }

    return false;
  }

  // ===============================================================
  // EXPANDABLE MENU SECTION
  // ===============================================================

  Widget _sectionMenu({
    required IconData icon,
    required String title,
    required String sectionKey,
    required List<String> children,
  }) {
    if (isCollapsed) {
      return _menuItem(
        icon: icon,
        title: title,
        selected: _isSelected(sectionKey),
        onTap: () {
          onMenuSelected(sectionKey);
        },
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
      ),
      child: ExpansionTile(
        key: ValueKey(
          '$title-${_openSection == title}',
        ),
        initiallyExpanded: _openSection == title,

        onExpansionChanged: (isExpanded) {
          setState(() {
            _openSection = isExpanded ? title : null;
          });
        },

        tilePadding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),

        childrenPadding: const EdgeInsets.only(
          bottom: 6,
        ),

        leading: Icon(
          icon,
          size: 21,
          color: Colors.white,
        ),

        iconColor: Colors.white,
        collapsedIconColor: Colors.white,

        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: _isSelected(sectionKey)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),

        backgroundColor: const Color(0xFF123653),
        collapsedBackgroundColor: const Color(0xFF123653),

        children: [
          for (final child in children) _subMenuItem(child),
        ],
      ),
    );
  }

  // ===============================================================
  // SUB MENU ITEM
  // ===============================================================

  Widget _subMenuItem(String title) {
    final selected = _isSelected(title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onMenuSelected(title);
        },
        hoverColor: Colors.white10,
        mouseCursor: SystemMouseCursors.click,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 42,
          ),
          padding: const EdgeInsets.only(
            left: 58,
            right: 14,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF245AA6).withOpacity(0.55)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: selected
                    ? Colors.white
                    : Colors.white70,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // NORMAL MENU ITEM
  // ===============================================================

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white10,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 50,
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF245AA6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 21,
                color: Colors.white,
              ),

              if (!isCollapsed) ...[
                const SizedBox(width: 17),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}