import 'package:flutter/material.dart';
import '../organization/organization_page.dart';
import '../organization/general_settings_page.dart';
import '../organization/manage_subscription_page.dart';
import '../users/manage_users_page.dart';
import '../users/manage_roles_page.dart';
import '../taxes/manage_taxes_page.dart';
import '../customization/transaction_number_series_page.dart';

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
  bool _showManageUsers = false;
  bool _showManageRoles = false;
  bool _showManageTaxes = false;
  bool _showTransactionNumberSeries = false;

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
    });
  }

  // ================================================================
  // BACK TO ALL SETTINGS
  // ================================================================

  void _backToAllSettings() {
    setState(() {
      _showOrganizationProfile = false;
    });
  }

  // ================================================================
  // COMING SOON
  // ================================================================

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title - Coming Soon',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ================================================================
  // SEARCH
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


    if (_showGeneralSettings) {
  return GeneralSettingsPage(
    onBack: () {
      setState(() {
        _showGeneralSettings = false;
      });
    },
  );
}

    if (_showManageSubscription) {
  return ManageSubscriptionPage(
    onBack: () {
      setState(() {
        _showManageSubscription = false;
      });
    },
  );
}

   if (_showManageUsers) {
  return ManageUsersPage(
    onBack: () {
      setState(() {
        _showManageUsers = false;
      });
    },
  );
}

    if (_showManageRoles) {
  return ManageRolesPage(
    onBack: () {
      setState(() {
        _showManageRoles = false;
      });
    },
  );
}    

    if (_showManageTaxes) {
  return ManageTaxesPage(
    onBack: () {
      setState(() {
        _showManageTaxes = false;
      });
    },
  );
}

    if (_showTransactionNumberSeries) {
  return TransactionNumberSeriesPage(
    onBack: () {
      setState(() {
        _showTransactionNumberSeries = false;
      });
    },
  );
}

    // ==============================================================
    // ALL SETTINGS PAGE
    // ==============================================================

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F7FA),

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // TOP HEADER
            // ========================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                22,
                24,
                20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE1E5E8),
                  ),
                ),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Settings',
                          style: TextStyle(
                            color: Color(0xFF252A2E),
                            fontSize: 29,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'test',
                          style: TextStyle(
                            color: Color(0xFF747E85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // SEARCH SETTINGS
                  // ==================================================

                  SizedBox(
                    width: 260,
                    height: 42,
                    child: TextField(
                      controller: _searchController,

                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },

                      decoration: InputDecoration(
                        hintText: 'Search settings (/)',

                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA5AD),
                          fontSize: 14,
                        ),

                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF8C9AA4),
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 10,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4DBE0),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Color(0xFF3978FF),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ==================================================
                  // CLOSE SETTINGS
                  // ==================================================

                  TextButton.icon(
                    onPressed: widget.onClose ??
                        () {
                          Navigator.maybePop(context);
                        },

                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF4C4FEA),
                    ),

                    label: const Text(
                      'Close Settings',
                    ),

                    style: TextButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF4C4FEA),

                      backgroundColor:
                          const Color(0xFFECEBFF),

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // SETTINGS CONTENT
            // ========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                35,
              ),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  35,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(11),

                  border: Border.all(
                    color: const Color(0xFFDDE3E7),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // ORGANIZATION SETTINGS TITLE
                    // =================================================

                    const Text(
                      'Organization Settings',
                      style: TextStyle(
                        color: Color(0xFF262B2F),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(
                      height: 1,
                      color: Color(0xFFE4E8EA),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // SETTINGS COLUMNS
                    // =================================================

                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        if (constraints.maxWidth >=
                            900) {
                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child:
                                    _organizationColumn(),
                              ),

                              const SizedBox(width: 35),

                              Expanded(
                                child:
                                    _usersAndTaxColumn(),
                              ),

                              const SizedBox(width: 35),

                              Expanded(
                                child:
                                    _setupColumn(),
                              ),

                              const SizedBox(width: 35),

                              Expanded(
                                child:
                                    _customizationColumn(),
                              ),
                            ],
                          );
                        }

                        if (constraints.maxWidth >=
                            600) {
                          return Wrap(
                            spacing: 30,
                            runSpacing: 35,
                            children: [
                              SizedBox(
                                width:
                                    (constraints.maxWidth -
                                            30) /
                                        2,
                                child:
                                    _organizationColumn(),
                              ),

                              SizedBox(
                                width:
                                    (constraints.maxWidth -
                                            30) /
                                        2,
                                child:
                                    _usersAndTaxColumn(),
                              ),

                              SizedBox(
                                width:
                                    (constraints.maxWidth -
                                            30) /
                                        2,
                                child:
                                    _setupColumn(),
                              ),

                              SizedBox(
                                width:
                                    (constraints.maxWidth -
                                            30) /
                                        2,
                                child:
                                    _customizationColumn(),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _organizationColumn(),

                            const SizedBox(height: 35),

                            _usersAndTaxColumn(),

                            const SizedBox(height: 35),

                            _setupColumn(),

                            const SizedBox(height: 35),

                            _customizationColumn(),
                          ],
                        );
                      },
                    ),
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
  // ORGANIZATION
  // ==================================================================

  Widget _organizationColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.business_rounded,
          iconColor: const Color(0xFF34A853),
          title: 'Organization',
        ),

        const SizedBox(height: 10),

        // PROFILE
        // THIS OPENS YOUR COMPLETE ORGANIZATION PROFILE PAGE
        if (_matches('Profile'))
          _settingLink(
            title: 'Profile',
            onTap: _openOrganizationProfile,
          ),

        if (_matches('General'))
  _settingLink(
    title: 'General',
    onTap: () {
      setState(() {
        _showGeneralSettings = true;
      });
    },
  ),

        if (_matches('Branding'))
          _settingLink(
            title: 'Branding',
            onTap: () {
              _showComingSoon('Branding');
            },
          ),

        if (_matches('Custom Domain'))
          _settingLink(
            title: 'Custom Domain',
            onTap: () {
              _showComingSoon('Custom Domain');
            },
          ),

        if (_matches('Locations'))
          _settingLink(
            title: 'Locations',
            onTap: () {
              _showComingSoon('Locations');
            },
          ),

        if (_matches('Manage Subscription'))
  _settingLink(
    title: 'Manage Subscription',
    onTap: () {
      setState(() {
        _showManageSubscription = true;
      });
    },
  ),
      ],
    );
  }

  // ==================================================================
  // USERS & ROLES + TAXES
  // ==================================================================

  Widget _usersAndTaxColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFFE83E7E),
          title: 'Users & Roles',
        ),

        const SizedBox(height: 10),

        if (_matches('Users'))
  _settingLink(
    title: 'Users',
    onTap: () {
      setState(() {
        _showManageUsers = true;
      });
    },
  ),

      if (_matches('Roles'))
  _settingLink(
    title: 'Roles',
    onTap: () {
      setState(() {
        _showManageRoles = true;
      });
    },
  ),

        if (_matches('User Preferences'))
          _settingLink(
            title: 'User Preferences',
            onTap: () {
              _showComingSoon(
                'User Preferences',
              );
            },
          ),

        const SizedBox(height: 25),

        _sectionTitle(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFFE83E7E),
          title: 'Taxes & Compliance',
        ),

        const SizedBox(height: 10),

        if (_matches('Taxes'))
  _settingLink(
    title: 'Taxes',
    onTap: () {
      setState(() {
        _showManageTaxes = true;
      });
    },
  ),

        if (_matches('Direct Taxes'))
          _settingLink(
            title: 'Direct Taxes',
            onTap: () {
              _showComingSoon('Direct Taxes');
            },
          ),

        if (_matches('e-Way Bills'))
          _settingLink(
            title: 'e-Way Bills',
            onTap: () {
              _showComingSoon('e-Way Bills');
            },
          ),

        if (_matches('e-Invoicing'))
          _settingLink(
            title: 'e-Invoicing',
            onTap: () {
              _showComingSoon('e-Invoicing');
            },
          ),
      ],
    );
  }

  // ==================================================================
  // SETUP & CONFIGURATIONS
  // ==================================================================

  Widget _setupColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFFF59A0A),
          title: 'Setup & Configurations',
        ),

        const SizedBox(height: 10),

        if (_matches('Currencies'))
          _settingLink(
            title: 'Currencies',
            onTap: () {
              _showComingSoon('Currencies');
            },
          ),

        if (_matches('Opening Balances'))
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
              _showComingSoon('Reminders');
            },
          ),

        if (_matches('Customer Portal'))
          _settingLink(
            title: 'Customer Portal',
            onTap: () {
              _showComingSoon(
                'Customer Portal',
              );
            },
          ),

        if (_matches('Vendor Portal'))
          _settingLink(
            title: 'Vendor Portal',
            onTap: () {
              _showComingSoon('Vendor Portal');
            },
          ),
      ],
    );
  }

  // ==================================================================
  // CUSTOMIZATION
  // ==================================================================

  Widget _customizationColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.palette_outlined,
          iconColor: const Color(0xFF3478F6),
          title: 'Customization',
        ),

        const SizedBox(height: 10),

        if (_matches('Transaction Number Series'))
  _settingLink(
    title: 'Transaction Number Series',
    onTap: () {
      setState(() {
        _showTransactionNumberSeries = true;
      });
    },
  ),

        if (_matches('PDF Templates'))
          _settingLink(
            title: 'PDF Templates',
            onTap: () {
              _showComingSoon('PDF Templates');
            },
          ),

        if (_matches('Email Notifications'))
          _settingLink(
            title: 'Email Notifications',
            onTap: () {
              _showComingSoon(
                'Email Notifications',
              );
            },
          ),

        if (_matches('SMS Notifications'))
          _settingLink(
            title: 'SMS Notifications',
            onTap: () {
              _showComingSoon(
                'SMS Notifications',
              );
            },
          ),

        if (_matches('Reporting Tags'))
          _settingLink(
            title: 'Reporting Tags',
            onTap: () {
              _showComingSoon('Reporting Tags');
            },
          ),

        if (_matches('Web Tabs'))
          _settingLink(
            title: 'Web Tabs',
            onTap: () {
              _showComingSoon('Web Tabs');
            },
          ),

        if (_matches('Digital Signature'))
          _settingLink(
            title: 'Digital Signature',
            onTap: () {
              _showComingSoon(
                'Digital Signature',
              );
            },
          ),
      ],
    );
  }

  // ==================================================================
  // SECTION TITLE
  // ==================================================================

  Widget _sectionTitle({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(6),
          ),

          child: Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF292E32),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==================================================================
  // SETTING LINK
  // ==================================================================

  Widget _settingLink({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(4),

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),

          child: Align(
            alignment: Alignment.centerLeft,

            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2767F4),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}