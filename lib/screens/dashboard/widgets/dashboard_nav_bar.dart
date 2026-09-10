import 'package:flutter/material.dart';

class DashboardNavBar extends StatefulWidget {
  final bool isCollapsed;
  final ValueChanged<String> onPageSelected;

  const DashboardNavBar({
    super.key,
    required this.isCollapsed,
    required this.onPageSelected,
  });

  @override
  State<DashboardNavBar> createState() =>
      _DashboardNavBarState();
}

class _DashboardNavBarState extends State<DashboardNavBar> {
  // Only ONE dropdown can be open at a time.
  String? _openSection;

  void _toggleSection(String section) {
    setState(() {
      if (_openSection == section) {
        // Clicking the same dropdown closes it.
        _openSection = null;
      } else {
        // Open selected dropdown.
        // Previous dropdown automatically closes.
        _openSection = section;
      }
    });
  }

  bool _isOpen(String section) {
    return _openSection == section;
  }

  @override
  void didUpdateWidget(covariant DashboardNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When sidebar is collapsed, close any open dropdown.
    if (widget.isCollapsed && !oldWidget.isCollapsed) {
      _openSection = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,

      // FULL SIDEBAR / ICON ONLY SIDEBAR
      width: widget.isCollapsed ? 72 : 245,

      decoration: const BoxDecoration(
        color: Color(0xFF0D2B4E),
      ),

      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // DASHBOARD
              // =====================================================

              _simpleMenuItem(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                onTap: () {
                  // Dashboard navigation here
                },
              ),

              _menuSpace(),

              // =====================================================
              // ITEMS
              // =====================================================

              _dropdownMenu(
                section: 'items',
                icon: Icons.inventory_2_outlined,
                title: 'Items',
                children: [
                  _subMenuItem(
                    icon: Icons.list_alt_outlined,
                    title: 'Items',
                    onTap: () {
                      // Items page
                    },
                  ),

                  _subMenuItem(
                    icon: Icons.category_outlined,
                    title: 'part',
                    onTap: () {},
                  ),
                ],
              ),

              _menuSpace(),

              // =====================================================
              // INVENTORY
              // =====================================================

              _dropdownMenu(
                section: 'inventory',
                icon: Icons.warehouse_outlined,
                title: 'Inventory',
                children: [
                  _subMenuItem(
                    icon: Icons.inventory_outlined,
                    title: 'Current Stock',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.tune_outlined,
                    title: 'Inventory Adjustments',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.assignment_return_outlined,
                    title: 'Returnable Assets',
                    onTap: () {},
                  ),
                ],
              ),

              _menuSpace(),

              // =====================================================
              // SALES
              // =====================================================

              _dropdownMenu(
                section: 'sales',
                icon: Icons.point_of_sale_outlined,
                title: 'Sales',
                children: [
                  _subMenuItem(
                    icon: Icons.people_outline,
                    title: 'Customers',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Estimates',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Sales Orders',
                    onTap: () {},
                  ),

                  
                  _subMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Invoices',
                    onTap: () {},
                  ),
                  _subMenuItem(
                    icon: Icons.local_shipping_outlined ,
                    title: 'Delivery Challans',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Payments received ',
                    onTap: () {},
                  ),
                   _subMenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Credit Notes ',
                    onTap: () {},
                  ),
                ],
              ),

              _menuSpace(),

              // =====================================================
              // PURCHASE
              // =====================================================

              _dropdownMenu(
                section: 'purchase',
                icon: Icons.shopping_cart_outlined,
                title: 'Purchase',
                children: [
                  _subMenuItem(
                    icon: Icons.store_outlined,
                    title: 'Vendors',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.shopping_cart_checkout_outlined,
                    title: 'Purchase Orders',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Bills',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payments Made',
                    onTap: () {},
                  ),
                  _subMenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'vendor Credit Notes',
                    onTap: () {},
                  ),
                ],
              ),

              _menuSpace(),

              // =====================================================
              // ACCOUNTANT
              // =====================================================

              _dropdownMenu(
                section: 'accountant',
                icon: Icons.account_balance_outlined,
                title: 'Accountant',
                children: [
                  _subMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Expenses',
                    onTap: () {},
                  ),

                  _subMenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Reimbursements',
                    onTap: () {},
                  ),
                  _subMenuItem(
                    icon: Icons.flight_takeoff_outlined,
                    title: 'Travel Allowance',
                    onTap: () {},
                  ),
                  _subMenuItem(
                    icon: Icons.request_quote_outlined,
                    title: 'Other Claims',
                    onTap: () {},
                  ),
                  _subMenuItem(
                    icon: Icons.savings_outlined,
                    title: 'Investments',
                    onTap: () {},
                  ),
                  _subMenuItem(
                    icon: Icons.account_balance_outlined,
                    title: 'Loans',
                    onTap: () {},
                  ),
                ],
              ),

              _menuSpace(),

              // =====================================================
              // _menuSpace(),
              _simpleMenuItem(
                icon: Icons.bar_chart_outlined,
                title: 'Reports',
                onTap: () => widget.onPageSelected('reports'),
              ),
              // =====================================================

              

    

              

              // =====================================================
              // SETTINGS
              // =====================================================

              

              

              _menuSpace(),

              // =====================================================
              // MY ACCOUNT
              // =====================================================

              

              _menuSpace(),

              // =====================================================
              // DIVIDER
              // =====================================================

              if (!widget.isCollapsed) ...[
                const SizedBox(height: 6),

                const Divider(
                  color: Colors.white24,
                  thickness: 1,
                ),

                const SizedBox(height: 6),
              ],
              _simpleMenuItem(
                icon: Icons.account_circle_outlined,
                title:'FluxaHub',
                onTap:(){},
              ),
              _menuSpace(),
              
              _simpleMenuItem(
                icon:Icons.settings_outlined,
                title:'Settings',
                onTap:(){},
              ),


              _simpleMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help',
                onTap: () {},
              ),

              _menuSpace(),

              // =====================================================
              //
              // =====================================================

              _simpleMenuItem(
                icon: Icons.quiz_outlined,
                title: "FAQ's",
                onTap: () {},
              ),
              _menuSpace(),
              

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SPACE BETWEEN MAIN MENU OPTIONS
  // =========================================================================

  Widget _menuSpace() {
    return const SizedBox(height: 7);
  }

  // =========================================================================
  // SIMPLE MENU ITEM
  // Dashboard / My Account / Help / FAQ
  // =========================================================================

  Widget _simpleMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withValues(alpha: 0.08),

        child: Container(
          height: 50,

          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 14,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),

          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),

              if (!widget.isCollapsed) ...[
                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  // =========================================================================
  // DROPDOWN MAIN MENU
  // =========================================================================

  Widget _dropdownMenu({
    required String section,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final bool opened = _isOpen(section);

    // When collapsed, show icon only.
    if (widget.isCollapsed) {
      return Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withValues(alpha: 0.08),

          child: Container(
            width: double.infinity,
            height: 50,

            alignment: Alignment.center,

            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // ====================================================================
        // MAIN DROPDOWN BUTTON
        // ====================================================================

        Material(
          color: Colors.transparent,

          child: InkWell(
            onTap: () {
              _toggleSection(section);
            },

            borderRadius: BorderRadius.circular(10),

            hoverColor: Colors.white.withValues(alpha: 0.08),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              height: 50,

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              decoration: BoxDecoration(
                color: opened
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.transparent,

                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      title,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),

                    turns: opened ? 0.5 : 0,

                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ====================================================================
        // DROPDOWN OPTIONS
        // ====================================================================

        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,

          child: opened
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 3,
                  ),

                  child: Column(
                    children: children,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // =========================================================================
  // DROPDOWN SUB MENU
  // =========================================================================

  Widget _subMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 13,
        right: 4,
        bottom: 3,
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(8),

          hoverColor: Colors.white.withValues(alpha: 0.08),

          child: Container(
            height: 42,

            padding: const EdgeInsets.only(
              left: 22,
              right: 10,
            ),

            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white70,
                  size: 18,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}