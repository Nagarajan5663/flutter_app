import 'dart:ui';

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
  String? _hoveredKey;

  static const Duration _motionDuration = Duration(milliseconds: 260);
  static const Curve _motionCurve = Curves.easeInOutCubic;

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

  bool _isHovered(String key) => _hoveredKey == key;

  void _setHovered(String? key) {
    if (_hoveredKey == key) return;

    setState(() {
      _hoveredKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: _motionCurve,
      width: isCollapsed ? 80 : 270,
      height: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071B2B).withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 24,
            sigmaY: 24,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF123A5C).withValues(alpha: 0.96),
                        const Color(0xFF102F4A).withValues(alpha: 0.94),
                        const Color(0xFF0E2A43).withValues(alpha: 0.96),
                      ],
                    ),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -90,
                left: -70,
                child: IgnorePointer(
                  child: _NavGlowOrb(
                    size: 220,
                    color: const Color(0xFF3D8DFF),
                    opacity: 0.22,
                  ),
                ),
              ),

              Positioned(
                top: 290,
                right: -110,
                child: IgnorePointer(
                  child: _NavGlowOrb(
                    size: 250,
                    color: const Color(0xFF7457F5),
                    opacity: 0.16,
                  ),
                ),
              ),

              Positioned(
                bottom: -110,
                left: -60,
                child: IgnorePointer(
                  child: _NavGlowOrb(
                    size: 240,
                    color: const Color(0xFF2CC7A5),
                    opacity: 0.13,
                  ),
                ),
              ),

              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                            children: [
                              _menuItem(
                                icon: Icons.dashboard_outlined,
                                title: 'Dashboard',
                                selected: _isSelected('dashboard'),
                                onTap: () {
                                  onMenuSelected('dashboard');
                                },
                              ),

                              const SizedBox(height: 7),

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

                              _menuItem(
                                icon: Icons.description_outlined,
                                title: 'Reports',
                                selected: _isSelected('reports'),
                                onTap: () {
                                  onMenuSelected('reports');
                                },
                              ),

                              const SizedBox(height: 20),

                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.28),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              _menuItem(
                                icon: Icons.hub_outlined,
                                title: 'Fluxa Hub',
                                selected: _isSelected('fluxa hub'),
                                onTap: () {
                                  onMenuSelected('fluxa hub');
                                },
                              ),

                              const SizedBox(height: 7),

                              _menuItem(
                                icon: Icons.settings_outlined,
                                title: 'Settings',
                                selected: _isSelected('settings'),
                                onTap: () {
                                  onMenuSelected('settings');
                                },
                              ),

                              const SizedBox(height: 7),

                              _menuItem(
                                icon: Icons.account_circle_outlined,
                                title: 'My Account',
                                selected: _isSelected('my account'),
                                onTap: () {
                                  onMenuSelected('my account');
                                },
                              ),

                              const SizedBox(height: 7),

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
                ],
              ),
          ),
        ),
    );
  }

  bool _isSelected(String menu) {
    final current = selectedMenu.toLowerCase().trim();
    final value = menu.toLowerCase().trim();

    if (current == value) {
      return true;
    }

    if (value == 'items') {
      return current == 'items' || current == 'parts';
    }

    if (value == 'inventory') {
      return current == 'inventory' ||
          current == 'current stock' ||
          current == 'inventory adjustments' ||
          current == 'returnable assets' ||
          current == 'current-stock' ||
          current == 'inventory-adjustments' ||
          current == 'returnable-assets';
    }

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

    final hoverKey = 'section-$sectionKey';
    final hovered = _isHovered(hoverKey);
    final selected = _isSelected(sectionKey);
    final expanded = _openSection == title;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(hoverKey),
      onExit: (_) => _setHovered(null),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        scale: hovered ? 1.008 : 1,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2D6CB1).withValues(alpha: 0.50)
                : Colors.white.withValues(
                    alpha: hovered || expanded ? 0.095 : 0.035,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF79BCFF).withValues(alpha: 0.34)
                  : Colors.white.withValues(
                      alpha: hovered ? 0.22 : 0.075,
                    ),
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF3D8DFF)
                          .withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.white.withValues(alpha: 0.06),
                highlightColor: Colors.white.withValues(alpha: 0.04),
              ),
              child: ExpansionTile(
                key: ValueKey(
                  '$title-${_openSection == title}',
                ),
                initiallyExpanded: expanded,
                onExpansionChanged: (isExpanded) {
                  setState(() {
                    _openSection = isExpanded ? title : null;
                  });
                },
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                childrenPadding: const EdgeInsets.only(
                  left: 6,
                  right: 6,
                  bottom: 7,
                ),
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF5AA9F3).withValues(alpha: 0.20)
                        : Colors.white.withValues(
                            alpha: hovered ? 0.11 : 0.06,
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white70,
                title: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                children: [
                  for (final child in children) _subMenuItem(child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _subMenuItem(String title) {
    final selected = _isSelected(title);
    final hoverKey = 'sub-${title.toLowerCase()}';
    final hovered = _isHovered(hoverKey);

    return Padding(
      padding: const EdgeInsets.only(
        top: 3,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setHovered(hoverKey),
        onExit: (_) => _setHovered(null),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          scale: hovered ? 1.012 : 1,
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onMenuSelected(title);
              },
              borderRadius: BorderRadius.circular(9),
              splashColor: Colors.white.withValues(alpha: 0.06),
              child: AnimatedContainer(
                duration: _motionDuration,
                curve: _motionCurve,
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 40,
                ),
                padding: const EdgeInsets.only(
                  left: 42,
                  right: 12,
                  top: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF4B8BD0).withValues(alpha: 0.38)
                      : Colors.white.withValues(
                          alpha: hovered ? 0.085 : 0.025,
                        ),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF82C1FF).withValues(alpha: 0.25)
                        : Colors.white.withValues(
                            alpha: hovered ? 0.16 : 0.04,
                          ),
                  ),
                  boxShadow: hovered
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4EA2F4)
                                .withValues(alpha: 0.11),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedSlide(
                      duration: _motionDuration,
                      curve: _motionCurve,
                      offset: selected || hovered
                          ? Offset.zero
                          : const Offset(-0.15, 0),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: selected || hovered
                            ? Colors.white
                            : Colors.white60,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected || hovered
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.82),
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
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final hoverKey = 'menu-${title.toLowerCase()}';
    final hovered = _isHovered(hoverKey);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(hoverKey),
      onExit: (_) => _setHovered(null),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        scale: hovered ? 1.018 : 1,
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.07),
            highlightColor: Colors.white.withValues(alpha: 0.04),
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(11),
            child: AnimatedContainer(
              duration: _motionDuration,
              curve: _motionCurve,
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 12,
              ),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF276AB1).withValues(alpha: 0.90),
                          const Color(0xFF3E83CB).withValues(alpha: 0.72),
                        ],
                      )
                    : null,
                color: selected
                    ? null
                    : Colors.white.withValues(
                        alpha: hovered ? 0.105 : 0.032,
                      ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF8CC8FF).withValues(alpha: 0.38)
                      : Colors.white.withValues(
                          alpha: hovered ? 0.23 : 0.065,
                        ),
                ),
                boxShadow: hovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3D8DFF)
                              .withValues(alpha: selected ? 0.24 : 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1E76C8)
                                  .withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: selected
                            ? 0.16
                            : hovered
                                ? 0.11
                                : 0.045,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: hovered
                          ? [
                              BoxShadow(
                                color: const Color(0xFF68B7FF)
                                    .withValues(alpha: 0.13),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 160),
                      scale: hovered ? 1.08 : 1,
                      child: Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  if (!isCollapsed) const SizedBox(width: 12),

                  if (!isCollapsed)
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavGlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _NavGlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.32),
            Colors.transparent,
          ],
          stops: const [
            0,
            0.48,
            1,
          ],
        ),
      ),
    );
  }
}

class _SidebarScrollBehavior extends ScrollBehavior {
  const _SidebarScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
