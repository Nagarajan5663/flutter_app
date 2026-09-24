import 'package:flutter/material.dart';

import 'widgets/add_inventory_adjustment_dialog.dart';
import 'widgets/add_returnable_asset_dialog.dart';
import 'widgets/current_stock_tab.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/inventory_adjustments_tab.dart';
import 'widgets/returnable_assets_tab.dart';

class InventoryPage extends StatefulWidget {
  /// 0 = Current Stock
  /// 1 = Inventory Adjustments
  /// 2 = Returnable Assets
  final int initialTab;

  final ValueChanged<String>? onSectionChanged;

  const InventoryPage({
    super.key,
    this.initialTab = 0,
    this.onSectionChanged,
  });

  @override
  State<InventoryPage> createState() =>
      _InventoryPageState();
}

class _InventoryPageState
    extends State<InventoryPage> {
  late int selectedTab;

  @override
  void initState() {
    super.initState();

    selectedTab = _validTab(
      widget.initialTab,
    );
  }

  @override
  void didUpdateWidget(
    covariant InventoryPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTab !=
        widget.initialTab) {
      final int newTab =
          _validTab(widget.initialTab);

      if (selectedTab != newTab) {
        setState(() {
          selectedTab = newTab;
        });
      }
    }
  }

  // ============================================================
  // VALID TAB
  // ============================================================

  int _validTab(int tab) {
    if (tab < 0) {
      return 0;
    }

    if (tab > 2) {
      return 2;
    }

    return tab;
  }

  // ============================================================
  // SECTION NAME
  // ============================================================

  String _sectionName(int index) {
    switch (index) {
      case 0:
        return 'Current Stock';

      case 1:
        return 'Inventory Adjustments';

      case 2:
        return 'Returnable Assets';

      default:
        return 'Current Stock';
    }
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _changeTab(int index) {
    final int validIndex =
        _validTab(index);

    if (selectedTab != validIndex) {
      setState(() {
        selectedTab = validIndex;
      });
    }

    widget.onSectionChanged?.call(
      _sectionName(validIndex),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile =
            constraints.maxWidth < 700;

        final bool enableTilt =
            constraints.maxWidth >= 850;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                InventoryGlassTheme.background1,
                InventoryGlassTheme.background2,
                InventoryGlassTheme.background3,
              ],
            ),
          ),
          child: Stack(
            children: [
              // ==================================================
              // BLUE BACKGROUND ORB
              // ==================================================

              Positioned(
                top: -110,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF3984BA,
                          ).withValues(
                            alpha: 0.32,
                          ),
                          const Color(
                            0xFF3984BA,
                          ).withValues(
                            alpha: 0.04,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // PURPLE BACKGROUND ORB
              // ==================================================

              Positioned(
                bottom: -170,
                left: 20,
                child: IgnorePointer(
                  child: Container(
                    width: 440,
                    height: 440,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF7563AD,
                          ).withValues(
                            alpha: 0.22,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // GREEN BACKGROUND ORB
              // ==================================================

              Positioned(
                top: 270,
                left: -120,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF45B6A1,
                          ).withValues(
                            alpha: 0.18,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // PAGE
              // ==================================================

              SingleChildScrollView(
                padding: EdgeInsets.all(
                  isMobile ? 14 : 30,
                ),
                child:
                    TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: 1,
                  ),
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (
                    context,
                    value,
                    child,
                  ) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          24 * (1 - value),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child:
                      InventoryGlassTiltPanel(
                    enableTilt: enableTilt,
                    borderRadius:
                        isMobile ? 20 : 28,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // HEADER
                        // ==========================================

                        _buildHeader(
                          isMobile: isMobile,
                        ),

                        // ==========================================
                        // TABS
                        // ==========================================

                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                isMobile ? 18 : 38,
                          ),
                          child: _buildMainTabs(
                            isMobile: isMobile,
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // ==========================================
                        // INFO STRIP
                        // ==========================================

                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                isMobile ? 18 : 38,
                          ),
                          child:
                              _buildSectionInfo(),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==========================================
                        // CONTENT
                        // ==========================================

                        Padding(
                          padding: EdgeInsets.only(
                            left:
                                isMobile ? 18 : 38,
                            right:
                                isMobile ? 18 : 38,
                            bottom:
                                isMobile ? 20 : 38,
                          ),
                          child:
                              AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds: 320,
                            ),
                            switchInCurve:
                                Curves.easeOutCubic,
                            switchOutCurve:
                                Curves.easeInCubic,
                            transitionBuilder: (
                              child,
                              animation,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child:
                                    SlideTransition(
                                  position:
                                      Tween<Offset>(
                                    begin:
                                        const Offset(
                                      0.03,
                                      0,
                                    ),
                                    end:
                                        Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent:
                                          animation,
                                      curve: Curves
                                          .easeOutCubic,
                                    ),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child:
                                _buildTabContent(
                              isMobile:
                                  isMobile,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required bool isMobile,
  }) {
    final Widget heading =
        Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        if (!isMobile) ...[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                begin: Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Color(0xFF123F61),
                  Color(0xFF3E83B6),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF174C72)
                          .withValues(
                    alpha: 0.22,
                  ),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.warehouse_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 18),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration:
                        const BoxDecoration(
                      color:
                          Color(0xFF438DC0),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INVENTORY',
                    style: TextStyle(
                      fontSize:
                          isMobile ? 9 : 10,
                      letterSpacing: 1.4,
                      fontWeight:
                          FontWeight.w700,
                      color: const Color(
                        0xFF60778A,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                'Inventory Management',
                style: TextStyle(
                  fontSize:
                      isMobile ? 26 : 35,
                  height: 1.1,
                  fontWeight:
                      FontWeight.w800,
                  color: const Color(
                    0xFF123456,
                  ),
                ),
              ),

              const SizedBox(height: 9),

              Text(
                _headerSubtitle(),
                style: TextStyle(
                  fontSize:
                      isMobile ? 13 : 14,
                  height: 1.5,
                  color: const Color(
                    0xFF6F8292,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 38,
        isMobile ? 25 : 36,
        isMobile ? 20 : 38,
        26,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                heading,

                if (selectedTab != 0) ...[
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child:
                        _buildActionButton(),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: heading,
                ),

                if (selectedTab != 0) ...[
                  const SizedBox(width: 24),
                  _buildActionButton(),
                ],
              ],
            ),
    );
  }

  String _headerSubtitle() {
    switch (selectedTab) {
      case 0:
        return 'View current stock levels for your consumable inventory.';

      case 1:
        return 'Track stock increases, decreases and inventory adjustments.';

      case 2:
        return 'Manage returnable assets and track their availability.';

      default:
        return '';
    }
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton() {
    if (selectedTab == 1) {
      return InventoryGlassButton(
        label: 'Add Adjustment',
        icon: Icons.add_rounded,
        onPressed:
            _openAddAdjustmentDialog,
      );
    }

    if (selectedTab == 2) {
      return InventoryGlassButton(
        label: 'Add Asset',
        icon: Icons.add_rounded,
        onPressed: _openAddAssetDialog,
      );
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // MAIN TABS
  // ============================================================

  Widget _buildMainTabs({
    required bool isMobile,
  }) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.35,
          ),
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFF143B57)
                      .withValues(
                alpha: 0.05,
              ),
              blurRadius: 20,
              offset:
                  const Offset(0, 7),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection:
              Axis.horizontal,
          child: Row(
            children: [
              _buildMainTab(
                title: 'Current Stock',
                icon:
                    Icons.inventory_2_outlined,
                index: 0,
              ),
              _buildMainTab(
                title:
                    'Inventory Adjustments',
                icon:
                    Icons.tune_rounded,
                index: 1,
              ),
              _buildMainTab(
                title:
                    'Returnable Assets',
                icon:
                    Icons.assignment_return_outlined,
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTab({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool selected =
        selectedTab == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(11),
        onTap: () => _changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 240,
          ),
          curve: Curves.easeOutCubic,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(
                    alpha: 0.84,
                  )
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(11),
            border: selected
                ? Border.all(
                    color: Colors.white
                        .withValues(
                      alpha: 0.90,
                    ),
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF123456,
                      ).withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 14,
                      offset:
                          const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(
                        0xFF153F5F,
                      )
                    : const Color(
                        0xFF80909D,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected
                      ? const Color(
                          0xFF153F5F,
                        )
                      : const Color(
                          0xFF748693,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO STRIP
  // ============================================================

  Widget _buildSectionInfo() {
    IconData icon;
    String text;

    switch (selectedTab) {
      case 1:
        icon = Icons.tune_rounded;
        text =
            'Inventory adjustment history will appear below.';
        break;

      case 2:
        icon =
            Icons.assignment_return_outlined;
        text =
            'Available and in-field assets are managed below.';
        break;

      default:
        icon =
            Icons.inventory_2_outlined;
        text =
            'Your current consumable stock will appear below.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.30,
        ),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.65,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF3F82B4)
                      .withValues(
                alpha: 0.11,
              ),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color:
                  const Color(0xFF3979A7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF667A8A),
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildTabContent({
    required bool isMobile,
  }) {
    if (selectedTab == 0) {
      return CurrentStockTab(
        key: const ValueKey(
          'current-stock',
        ),
        isMobile: isMobile,
      );
    }

    if (selectedTab == 1) {
      return InventoryAdjustmentsTab(
        key: const ValueKey(
          'inventory-adjustments',
        ),
        isMobile: isMobile,
      );
    }

    return ReturnableAssetsTab(
      key: const ValueKey(
        'returnable-assets',
      ),
      isMobile: isMobile,
    );
  }

  // ============================================================
  // ADD ADJUSTMENT POPUP
  // ============================================================

  Future<void>
      _openAddAdjustmentDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,

      // Same dark background as Items & Parts dialogs.
      barrierColor:
          const Color(0x9A12202C),

      builder: (dialogContext) {
        return const
            AddInventoryAdjustmentDialog();
      },
    );
  }

  // ============================================================
  // ADD ASSET POPUP
  // ============================================================

  Future<void>
      _openAddAssetDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor:
          const Color(0x9A12202C),
      builder: (dialogContext) {
        return const
            AddReturnableAssetDialog();
      },
    );
  }
}