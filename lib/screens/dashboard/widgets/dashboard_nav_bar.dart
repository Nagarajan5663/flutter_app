import 'package:flutter/material.dart';

class DashboardNavBar extends StatelessWidget {
  final String selectedMenu;
  final ValueChanged<String> onMenuSelected;

  const DashboardNavBar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: double.infinity,
      color: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D2B4E),
                  Color(0xFF123A5C),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'Organization',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // DASHBOARD
          // ======================================================

          _mainMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
          ),

          // ======================================================
          // ITEMS
          // ======================================================

          ExpansionTile(
            leading: const Icon(
              Icons.inventory_2,
              color: Colors.white,
            ),
            title: const Text(
              'Items',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              _subMenuItem('Items'),
              _subMenuItem('Parts'),
            ],
          ),

          // ======================================================
          // INVENTORY
          // ======================================================

          ExpansionTile(
            leading: const Icon(
              Icons.warehouse,
              color: Colors.white,
            ),
            title: const Text(
              'Inventory',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              _subMenuItem('Current Stock'),
              _subMenuItem('Inventory Adjustments'),
              _subMenuItem('Returnable Assets'),
            ],
          ),

          // ======================================================
          // SALES
          // ======================================================

          ExpansionTile(
            leading: const Icon(
              Icons.trending_up,
              color: Colors.white,
            ),
            title: const Text(
              'Sales',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              _subMenuItem('Customers'),
              _subMenuItem('Estimates'),
              _subMenuItem('Sales Order'),
              _subMenuItem('Invoices'),
              _subMenuItem('Delivery Challans'),
              _subMenuItem('Payment Received'),
              _subMenuItem('Credit Notes'),
            ],
          ),

          // ======================================================
          // PURCHASE
          // ======================================================

          ExpansionTile(
            leading: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            title: const Text(
              'Purchase',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              _subMenuItem('Vendors'),
              _subMenuItem('Purchase Orders'),
              _subMenuItem('Bills'),
              _subMenuItem('Payment Made'),
              _subMenuItem('Vendor Credit Notes'),
            ],
          ),

          // ======================================================
          // ACCOUNTS
          // ======================================================

          ExpansionTile(
            leading: const Icon(
              Icons.account_balance,
              color: Colors.white,
            ),
            title: const Text(
              'Accountant',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              _subMenuItem('Expense'),
              _subMenuItem('Reimbursements'),
              _subMenuItem('Travel Allowance'),
              _subMenuItem('Other Claims'),
              _subMenuItem('Investments'),
              _subMenuItem('Loans'),
            ],
          ),

          const Divider(
            color: Colors.grey,
            height: 1,
          ),

          // ======================================================
          // OTHER MENU
          // ======================================================

          _mainMenuItem(
            icon: Icons.description,
            title: 'Reports',
          ),

          _mainMenuItem(
            icon: Icons.hub,
            title: 'Fluxa Hub',
          ),

          _mainMenuItem(
            icon: Icons.settings,
            title: 'Settings',
          ),

          _mainMenuItem(
            icon: Icons.account_circle,
            title: 'My Account',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN MENU ITEM
  // ============================================================

  Widget _mainMenuItem({
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = selectedMenu == title;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.white12,

      leading: Icon(
        icon,
        color: Colors.white,
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),

      onTap: () {
        onMenuSelected(title);
      },
    );
  }

  // ============================================================
  // SUB MENU ITEM
  // ============================================================

  Widget _subMenuItem(String title) {
    final bool isSelected = selectedMenu == title;

    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 72,
      ),

      selected: isSelected,
      selectedTileColor: Colors.white12,

      leading: const Text(
        '•',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      onTap: () {
        // IMPORTANT:
        // We do NOT Navigator.push().
        // We only change the content on the right.
        onMenuSelected(title);
      },
    );
  }
}