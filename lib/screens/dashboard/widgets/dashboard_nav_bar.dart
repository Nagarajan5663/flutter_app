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
  // ================================================================
  // STATE
  // ================================================================

  String? _openSection;
  String? _hoveredItem;

  OverlayEntry? _flyoutEntry;
  String? _flyoutSection;

  final Map<String, LayerLink> _sectionLinks = {
    'Items': LayerLink(),
    'Inventory': LayerLink(),
    'Sales': LayerLink(),
    'Purchase': LayerLink(),
    'Accountant': LayerLink(),
  };

  bool get isCollapsed => widget.isCollapsed;

  String get selectedMenu => widget.selectedMenu;

  ValueChanged<String> get onMenuSelected =>
      widget.onMenuSelected;

  // ================================================================
  // COLORS
  // ================================================================

  static const Color _navy = Color(0xFF0E2942);
  static const Color _navyDark = Color(0xFF081D31);

  static const Color _blue = Color(0xFF3B82F6);
  static const Color _blueLight = Color(0xFF60A5FA);
  static const Color _cyan = Color(0xFF38BDF8);
  static const Color _mint = Color(0xFF2DD4BF);

  static const Color _textPrimary =
      Color(0xFFF8FAFC);

  static const Color _textSecondary =
      Color(0xFFB8C7D9);

  static const Color _textMuted =
      Color(0xFF7F95AB);

  // ================================================================
  // LIFE CYCLE
  // ================================================================

  @override
  void didUpdateWidget(
    covariant DashboardNavBar oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    // --------------------------------------------------------------
    // EXPANDED → COLLAPSED
    // --------------------------------------------------------------

    if (!oldWidget.isCollapsed &&
        widget.isCollapsed) {
      _openSection = null;
    }

    // --------------------------------------------------------------
    // COLLAPSED → EXPANDED
    // --------------------------------------------------------------

    if (oldWidget.isCollapsed &&
        !widget.isCollapsed) {
      _removeFlyout(rebuild: false);

      final section =
          _findParentSection(widget.selectedMenu);

      if (section != null) {
        _openSection = section;
      }
    }
  }

  @override
  void dispose() {
    _removeFlyout(rebuild: false);
    super.dispose();
  }

  // ================================================================
  // FIND PARENT SECTION
  // ================================================================

  String? _findParentSection(String menu) {
    final value = menu.toLowerCase().trim();

    const sections = {
      'Items': [
        'items',
        'parts',
      ],

      'Inventory': [
        'inventory',
        'current stock',
        'inventory adjustments',
        'returnable assets',
      ],

      'Sales': [
        'sales',
        'customers',
        'estimates',
        'sales order',
        'sales orders',
        'invoices',
        'delivery challans',
        'payment received',
        'payments received',
        'credit notes',
      ],

      'Purchase': [
        'purchase',
        'vendors',
        'purchase orders',
        'bills',
        'payment made',
        'payments made',
        'vendor credit notes',
      ],

      'Accountant': [
        'accountant',
        'expense',
        'expenses',
        'reimbursements',
        'travel allowance',
        'other claims',
        'investment',
        'investments',
        'loans',
      ],
    };

    for (final entry in sections.entries) {
      if (entry.value.contains(value)) {
        return entry.key;
      }
    }

    return null;
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: isCollapsed ? 88 : 282,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isCollapsed ? 8 : 12,
        12,
        isCollapsed ? 8 : 12,
        12,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            isCollapsed ? 24 : 28,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _navy.withValues(alpha: 0.96),
              _navyDark.withValues(alpha: 0.97),
              const Color(0xFF102F47)
                  .withValues(alpha: 0.96),
            ],
          ),
          border: Border.all(
            color: Colors.white
                .withValues(alpha: 0.13),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B2340)
                  .withValues(alpha: 0.24),
              blurRadius: 28,
              offset: const Offset(8, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ======================================================
            // TOP BLUE GLOW
            // ======================================================

            Positioned(
              top: -90,
              left: -80,
              child: IgnorePointer(
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _blue.withValues(
                          alpha: 0.18,
                        ),
                        _blue.withValues(
                          alpha: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // BOTTOM GREEN GLOW
            // ======================================================

            Positioned(
              right: -110,
              bottom: 40,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _mint.withValues(
                          alpha: 0.11,
                        ),
                        _mint.withValues(
                          alpha: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // SIDEBAR CONTENT
            // ======================================================

            Positioned.fill(
              child: Column(
                children: [
                  if (!isCollapsed) ...[
                    const SizedBox(height: 16),

                    _buildSectionLabel(
                      'WORKSPACE',
                    ),
                  ] else
                    const SizedBox(height: 16),

                  Expanded(
                    child: ScrollConfiguration(
                      behavior:
                          const _SidebarScrollBehavior(),
                      child: SingleChildScrollView(
                        physics:
                            const ClampingScrollPhysics(),
                        padding:
                            EdgeInsets.fromLTRB(
                          isCollapsed ? 7 : 10,
                          0,
                          isCollapsed ? 7 : 10,
                          12,
                        ),
                        child: Column(
                          children: [
                            // ======================================
                            // DASHBOARD
                            // ======================================

                            _menuItem(
                              icon:
                                  Icons.grid_view_rounded,
                              title: 'Dashboard',
                              selected:
                                  _isSelected(
                                'dashboard',
                              ),
                              onTap: () {
                                _selectDirect(
                                  'dashboard',
                                );
                              },
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // ITEMS
                            // ======================================

                            _sectionMenu(
                              icon:
                                  Icons.inventory_2_outlined,
                              title: 'Items',
                              children: const [
                                'Items',
                                'Parts',
                              ],
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // INVENTORY
                            // ======================================

                            _sectionMenu(
                              icon:
                                  Icons.warehouse_outlined,
                              title: 'Inventory',
                              children: const [
                                'Current Stock',
                                'Inventory Adjustments',
                                'Returnable Assets',
                              ],
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // SALES
                            // ======================================

                            _sectionMenu(
                              icon:
                                  Icons.trending_up_rounded,
                              title: 'Sales',
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

                            const SizedBox(height: 6),

                            // ======================================
                            // PURCHASE
                            // ======================================

                            _sectionMenu(
                              icon:
                                  Icons.shopping_bag_outlined,
                              title: 'Purchase',
                              children: const [
                                'Vendors',
                                'Purchase Orders',
                                'Bills',
                                'Payment Made',
                                'Vendor Credit Notes',
                              ],
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // ACCOUNTANT
                            // ======================================

                            _sectionMenu(
                              icon: Icons
                                  .account_balance_wallet_outlined,
                              title: 'Accountant',
                              children: const [
                                'Expense',
                                'Reimbursements',
                                'Travel Allowance',
                                'Other Claims',
                                'Investments',
                                'Loans',
                              ],
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // REPORTS
                            // ======================================

                            _menuItem(
                              icon:
                                  Icons.analytics_outlined,
                              title: 'Reports',
                              selected:
                                  _isSelected(
                                'reports',
                              ),
                              onTap: () {
                                _selectDirect(
                                  'reports',
                                );
                              },
                            ),

                            const SizedBox(height: 18),

                            _buildDivider(),

                            if (!isCollapsed) ...[
                              const SizedBox(
                                height: 16,
                              ),

                              _buildSectionLabel(
                                'SYSTEM',
                              ),
                            ] else
                              const SizedBox(
                                height: 16,
                              ),

                            // ======================================
                            // FLUXA HUB
                            // ======================================

                            _menuItem(
                              icon:
                                  Icons.hub_outlined,
                              title: 'Fluxa Hub',
                              selected:
                                  _isSelected(
                                'fluxa hub',
                              ),
                              accent: _mint,
                              onTap: () {
                                _selectDirect(
                                  'fluxa hub',
                                );
                              },
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // SETTINGS
                            // ======================================

                            _menuItem(
                              icon:
                                  Icons.settings_outlined,
                              title: 'Settings',
                              selected:
                                  _isSelected(
                                        'settings',
                                      ) ||
                                      _isSelected(
                                        'all_settings',
                                      ),
                              onTap: () {
                                _selectDirect(
                                  'settings',
                                );
                              },
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // MY ACCOUNT
                            // ======================================

                            _menuItem(
                              icon: Icons
                                  .person_outline_rounded,
                              title: 'My Account',
                              selected:
                                  _isSelected(
                                'my account',
                              ),
                              onTap: () {
                                _selectDirect(
                                  'my account',
                                );
                              },
                            ),

                            const SizedBox(height: 6),

                            // ======================================
                            // HELP
                            // ======================================

                            _menuItem(
                              icon: Icons
                                  .help_outline_rounded,
                              title: 'Help',
                              selected:
                                  _isSelected(
                                'help',
                              ),
                              onTap: () {
                                _selectDirect(
                                  'help',
                                );
                              },
                            ),

                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // DIRECT ITEM SELECT
  // ================================================================

  void _selectDirect(String menu) {
    _removeFlyout();

    setState(() {
      _openSection = null;
    });

    onMenuSelected(menu);
  }

  // ================================================================
  // SECTION LABEL
  // ================================================================

  Widget _buildSectionLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        0,
        16,
        8,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _textMuted,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.7,
        ),
      ),
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 10 : 12,
      ),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(
              alpha: 0.14,
            ),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SELECTED
  // ================================================================

  bool _isSelected(String menu) {
    return selectedMenu
            .toLowerCase()
            .trim() ==
        menu.toLowerCase().trim();
  }

  bool _isSectionSelected(
    String title,
    List<String> children,
  ) {
    if (_isSelected(title)) {
      return true;
    }

    for (final child in children) {
      if (_isSelected(child)) {
        return true;
      }
    }

    // Aliases used by DashboardPage.
    final selected =
        selectedMenu.toLowerCase().trim();

    if (title == 'Sales' &&
        selected == 'sales orders') {
      return true;
    }

    if (title == 'Sales' &&
        selected == 'payments received') {
      return true;
    }

    if (title == 'Purchase' &&
        selected == 'payments made') {
      return true;
    }

    if (title == 'Accountant' &&
        selected == 'expenses') {
      return true;
    }

    if (title == 'Accountant' &&
        selected == 'investment') {
      return true;
    }

    return false;
  }

  // ================================================================
  // TOGGLE INLINE SECTION
  // ================================================================

  void _toggleSection(String title) {
    _removeFlyout();

    setState(() {
      if (_openSection == title) {
        _openSection = null;
      } else {
        _openSection = title;
      }
    });
  }

  // ================================================================
  // SECTION
  // ================================================================

  Widget _sectionMenu({
    required IconData icon,
    required String title,
    required List<String> children,
  }) {
    final selected =
        _isSectionSelected(
      title,
      children,
    );

    final open =
        _openSection == title;

    final flyoutOpen =
        _flyoutSection == title;

    final link =
        _sectionLinks[title]!;

    // ==============================================================
    // COLLAPSED MODE
    // ==============================================================

    if (isCollapsed) {
      return CompositedTransformTarget(
        link: link,
        child: _menuItem(
          icon: icon,
          title: title,
          selected:
              selected || flyoutOpen,
          onTap: () {
            _showFlyout(
              title: title,
              icon: icon,
              children: children,
              link: link,
            );
          },
        ),
      );
    }

    // ==============================================================
    // EXPANDED MODE
    // ==============================================================

    final hoverKey =
        'section-$title';

    final hovered =
        _hoveredItem == hoverKey;

    return Column(
      children: [
        MouseRegion(
          cursor:
              SystemMouseCursors.click,
          onEnter: (_) {
            setState(() {
              _hoveredItem =
                  hoverKey;
            });
          },
          onExit: (_) {
            setState(() {
              if (_hoveredItem ==
                  hoverKey) {
                _hoveredItem = null;
              }
            });
          },
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque,
            onTap: () {
              _toggleSection(title);
            },
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 170,
              ),
              curve:
                  Curves.easeOutCubic,
              height: 50,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                gradient: selected
                    ? LinearGradient(
                        begin:
                            Alignment.centerLeft,
                        end:
                            Alignment.centerRight,
                        colors: [
                          _blue.withValues(
                            alpha: 0.25,
                          ),
                          _cyan.withValues(
                            alpha: 0.09,
                          ),
                        ],
                      )
                    : hovered
                        ? LinearGradient(
                            colors: [
                              Colors.white
                                  .withValues(
                                alpha: 0.09,
                              ),
                              Colors.white
                                  .withValues(
                                alpha: 0.035,
                              ),
                            ],
                          )
                        : null,
                border: Border.all(
                  color: selected
                      ? _blueLight
                          .withValues(
                          alpha: 0.30,
                        )
                      : hovered
                          ? Colors.white
                              .withValues(
                              alpha:
                                  0.10,
                            )
                          : Colors
                              .transparent,
                ),
              ),
              child: Row(
                children: [
                  _menuIcon(
                    icon: icon,
                    selected:
                        selected,
                    hovered:
                        hovered,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      title,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            selected ||
                                    hovered
                                ? _textPrimary
                                : _textSecondary,
                        fontSize: 14,
                        fontWeight:
                            selected
                                ? FontWeight
                                    .w700
                                : FontWeight
                                    .w500,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    turns:
                        open ? 0.25 : 0,
                    duration:
                        const Duration(
                      milliseconds: 220,
                    ),
                    curve:
                        Curves.easeOutCubic,
                    child: Icon(
                      Icons
                          .chevron_right_rounded,
                      color: selected
                          ? _blueLight
                          : _textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ============================================================
        // INLINE CHILDREN
        // ============================================================

        AnimatedSize(
          duration:
              const Duration(
            milliseconds: 240,
          ),
          curve:
              Curves.easeOutCubic,
          alignment:
              Alignment.topCenter,
          child: open
              ? Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 6,
                    bottom: 4,
                  ),
                  child:
                      _buildSubMenuList(
                    children,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ================================================================
  // INLINE SUB MENU LIST
  // ================================================================

  Widget _buildSubMenuList(
    List<String> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        left: 22,
      ),
      padding: const EdgeInsets.only(
        left: 15,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white
                .withValues(
              alpha: 0.09,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          for (final child
              in children)
            _subMenuItem(child),
        ],
      ),
    );
  }

  // ================================================================
  // INLINE SUB MENU ITEM
  // ================================================================

  Widget _subMenuItem(
    String title,
  ) {
    final selected =
        _isSelected(title);

    final hoverKey =
        'sub-$title';

    final hovered =
        _hoveredItem == hoverKey;

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredItem = hoverKey;
        });
      },
      onExit: (_) {
        setState(() {
          if (_hoveredItem ==
              hoverKey) {
            _hoveredItem = null;
          }
        });
      },
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,
        onTap: () {
          onMenuSelected(title);
        },
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 150,
          ),
          curve:
              Curves.easeOutCubic,
          margin:
              const EdgeInsets.only(
            bottom: 3,
          ),
          height: 38,
          padding:
              const EdgeInsets.only(
            left: 12,
            right: 10,
          ),
          transform:
              Matrix4.translationValues(
            hovered ? 3 : 0,
            0,
            0,
          ),
          decoration:
              BoxDecoration(
            color: selected
                ? _blue.withValues(
                    alpha: 0.13,
                  )
                : hovered
                    ? Colors.white
                        .withValues(
                        alpha:
                            0.055,
                      )
                    : Colors
                        .transparent,
            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 150,
                ),
                width:
                    selected ? 7 : 5,
                height:
                    selected ? 7 : 5,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color: selected
                      ? _blueLight
                      : hovered
                          ? Colors
                              .white70
                          : _textMuted,
                  boxShadow:
                      selected
                          ? [
                              BoxShadow(
                                color:
                                    _blueLight
                                        .withValues(
                                  alpha:
                                      0.45,
                                ),
                                blurRadius:
                                    8,
                              ),
                            ]
                          : null,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    color: selected
                        ? _textPrimary
                        : hovered
                            ? Colors
                                .white
                            : _textSecondary,
                    fontSize: 12.5,
                    fontWeight:
                        selected
                            ? FontWeight
                                .w600
                            : FontWeight
                                .w400,
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
  // COLLAPSED FLYOUT
  // ================================================================

  void _showFlyout({
    required String title,
    required IconData icon,
    required List<String> children,
    required LayerLink link,
  }) {
    // Clicking same parent again closes the popup.
    if (_flyoutSection == title &&
        _flyoutEntry != null) {
      _removeFlyout();
      return;
    }

    _removeFlyout(
      rebuild: false,
    );

    _flyoutSection = title;

    _flyoutEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // ======================================================
            // CLICK OUTSIDE
            // ======================================================

            Positioned.fill(
              child: GestureDetector(
                behavior:
                    HitTestBehavior.translucent,
                onTap: () {
                  _removeFlyout();
                },
                child:
                    const SizedBox.expand(),
              ),
            ),

            // ======================================================
            // RIGHT SIDE FLYOUT
            // ======================================================

            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              targetAnchor:
                  Alignment.topRight,
              followerAnchor:
                  Alignment.topLeft,
              offset:
                  const Offset(12, -4),
              child: Material(
                color:
                    Colors.transparent,
                child: _SidebarFlyout(
                  title: title,
                  icon: icon,
                  items: children,
                  selectedMenu:
                      selectedMenu,
                  onItemSelected:
                      (value) {
                    _removeFlyout();

                    onMenuSelected(
                      value,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(
      _flyoutEntry!,
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ================================================================
  // REMOVE FLYOUT
  // ================================================================

  void _removeFlyout({
    bool rebuild = true,
  }) {
    _flyoutEntry?.remove();

    _flyoutEntry = null;
    _flyoutSection = null;

    if (rebuild && mounted) {
      setState(() {});
    }
  }

  // ================================================================
  // NORMAL MENU ITEM
  // ================================================================

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color accent = _blue,
  }) {
    final hoverKey =
        'item-$title';

    final hovered =
        _hoveredItem == hoverKey;

    final menu =
        AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 170,
      ),
      curve:
          Curves.easeOutCubic,
      width: double.infinity,
      height: 50,
      transform:
          Matrix4.translationValues(
        hovered && !isCollapsed
            ? 4
            : 0,
        0,
        0,
      ),
      padding:
          EdgeInsets.symmetric(
        horizontal:
            isCollapsed ? 5 : 10,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          15,
        ),

        // ------------------------------------------------------------
        // SELECTED GRADIENT
        // ------------------------------------------------------------

        gradient: selected
            ? LinearGradient(
                begin:
                    Alignment.centerLeft,
                end:
                    Alignment.centerRight,
                colors: [
                  accent.withValues(
                    alpha: 0.90,
                  ),
                  _blue.withValues(
                    alpha: 0.64,
                  ),
                  _cyan.withValues(
                    alpha: 0.38,
                  ),
                ],
              )
            : hovered
                ? LinearGradient(
                    colors: [
                      Colors.white
                          .withValues(
                        alpha: 0.11,
                      ),
                      Colors.white
                          .withValues(
                        alpha: 0.045,
                      ),
                    ],
                  )
                : null,

        border: Border.all(
          color: selected
              ? Colors.white
                  .withValues(
                  alpha: 0.18,
                )
              : hovered
                  ? Colors.white
                      .withValues(
                      alpha:
                          0.10,
                    )
                  : Colors
                      .transparent,
        ),

        boxShadow: selected
            ? [
                BoxShadow(
                  color:
                      accent.withValues(
                    alpha: 0.24,
                  ),
                  blurRadius: 18,
                  offset:
                      const Offset(
                    0,
                    7,
                  ),
                ),
              ]
            : hovered
                ? [
                    BoxShadow(
                      color:
                          Colors.black
                              .withValues(
                        alpha:
                            0.10,
                      ),
                      blurRadius:
                          12,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ]
                : const [],
      ),
      child: Stack(
        children: [
          // ==========================================================
          // ACTIVE STRIP
          // ==========================================================

          if (selected)
            Positioned(
              left: -5,
              top: 12,
              bottom: 12,
              child: Container(
                width: 3,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.white
                              .withValues(
                        alpha:
                            0.60,
                      ),
                      blurRadius:
                          7,
                    ),
                  ],
                ),
              ),
            ),

          Center(
            child: Row(
              mainAxisAlignment:
                  isCollapsed
                      ? MainAxisAlignment
                          .center
                      : MainAxisAlignment
                          .start,
              children: [
                _menuIcon(
                  icon: icon,
                  selected:
                      selected,
                  hovered:
                      hovered,
                ),

                if (!isCollapsed) ...[
                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        AnimatedDefaultTextStyle(
                      duration:
                          const Duration(
                        milliseconds:
                            150,
                      ),
                      style:
                          TextStyle(
                        color:
                            selected ||
                                    hovered
                                ? Colors
                                    .white
                                : _textSecondary,
                        fontSize:
                            14,
                        fontWeight:
                            selected
                                ? FontWeight
                                    .w700
                                : FontWeight
                                    .w500,
                      ),
                      child: Text(
                        title,
                        maxLines:
                            1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),
                  ),

                  if (selected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape
                                .circle,
                        color:
                            Colors
                                .white,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors
                                    .white
                                    .withValues(
                              alpha:
                                  0.65,
                            ),
                            blurRadius:
                                8,
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Tooltip(
      message:
          isCollapsed ? title : '',
      waitDuration:
          const Duration(
        milliseconds: 350,
      ),
      child: MouseRegion(
        cursor:
            SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _hoveredItem =
                hoverKey;
          });
        },
        onExit: (_) {
          setState(() {
            if (_hoveredItem ==
                hoverKey) {
              _hoveredItem = null;
            }
          });
        },
        child: GestureDetector(
          behavior:
              HitTestBehavior.opaque,
          onTap: onTap,
          child: menu,
        ),
      ),
    );
  }

  // ================================================================
  // MENU ICON
  // ================================================================

  Widget _menuIcon({
    required IconData icon,
    required bool selected,
    required bool hovered,
  }) {
    return AnimatedScale(
      duration:
          const Duration(
        milliseconds: 160,
      ),
      curve:
          Curves.easeOutBack,
      scale:
          hovered ? 1.08 : 1,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 160,
        ),
        width:
            isCollapsed ? 38 : 36,
        height:
            isCollapsed ? 38 : 36,
        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          color: selected
              ? Colors.white
                  .withValues(
                  alpha: 0.16,
                )
              : hovered
                  ? Colors.white
                      .withValues(
                      alpha:
                          0.09,
                    )
                  : Colors.white
                      .withValues(
                      alpha:
                          0.045,
                    ),
          border: Border.all(
            color: selected
                ? Colors.white
                    .withValues(
                    alpha:
                        0.20,
                  )
                : Colors.white
                    .withValues(
                    alpha:
                        0.06,
                  ),
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color:
              selected || hovered
                  ? Colors.white
                  : _textSecondary,
        ),
      ),
    );
  }
}

// ==================================================================
// COLLAPSED SIDEBAR FLYOUT MENU
// ==================================================================

class _SidebarFlyout
    extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final String selectedMenu;
  final ValueChanged<String>
      onItemSelected;

  const _SidebarFlyout({
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedMenu,
    required this.onItemSelected,
  });

  @override
  State<_SidebarFlyout>
      createState() =>
          _SidebarFlyoutState();
}

class _SidebarFlyoutState
    extends State<_SidebarFlyout> {
  String? _hoveredItem;

  static const Color _blue =
      Color(0xFF3B82F6);

  static const Color _blueLight =
      Color(0xFF60A5FA);

  static const Color _navy =
      Color(0xFF0C2942);

  static const Color _navyDark =
      Color(0xFF061A2C);

  static const Color _text =
      Color(0xFFF8FAFC);

  static const Color _secondary =
      Color(0xFFB8C7D9);

  bool _selected(String value) {
    return widget.selectedMenu
            .toLowerCase()
            .trim() ==
        value.toLowerCase().trim();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration:
          const Duration(
        milliseconds: 180,
      ),
      curve:
          Curves.easeOutCubic,
      builder: (
        context,
        animation,
        child,
      ) {
        return Opacity(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(
              (1 - animation) * -8,
              0,
            ),
            child:
                Transform.scale(
              alignment:
                  Alignment.centerLeft,
              scale:
                  0.96 +
                      animation *
                          0.04,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 258,
        constraints:
            const BoxConstraints(
          maxHeight: 440,
        ),
        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          gradient:
              const LinearGradient(
            begin:
                Alignment.topLeft,
            end:
                Alignment.bottomRight,
            colors: [
              _navy,
              _navyDark,
              Color(0xFF102F47),
            ],
          ),
          border: Border.all(
            color: Colors.white
                .withValues(
              alpha: 0.14,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.28,
              ),
              blurRadius: 28,
              offset:
                  const Offset(
                8,
                12,
              ),
            ),
            BoxShadow(
              color: _blue
                  .withValues(
                alpha: 0.10,
              ),
              blurRadius: 28,
            ),
          ],
        ),
        clipBehavior:
            Clip.antiAlias,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Container(
              height: 62,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
              ),
              decoration:
                  BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(
                    color: Colors.white
                        .withValues(
                      alpha:
                          0.09,
                    ),
                  ),
                ),
                gradient:
                    LinearGradient(
                  colors: [
                    _blue.withValues(
                      alpha: 0.15,
                    ),
                    Colors
                        .transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                      color: _blue
                          .withValues(
                        alpha:
                            0.18,
                      ),
                      border:
                          Border.all(
                        color: _blueLight
                            .withValues(
                          alpha:
                              0.22,
                        ),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color:
                          _blueLight,
                      size: 19,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      widget.title,
                      style:
                          const TextStyle(
                        color: _text,
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // MENU
            // ======================================================

            Flexible(
              child:
                  SingleChildScrollView(
                physics:
                    const ClampingScrollPhysics(),
                padding:
                    const EdgeInsets
                        .all(
                  9,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    for (final item
                        in widget.items)
                      _item(item),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    String title,
  ) {
    final selected =
        _selected(title);

    final hovered =
        _hoveredItem == title;

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredItem = title;
        });
      },
      onExit: (_) {
        setState(() {
          if (_hoveredItem ==
              title) {
            _hoveredItem = null;
          }
        });
      },
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,
        onTap: () {
          widget.onItemSelected(
            title,
          );
        },
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 150,
          ),
          curve:
              Curves.easeOutCubic,
          height: 43,
          margin:
              const EdgeInsets.only(
            bottom: 4,
          ),
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 12,
          ),
          transform:
              Matrix4.translationValues(
            hovered ? 3 : 0,
            0,
            0,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      _blue.withValues(
                        alpha:
                            0.30,
                      ),
                      _blueLight
                          .withValues(
                        alpha:
                            0.12,
                      ),
                    ],
                  )
                : null,
            color: selected
                ? null
                : hovered
                    ? Colors.white
                        .withValues(
                        alpha:
                            0.075,
                      )
                    : Colors
                        .transparent,
            border: Border.all(
              color: selected
                  ? _blueLight
                      .withValues(
                      alpha:
                          0.24,
                    )
                  : Colors
                      .transparent,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 150,
                ),
                width:
                    selected ? 7 : 5,
                height:
                    selected ? 7 : 5,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color: selected
                      ? _blueLight
                      : hovered
                          ? Colors
                              .white
                          : _secondary,
                  boxShadow:
                      selected
                          ? [
                              BoxShadow(
                                color:
                                    _blueLight
                                        .withValues(
                                  alpha:
                                      0.50,
                                ),
                                blurRadius:
                                    8,
                              ),
                            ]
                          : null,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  title,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    color:
                        selected ||
                                hovered
                            ? _text
                            : _secondary,
                    fontSize: 13,
                    fontWeight:
                        selected
                            ? FontWeight
                                .w600
                            : FontWeight
                                .w500,
                  ),
                ),
              ),

              if (selected)
                const Icon(
                  Icons
                      .check_rounded,
                  color:
                      _blueLight,
                  size: 17,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SIDEBAR SCROLL BEHAVIOUR
// ==================================================================

class _SidebarScrollBehavior
    extends ScrollBehavior {
  const _SidebarScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics
      getScrollPhysics(
    BuildContext context,
  ) {
    return const ClampingScrollPhysics();
  }
}