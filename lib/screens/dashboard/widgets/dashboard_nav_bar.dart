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
      _openSection = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 250,
      height: double.infinity,
      color: const Color(0xFF123653),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 14,
            vertical: 18,
          ),
          child: Column(
            children: [
              // =====================================================
              // DASHBOARD
              // =====================================================
              _menuItem(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                selected: _isSelected('dashboard'),
                onTap: () {
                  onMenuSelected('dashboard');
                },
              ),

              const SizedBox(height: 7),

              // =====================================================
              // ITEMS
              // =====================================================
              _sectionMenu(
                icon: Icons.inventory_2_outlined,
                title: 'Items',
                selected: _isSelected('items'),
                children: const [
                  'Items',
                  'Parts',
                ],
              ),

              const SizedBox(height: 7),

              // =====================================================
              // INVENTORY
              // =====================================================
              _sectionMenu(
                icon: Icons.warehouse_outlined,
                title: 'Inventory',
                selected: _isSelected('inventory'),
                children: const [
                  'Current Stock',
                  'Inventory Adjustments',
                  'Returnable Assets',
                ],
              ),

              const SizedBox(height: 7),

              // =====================================================
              // SALES
              // =====================================================
              _sectionMenu(
                icon: Icons.show_chart_rounded,
                title: 'Sales',
                selected: _isSelected('sales'),
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

              // =====================================================
              // PURCHASE
              // =====================================================
              _sectionMenu(
                icon: Icons.shopping_cart_outlined,
                title: 'Purchase',
                selected: _isSelected('purchase'),
                children: const [
                  'Vendors',
                  'Purchase Orders',
                  'Bills',
                  'Payment Made',
                  'Vendor Credit Notes',
                ],
              ),

              const SizedBox(height: 7),

              // =====================================================
              // ACCOUNTANT
              // =====================================================
              _sectionMenu(
                icon: Icons.calculate_outlined,
                title: 'Accountant',
                selected: _isSelected('accountant'),
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

              // =====================================================
              // REPORTS
              // =====================================================
              _menuItem(
                icon: Icons.description_outlined,
                title: 'Reports',
                selected: _isSelected('reports'),
                onTap: () {
                  onMenuSelected('reports');
                },
              ),

              const SizedBox(height: 20),

              // =====================================================
              // DIVIDER
              // =====================================================
              const Divider(
                color: Color(0xFF31516F),
                thickness: 1,
                height: 1,
              ),

              const SizedBox(height: 20),

              // =====================================================
              // FLUXA HUB
              // =====================================================
              _menuItem(
                icon: Icons.hub_outlined,
                title: 'Fluxa Hub',
                selected: _isSelected('fluxa hub'),
                onTap: () {
                  onMenuSelected('fluxa hub');
                },
              ),

              const SizedBox(height: 7),

              // =====================================================
              // SETTINGS
              // NO DROPDOWN
              // NO NAVIGATION
              // =====================================================
              _menuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  // No functionality
                },
              ),

              const SizedBox(height: 7),

              // =====================================================
              // MY ACCOUNT
              // =====================================================
              _menuItem(
                icon: Icons.account_circle_outlined,
                title: 'My Account',
                selected: _isSelected('my account'),
                onTap: () {
                  onMenuSelected('my account');
                },
              ),

              const SizedBox(height: 7),

              // =====================================================
              // HELP
              // =====================================================
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
    );
  }

  // ===============================================================
  // CHECK SELECTED MENU
  // ===============================================================
  bool _isSelected(String menu) {
    return selectedMenu.toLowerCase().trim() ==
        menu.toLowerCase().trim();
  }

  // ===============================================================
  // EXPANDABLE MENU SECTION
  // ===============================================================
  Widget _sectionMenu({
    required IconData icon,
    required String title,
    required List<String> children,
    bool selected = false,
  }) {
    if (isCollapsed) {
      return _menuItem(
        icon: icon,
        title: title,
        selected: selected,
        onTap: () => onMenuSelected(
          title.toLowerCase(),
        ),
      );
    }

    return ExpansionTile(
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),

      backgroundColor: const Color(0xFF123653),
      collapsedBackgroundColor:
          const Color(0xFF123653),

      children: [
        for (final child in children)
          _subMenuItem(child),
      ],
    );
  }

  // ===============================================================
  // SUB MENU ITEM
  // ===============================================================
  Widget _subMenuItem(String title) {
    return ListTile(
      dense: true,

      contentPadding: const EdgeInsets.only(
        left: 62,
        right: 12,
      ),

      selected: _isSelected(title),
      selectedTileColor: Colors.transparent,

      leading: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Colors.white70,
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),

      onTap: () {
        onMenuSelected(title);
      },
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
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),

        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 150,
          ),

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
              // ICON
              Icon(
                icon,
                size: 21,
                color: Colors.white,
              ),

              // Hide text when sidebar is collapsed
              if (!isCollapsed) ...[
                const SizedBox(width: 17),

                // MENU NAME
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // OPTIONAL ARROW
                if (showArrow)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}