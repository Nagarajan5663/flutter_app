import 'package:flutter/material.dart';

import 'shared/glass_widgets.dart';

import 'general/item_preferences_page.dart';
import 'sales/sales_order_preferences_page.dart';
import 'purchases/expanse_settings_page.dart';

import '../organization_page.dart';
import './organization/manage_subscription_page.dart';
import './organization/general_settings_page.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onClose;

  const SettingsPage({
    super.key,
    this.onClose,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  bool _showOrganizationProfile = false;
  bool _showGeneralSettings = false;
  bool _showManageSubscription = false;

  final TextEditingController
      _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // ORGANIZATION PROFILE
  // ================================================================

  void _openOrganizationProfile() {
    setState(() {
      _showOrganizationProfile = true;
      _showGeneralSettings = false;
      _showManageSubscription = false;
    });
  }

  // ================================================================
  // GENERAL SETTINGS
  // ================================================================

  void _openGeneralSettings() {
    setState(() {
      _showOrganizationProfile = false;
      _showGeneralSettings = true;
      _showManageSubscription = false;
    });
  }

  // ================================================================
  // MANAGE SUBSCRIPTION
  // ================================================================

  void _openManageSubscription() {
    setState(() {
      _showOrganizationProfile = false;
      _showGeneralSettings = false;
      _showManageSubscription = true;
    });
  }

  // ================================================================
  // ITEMS
  // ================================================================

  void _openItemPreferences() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const ItemPreferencesPage(),
      ),
    );
  }

  // ================================================================
  // SALES ORDERS
  // ================================================================

  void _openSalesOrderPreferences() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const SalesOrderPreferencesPage(),
      ),
    );
  }

  // ================================================================
  // EXPENSE SETTINGS
  // ================================================================

  void _openExpenseSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const ExpenseSettingsPage(),
      ),
    );
  }

  // ================================================================
  // BACK
  // ================================================================

  void _backToAllSettings() {
    setState(() {
      _showOrganizationProfile = false;
      _showGeneralSettings = false;
      _showManageSubscription = false;
    });
  }

  // ================================================================
  // COMING SOON
  // ================================================================

  void _showComingSoon(
    String title,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$title - Coming Soon',
        ),
        duration:
            const Duration(
          seconds: 1,
        ),
      ),
    );
  }

  // ================================================================
  // SEARCH
  // ================================================================

  bool _matches(
    String text,
  ) {
    if (_searchText
        .trim()
        .isEmpty) {
      return true;
    }

    return text
        .toLowerCase()
        .contains(
          _searchText
              .toLowerCase()
              .trim(),
        );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_showOrganizationProfile) {
      return OrganizationPage(
        onBack:
            _backToAllSettings,
      );
    }

    if (_showGeneralSettings) {
      return GeneralSettingsPage(
        onBack:
            _backToAllSettings,
      );
    }

    if (_showManageSubscription) {
      return ManageSubscriptionPage(
        onBack:
            _backToAllSettings,
      );
    }

    return GlassPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
            // =======================================================
            // HEADER
            // =======================================================

            GlassPanel(
              borderRadius:
                  BorderRadius.zero,
              child: Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  20,
                  18,
                  20,
                  16,
                ),
                child:
                    LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final isSmall =
                        constraints
                                .maxWidth <
                            750;

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          _buildTitle(),
                          const SizedBox(
                            height: 14,
                          ),
                          SizedBox(
                            width:
                                double.infinity,
                            height: 38,
                            child:
                                _buildSearchField(),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child:
                              _buildTitle(),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        SizedBox(
                          width: 220,
                          height: 38,
                          child:
                              _buildSearchField(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // =======================================================
            // ORGANIZATION SETTINGS
            // =======================================================

            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                18,
                20,
                0,
              ),
              child: GlassPanel(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    18,
                    18,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Organization Settings',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Divider(
                        height: 1,
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.16,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      LayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          if (constraints
                                  .maxWidth >=
                              1100) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      _organizationColumn(),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Expanded(
                                  child:
                                      _usersAndTaxColumn(),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Expanded(
                                  child:
                                      _setupColumn(),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Expanded(
                                  child:
                                      _customizationColumn(),
                                ),
                              ],
                            );
                          }

                          if (constraints
                                  .maxWidth >=
                              600) {
                            final width =
                                (constraints.maxWidth -
                                        22) /
                                    2;

                            return Wrap(
                              spacing: 22,
                              runSpacing: 26,
                              children: [
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _organizationColumn(),
                                ),
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _usersAndTaxColumn(),
                                ),
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _setupColumn(),
                                ),
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _customizationColumn(),
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              _organizationColumn(),
                              const SizedBox(
                                height: 26,
                              ),
                              _usersAndTaxColumn(),
                              const SizedBox(
                                height: 26,
                              ),
                              _setupColumn(),
                              const SizedBox(
                                height: 26,
                              ),
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

            // =======================================================
            // MODULE SETTINGS
            // =======================================================

            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                18,
                20,
                26,
              ),
              child: GlassPanel(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    18,
                    18,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Module Settings',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Divider(
                        height: 1,
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.16,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      LayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          if (constraints
                                  .maxWidth >=
                              1050) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      _generalModuleColumn(),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Expanded(
                                  child:
                                      _inventoryModuleColumn(),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Expanded(
                                  child:
                                      _salesModuleColumn(),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Expanded(
                                  child:
                                      _purchasesModuleColumn(),
                                ),
                              ],
                            );
                          }

                          if (constraints
                                  .maxWidth >=
                              600) {
                            final width =
                                (constraints.maxWidth -
                                        22) /
                                    2;

                            return Wrap(
                              spacing: 22,
                              runSpacing: 28,
                              children: [
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _generalModuleColumn(),
                                ),
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _inventoryModuleColumn(),
                                ),
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _salesModuleColumn(),
                                ),
                                SizedBox(
                                  width:
                                      width,
                                  child:
                                      _purchasesModuleColumn(),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _generalModuleColumn(),
                              const SizedBox(
                                height: 26,
                              ),
                              _inventoryModuleColumn(),
                              const SizedBox(
                                height: 26,
                              ),
                              _salesModuleColumn(),
                              const SizedBox(
                                height: 26,
                              ),
                              _purchasesModuleColumn(),
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
            fontWeight:
                FontWeight.w700,
          ),
        ),

        SizedBox(height: 4),

        Text(
          'Manage your organization settings and preferences',
          style: TextStyle(
            color:
                Color(0xFFAAB4C4),
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
    return TextField(
      controller:
          _searchController,
      style:
          const TextStyle(
        color:
            GlassSurface.inputText,
        fontSize: 13.5,
      ),
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration:
          InputDecoration(
        hintText:
            'Search settings (/)',
        hintStyle:
            TextStyle(
          color:
              GlassSurface.hintText,
          fontSize: 13.5,
        ),
        prefixIcon:
            Icon(
          Icons.search_rounded,
          size: 18,
          color:
              GlassSurface.hintText,
        ),
        suffixIcon:
            _searchText.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons
                          .close_rounded,
                      size: 16,
                      color:
                          GlassSurface
                              .hintText,
                    ),
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(() {
                        _searchText =
                            '';
                      });
                    },
                  )
                : null,
        filled: true,
        fillColor:
            GlassSurface.fill(),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            7,
          ),
          borderSide:
              BorderSide(
            color:
                GlassSurface.border(),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            7,
          ),
          borderSide:
              BorderSide(
            color:
                GlassSurface.border(
              focused: true,
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
          icon:
              Icons.business_rounded,
          iconColor:
              const Color(
            0xFF34A853,
          ),
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
          _comingSoonLink(
            'Branding',
          ),

        if (_matches(
          'Custom Domain',
        ))
          _comingSoonLink(
            'Custom Domain',
          ),

        if (_matches('Locations'))
          _comingSoonLink(
            'Locations',
          ),

        if (_matches(
          'Manage Subscription',
        ))
          _settingLink(
            title:
                'Manage Subscription',
            onTap:
                _openManageSubscription,
          ),
      ],
    );
  }

  // ================================================================
  // USERS + TAX
  // ================================================================

  Widget _usersAndTaxColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.groups_rounded,
          iconColor:
              const Color(
            0xFFE83E7E,
          ),
          title:
              'Users & Roles',
        ),

        const SizedBox(height: 8),

        if (_matches('Users'))
          _comingSoonLink(
            'Users',
          ),

        if (_matches('Roles'))
          _comingSoonLink(
            'Roles',
          ),

        if (_matches(
          'User Preferences',
        ))
          _comingSoonLink(
            'User Preferences',
          ),

        const SizedBox(
          height: 18,
        ),

        _sectionTitle(
          icon:
              Icons.shield_outlined,
          iconColor:
              const Color(
            0xFFE83E7E,
          ),
          title:
              'Taxes & Compliance',
        ),

        const SizedBox(height: 8),

        if (_matches('Taxes'))
          _comingSoonLink(
            'Taxes',
          ),

        if (_matches(
          'Direct Taxes',
        ))
          _comingSoonLink(
            'Direct Taxes',
          ),

        if (_matches(
          'e-Way Bills',
        ))
          _comingSoonLink(
            'e-Way Bills',
          ),

        if (_matches(
          'e-Invoicing',
        ))
          _comingSoonLink(
            'e-Invoicing',
          ),
      ],
    );
  }

  // ================================================================
  // SETUP
  // ================================================================

  Widget _setupColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.tune_rounded,
          iconColor:
              const Color(
            0xFFF59A0A,
          ),
          title:
              'Setup & Configurations',
        ),

        const SizedBox(height: 8),

        if (_matches(
          'Currencies',
        ))
          _comingSoonLink(
            'Currencies',
          ),

        if (_matches(
          'Opening Balances',
        ))
          _comingSoonLink(
            'Opening Balances',
          ),

        if (_matches(
          'Reminders',
        ))
          _comingSoonLink(
            'Reminders',
          ),

        if (_matches(
          'Customer Portal',
        ))
          _comingSoonLink(
            'Customer Portal',
          ),

        if (_matches(
          'Vendor Portal',
        ))
          _comingSoonLink(
            'Vendor Portal',
          ),
      ],
    );
  }

  // ================================================================
  // CUSTOMIZATION
  // ================================================================

  Widget _customizationColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.palette_outlined,
          iconColor:
              const Color(
            0xFF3478F6,
          ),
          title:
              'Customization',
        ),

        const SizedBox(height: 8),

        if (_matches(
          'Transaction Number Series',
        ))
          _comingSoonLink(
            'Transaction Number Series',
          ),

        if (_matches(
          'PDF Templates',
        ))
          _comingSoonLink(
            'PDF Templates',
          ),

        if (_matches(
          'Email Notifications',
        ))
          _comingSoonLink(
            'Email Notifications',
          ),

        if (_matches(
          'SMS Notifications',
        ))
          _comingSoonLink(
            'SMS Notifications',
          ),

        if (_matches(
          'Reporting Tags',
        ))
          _comingSoonLink(
            'Reporting Tags',
          ),

        if (_matches('Web Tabs'))
          _comingSoonLink(
            'Web Tabs',
          ),

        if (_matches(
          'Digital Signature',
        ))
          _comingSoonLink(
            'Digital Signature',
          ),
      ],
    );
  }

  // ================================================================
  // GENERAL MODULE
  // ================================================================

  Widget _generalModuleColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.apps_rounded,
          iconColor:
              const Color(
            0xFF34A853,
          ),
          title: 'General',
        ),

        const SizedBox(height: 8),

        if (_matches(
          'Customers and Vendors',
        ))
          _comingSoonLink(
            'Customers and Vendors',
          ),

        if (_matches('Items'))
          _settingLink(
            title: 'Items',
            onTap:
                _openItemPreferences,
          ),

        if (_matches('Accountant'))
          _comingSoonLink(
            'Accountant',
          ),

        if (_matches('Projects'))
          _comingSoonLink(
            'Projects',
          ),

        if (_matches('Timesheet'))
          _comingSoonLink(
            'Timesheet',
          ),
      ],
    );
  }

  // ================================================================
  // INVENTORY + ONLINE PAYMENTS
  // ================================================================

  Widget _inventoryModuleColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.inventory_2_rounded,
          iconColor:
              const Color(
            0xFFE83E7E,
          ),
          title: 'Inventory',
        ),

        const SizedBox(height: 8),

        if (_matches(
          'Inventory Adjustments',
        ))
          _comingSoonLink(
            'Inventory Adjustments',
          ),

        const SizedBox(
          height: 18,
        ),

        _sectionTitle(
          icon:
              Icons.credit_card_rounded,
          iconColor:
              const Color(
            0xFF3498DB,
          ),
          title:
              'Online Payments',
        ),

        const SizedBox(height: 8),

        if (_matches(
          'Customer Payments',
        ))
          _comingSoonLink(
            'Customer Payments',
          ),

        if (_matches(
          'Vendor Payments',
        ))
          _comingSoonLink(
            'Vendor Payments',
          ),
      ],
    );
  }

  // ================================================================
  // SALES MODULE
  // ================================================================

  Widget _salesModuleColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.show_chart_rounded,
          iconColor:
              const Color(
            0xFF009688,
          ),
          title: 'Sales',
        ),

        const SizedBox(height: 8),

        if (_matches('Estimates'))
          _comingSoonLink(
            'Estimates',
          ),

        if (_matches(
          'Sales Orders',
        ))
          _settingLink(
            title:
                'Sales Orders',
            onTap:
                _openSalesOrderPreferences,
          ),

        if (_matches(
          'Delivery Challans',
        ))
          _comingSoonLink(
            'Delivery Challans',
          ),

        if (_matches('Invoices'))
          _comingSoonLink(
            'Invoices',
          ),

        if (_matches(
          'Recurring Invoices',
        ))
          _comingSoonLink(
            'Recurring Invoices',
          ),

        if (_matches(
          'Payments Received',
        ))
          _comingSoonLink(
            'Payments Received',
          ),

        if (_matches(
          'Credit Notes',
        ))
          _comingSoonLink(
            'Credit Notes',
          ),

        if (_matches(
          'Delivery Notes',
        ))
          _comingSoonLink(
            'Delivery Notes',
          ),

        if (_matches(
          'Packing Slips',
        ))
          _comingSoonLink(
            'Packing Slips',
          ),
      ],
    );
  }

  // ================================================================
  // PURCHASES MODULE
  // ================================================================

  Widget _purchasesModuleColumn() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
              Icons.shopping_cart_rounded,
          iconColor:
              const Color(
            0xFF673AB7,
          ),
          title: 'Purchases',
        ),

        const SizedBox(height: 8),

        if (_matches('Expenses'))
          _settingLink(
            title: 'Expenses',
            onTap:
                _openExpenseSettings,
          ),

        if (_matches(
          'Purchase Orders',
        ))
          _comingSoonLink(
            'Purchase Orders',
          ),

        if (_matches('Bills'))
          _comingSoonLink(
            'Bills',
          ),

        if (_matches(
          'Payments Made',
        ))
          _comingSoonLink(
            'Payments Made',
          ),

        if (_matches(
          'Vendor Credits',
        ))
          _comingSoonLink(
            'Vendor Credits',
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
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color: iconColor,
            borderRadius:
                BorderRadius.circular(
              6,
            ),
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
            style:
                const TextStyle(
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
  // LINK
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

  Widget _comingSoonLink(
    String title,
  ) {
    return GlassLinkTile(
      title: title,
      onTap: () {
        _showComingSoon(
          title,
        );
      },
    );
  }
}