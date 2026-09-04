import 'package:flutter/material.dart';

class DashboardNavBar extends StatelessWidget {
  const DashboardNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // =========================
          // ORGANIZATION HEADER
          // Same gradient as dashboard
          // =========================
          Container(
            height: 160,
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
            padding: const EdgeInsets.all(16),
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

          // =========================
          // DASHBOARD
          // =========================
          ListTile(
            leading: const Icon(
              Icons.dashboard,
              color: Colors.white,
            ),
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            selected: true,
            selectedTileColor: Colors.white12,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // =========================
          // ITEMS
          // =========================
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

          // =========================
          // INVENTORY
          // =========================
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

          // =========================
          // SALES
          // =========================
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

          // =========================
          // PURCHASE
          // =========================
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

          // =========================
          // ACCOUNTS
          // =========================
          ExpansionTile(
            leading: const Icon(
              Icons.account_balance,
              color: Colors.white,
            ),
            title: const Text(
              'Accounts',
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

          // =========================
          // DIVIDER
          // =========================
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 1,
          ),

          // =========================
          // REPORTS
          // =========================
          _mainMenuItem(
            icon: Icons.description,
            title: 'Reports',
          ),

          // =========================
          // FLUXA HUB
          // =========================
          _mainMenuItem(
            icon: Icons.hub,
            title: 'Fluxa Hub',
          ),

          // =========================
          // SETTINGS
          // =========================
          _mainMenuItem(
            icon: Icons.settings,
            title: 'Settings',
          ),

          // =========================
          // MY ACCOUNT
          // =========================
          _mainMenuItem(
            icon: Icons.account_circle,
            title: 'My Account',
          ),
        ],
      ),
    );
  }

  // =========================
  // MAIN MENU ITEM
  // =========================
  Widget _mainMenuItem({
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      onTap: () {},
    );
  }

  // =========================
  // SUB MENU ITEM
  // =========================
  Widget _subMenuItem(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 72,
      ),
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
        ),
      ),
      onTap: () {},
    );
  }
}