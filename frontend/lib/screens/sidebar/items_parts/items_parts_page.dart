import 'dart:ui';

import 'package:flutter/material.dart';

import 'widgets/add_item_dialog.dart';
import 'widgets/add_part_dialog.dart';
import 'widgets/items_tab.dart';

class ItemsPartsPage extends StatefulWidget {
  /// 0 = Items
  /// 1 = Parts
  final int initialTab;

  /// Sync internal tab with dashboard/sidebar.
  final ValueChanged<String>? onSectionChanged;

  const ItemsPartsPage({
    super.key,
    this.initialTab = 0,
    this.onSectionChanged,
  });

  @override
  State<ItemsPartsPage> createState() => _ItemsPartsPageState();
}

class _ItemsPartsPageState extends State<ItemsPartsPage> {
  late int selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = _validTab(widget.initialTab);
  }

  @override
  void didUpdateWidget(covariant ItemsPartsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTab != widget.initialTab) {
      final int newTab = _validTab(widget.initialTab);

      if (selectedTab != newTab) {
        setState(() {
          selectedTab = newTab;
        });
      }
    }
  }

  int _validTab(int tab) {
    if (tab < 0) return 0;
    if (tab > 1) return 1;
    return tab;
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _changeTab(int index) {
    final int validIndex = _validTab(index);

    if (selectedTab != validIndex) {
      setState(() {
        selectedTab = validIndex;
      });
    }

    widget.onSectionChanged?.call(
      validIndex == 0 ? 'Items' : 'Parts',
    );
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  void _openAddItem() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AddItemDialog();
      },
    );
  }

  // ============================================================
  // ADD PART
  // ============================================================

  void _openAddPart() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AddPartDialog();
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isItemsTab = selectedTab == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        final bool enableTilt = constraints.maxWidth >= 850;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCADAE7),
      Color(0xFFD2D6E3),
      Color(0xFFC7DCD9),
    ],
  ),
),
          child: Stack(
            children: [
              // ====================================================
              // BACKGROUND ORB 1
              // ====================================================

              Positioned(
                top: -100,
                right: -60,
                child: IgnorePointer(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF3984BA)
                              .withValues(alpha: 0.23),
                          const Color(0xFF3984BA)
                              .withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ====================================================
              // BACKGROUND ORB 2
              // ====================================================

              Positioned(
                bottom: -160,
                left: 30,
                child: IgnorePointer(
                  child: Container(
                    width: 430,
                    height: 430,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7563AD)
                              .withValues(alpha: 0.16),
                          const Color(0xFF7563AD)
                              .withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ====================================================
              // BACKGROUND ORB 3
              // ====================================================

              Positioned(
                top: 250,
                left: -120,
                child: IgnorePointer(
                  child: Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF45B6A1)
                              .withValues(alpha: 0.13),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ====================================================
              // PAGE CONTENT
              // ====================================================

              SingleChildScrollView(
                padding: EdgeInsets.all(
                  isMobile ? 14 : 30,
                ),
                child: TweenAnimationBuilder<double>(
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
                          25 * (1 - value),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: GlassTiltPanel(
                    enableTilt: enableTilt,
                    borderRadius: isMobile ? 20 : 28,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // HEADER
                        // ==========================================

                        _buildHeader(
                          isMobile: isMobile,
                          isItemsTab: isItemsTab,
                        ),

                        // ==========================================
                        // TAB AREA
                        // ==========================================

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isMobile ? 18 : 38,
                          ),
                          child: _buildTabs(
                            isMobile: isMobile,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==========================================
                        // SECTION INFO
                        // ==========================================

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isMobile ? 18 : 38,
                          ),
                          child: _buildSectionInfo(
                            isItemsTab: isItemsTab,
                            isMobile: isMobile,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==========================================
                        // TAB CONTENT
                        // ==========================================

                        Padding(
                          padding: EdgeInsets.only(
                            left: isMobile ? 18 : 38,
                            right: isMobile ? 18 : 38,
                            bottom: isMobile ? 20 : 38,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(
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
                              final slideAnimation =
                                  Tween<Offset>(
                                begin: const Offset(
                                  0.03,
                                  0,
                                ),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve:
                                      Curves.easeOutCubic,
                                ),
                              );

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      slideAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: isItemsTab
                                ? ItemsTab(
                                    key: const ValueKey(
                                      'items',
                                    ),
                                    onAddItem:
                                        _openAddItem,
                                  )
                                : _buildPartsContent(
                                    key: const ValueKey(
                                      'parts',
                                    ),
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
    required bool isItemsTab,
  }) {
    final titleArea = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isMobile) ...[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF123F61),
                  Color(0xFF3E83B6),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF174C72)
                      .withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 28,
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
                      color: Color(0xFF438DC0),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INVENTORY MANAGEMENT',
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color:
                          const Color(0xFF60778A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Manage Items & Parts',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 35,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF123456),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                isItemsTab
                    ? 'Create and manage your inventory items in one place.'
                    : 'Manage components and individual parts in your inventory.',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  height: 1.5,
                  color: const Color(0xFF6F8292),
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
                titleArea,
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: _buildAddButton(
                    isItemsTab: isItemsTab,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: titleArea,
                ),
                const SizedBox(width: 24),
                _buildAddButton(
                  isItemsTab: isItemsTab,
                ),
              ],
            ),
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget _buildAddButton({
    required bool isItemsTab,
  }) {
    return _HoverScale(
      scale: 1.025,
      child: ElevatedButton.icon(
        onPressed:
            isItemsTab ? _openAddItem : _openAddPart,
        icon: const Icon(
          Icons.add_rounded,
          size: 21,
        ),
        label: Text(
          isItemsTab
              ? 'Add New Item'
              : 'Add New Part',
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              const Color(0xFF194E75),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 23,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GLASS TABS
  // ============================================================

  Widget _buildTabs({
    required bool isMobile,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.34,
            ),
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.68,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF143B57)
                    .withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: isMobile
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              _buildTab(
                title: 'Items',
                icon:
                    Icons.inventory_2_outlined,
                index: 0,
                isMobile: isMobile,
              ),
              _buildTab(
                title: 'Parts',
                icon: Icons.settings_outlined,
                index: 1,
                isMobile: isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required int index,
    required bool isMobile,
  }) {
    final bool selected =
        selectedTab == index;

    final tab = AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 15 : 23,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(
                alpha: 0.82,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: selected
            ? Border.all(
                color: Colors.white.withValues(
                  alpha: 0.88,
                ),
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF123456)
                      .withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 220),
            child: Icon(
              icon,
              key: ValueKey(selected),
              size: 18,
              color: selected
                  ? const Color(0xFF153F5F)
                  : const Color(0xFF80909D),
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
                  ? const Color(0xFF153F5F)
                  : const Color(0xFF748693),
            ),
          ),
        ],
      ),
    );

    final clickable = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(11),
        onTap: () => _changeTab(index),
        child: tab,
      ),
    );

    if (isMobile) {
      return Expanded(
        child: clickable,
      );
    }

    return clickable;
  }

  // ============================================================
  // SECTION INFORMATION
  // ============================================================

  Widget _buildSectionInfo({
    required bool isItemsTab,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 17,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.28,
        ),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.60,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF3F82B4)
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              isItemsTab
                  ? Icons.inventory_2_outlined
                  : Icons.precision_manufacturing_outlined,
              size: 19,
              color: const Color(0xFF3979A7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isItemsTab
                  ? 'Your inventory items will appear below.'
                  : 'Your available parts will appear below.',
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: const Color(0xFF667A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PARTS TABLE
  // ============================================================

  Widget _buildPartsContent({
    Key? key,
    required bool isMobile,
  }) {
    return _GlassTable(
      key: key,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double minWidth = 760;

          final double width =
              constraints.maxWidth < minWidth
                  ? minWidth
                  : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  // ================================================
                  // HEADER
                  // ================================================

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.33,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white
                              .withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _TableHeader(
                            title: 'NAME',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _TableHeader(
                            title: 'SKU',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _TableHeader(
                            title:
                                'PURCHASE PRICE',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _TableHeader(
                            title: 'ACTIONS',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ================================================
                  // EMPTY STATE
                  // ================================================

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 55,
                    ),
                    child: Column(
                      children: [
                        _HoverScale(
                          scale: 1.06,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.40,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                23,
                              ),
                              border: Border.all(
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.75,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(
                                    0xFF24587E,
                                  ).withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 18,
                                  offset:
                                      const Offset(
                                    0,
                                    8,
                                  ),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons
                                  .settings_suggest_outlined,
                              size: 37,
                              color:
                                  Color(0xFF427FA8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No parts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Color(0xFF203A4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start by adding your first part to your inventory.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color:
                                Color(0xFF778A98),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _HoverScale(
                          scale: 1.035,
                          child:
                              OutlinedButton.icon(
                            onPressed:
                                _openAddPart,
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Add First Part',
                            ),
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  const Color(
                                0xFF1A537A,
                              ),
                              backgroundColor:
                                  Colors.white
                                      .withValues(
                                alpha: 0.25,
                              ),
                              side: BorderSide(
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.90,
                                ),
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 19,
                                vertical: 13,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  11,
                                ),
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
        },
      ),
    );
  }
}

// ============================================================================
// GLASS + 3D HOVER TILT PANEL
// ============================================================================

class GlassTiltPanel extends StatefulWidget {
  final Widget child;
  final bool enableTilt;
  final double borderRadius;

  const GlassTiltPanel({
    super.key,
    required this.child,
    this.enableTilt = true,
    this.borderRadius = 28,
  });

  @override
  State<GlassTiltPanel> createState() =>
      _GlassTiltPanelState();
}

class _GlassTiltPanelState
    extends State<GlassTiltPanel> {
  double rotateX = 0;
  double rotateY = 0;

  bool hovering = false;

  void _onHover(PointerEvent event) {
    if (!widget.enableTilt) return;

    final RenderObject? object =
        context.findRenderObject();

    if (object is! RenderBox) return;

    final Size size = object.size;

    if (size.width == 0 ||
        size.height == 0) {
      return;
    }

    final double x =
        (event.localPosition.dx / size.width) -
            0.5;

    final double y =
        (event.localPosition.dy / size.height) -
            0.5;

    // Small professional tilt.
    const double maxTilt = 0.025;

    setState(() {
      rotateY = x * maxTilt;
      rotateX = -y * maxTilt;
    });
  }

  void _reset() {
    if (!mounted) return;

    setState(() {
      hovering = false;
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enableTilt) return;

        setState(() {
          hovering = true;
        });
      },
      onHover: _onHover,
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: hovering ? 100 : 350,
        ),
        curve: hovering
            ? Curves.linear
            : Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            widget.borderRadius,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173D59)
                  .withValues(
                alpha: hovering ? 0.15 : 0.09,
              ),
              blurRadius: hovering ? 48 : 35,
              spreadRadius: hovering ? 2 : 0,
              offset: Offset(
                rotateY * 120,
                14 + (rotateX * 80),
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(
            widget.borderRadius,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 230),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha:
                      hovering ? 0.59 : 0.49,
                ),
                borderRadius:
                    BorderRadius.circular(
                  widget.borderRadius,
                ),
                border: Border.all(
                  width: 1.3,
                  color: Colors.white.withValues(
                    alpha:
                        hovering ? 0.88 : 0.68,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  widget.child,

                  // ================================================
                  // TOP GLASS SHINE
                  // ================================================

                  Positioned(
                    top: -120,
                    right: -70,
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha: hovering
                                    ? 0.24
                                    : 0.13,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ================================================
                  // GLASS EDGE LIGHT
                  // ================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient:
                              LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white
                                  .withValues(
                                alpha: 0.95,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
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

// ============================================================================
// GLASS TABLE WRAPPER
// ============================================================================

class _GlassTable extends StatefulWidget {
  final Widget child;

  const _GlassTable({
    super.key,
    required this.child,
  });

  @override
  State<_GlassTable> createState() =>
      _GlassTableState();
}

class _GlassTableState
    extends State<_GlassTable> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: hovering ? 0.37 : 0.27,
          ),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: hovering ? 0.88 : 0.65,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163E5A)
                  .withValues(
                alpha: hovering ? 0.10 : 0.05,
              ),
              blurRadius: hovering ? 25 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(17),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================================
// SMALL HOVER SCALE
// ============================================================================

class _HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;

  const _HoverScale({
    required this.child,
    this.scale = 1.03,
  });

  @override
  State<_HoverScale> createState() =>
      _HoverScaleState();
}

class _HoverScaleState
    extends State<_HoverScale> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        duration:
            const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        scale:
            hovering ? widget.scale : 1,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// TABLE HEADER
// ============================================================================

class _TableHeader extends StatelessWidget {
  final String title;

  const _TableHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.65,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5C7283),
      ),
    );
  }
}