import 'package:flutter/material.dart';

import 'widgets/current_stock_tab.dart';
import 'widgets/inventory_adjustments_tab.dart';
import 'widgets/returnable_assets_tab.dart';
import 'widgets/add_inventory_adjustment_dialog.dart';
import 'widgets/add_returnable_asset_dialog.dart';

class InventoryPage extends StatefulWidget {
  /// 0 = Current Stock
  /// 1 = Inventory Adjustments
  /// 2 = Returnable Assets
  final int initialTab;

  /// Sends the currently selected Inventory section
  /// back to DashboardPage.
  ///
  /// Current Stock
  /// Inventory Adjustments
  /// Returnable Assets
  final ValueChanged<String>? onSectionChanged;

  const InventoryPage({
    super.key,
    this.initialTab = 0,
    this.onSectionChanged,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late int selectedTab;

  @override
  void initState() {
    super.initState();

    selectedTab = _validTab(widget.initialTab);
  }

  @override
  void didUpdateWidget(covariant InventoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep the internal tab synchronized when
    // DashboardPage changes the selected menu.
    if (oldWidget.initialTab != widget.initialTab) {
      final int newTab = _validTab(widget.initialTab);

      if (selectedTab != newTab) {
        setState(() {
          selectedTab = newTab;
        });
      }
    }
  }

  // ================================================================
  // VALIDATE TAB
  // ================================================================

  int _validTab(int tab) {
    if (tab < 0) {
      return 0;
    }

    if (tab > 2) {
      return 2;
    }

    return tab;
  }

  // ================================================================
  // CHANGE INVENTORY TAB
  // ================================================================

  void _changeTab(int index) {
    final int validIndex = _validTab(index);

    // Update this page.
    setState(() {
      selectedTab = validIndex;
    });

    // IMPORTANT:
    // Tell DashboardPage about the tab change.
    //
    // This keeps the sidebar highlight synchronized.
    widget.onSectionChanged?.call(
      _sectionName(validIndex),
    );
  }

  // ================================================================
  // SECTION NAME
  // ================================================================

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

  // ================================================================
  // BUILD PAGE
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6F8),
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                isMobile ? 16 : 28,
              ),
              child: _buildInventoryCard(
                isMobile: isMobile,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // INVENTORY CARD
  // ================================================================

  Widget _buildInventoryCard({
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD9DEE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isMobile ? 18 : 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            _buildHeader(
              isMobile: isMobile,
            ),

            const SizedBox(height: 30),

            // ======================================================
            // MAIN TABS
            // ======================================================

            _buildMainTabs(
              isMobile: isMobile,
            ),

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFD9DEE5),
            ),

            const SizedBox(height: 28),

            // ======================================================
            // TAB CONTENT
            // ======================================================

            _buildTabContent(
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader({
    required bool isMobile,
  }) {
    final Widget title = Text(
      'Inventory Management',
      style: TextStyle(
        fontSize: isMobile ? 24 : 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF17395C),
      ),
    );

    final Widget actionButton = _buildActionButton(
      isMobile: isMobile,
    );

    // Mobile layout
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 18),
          actionButton,
        ],
      );
    }

    // Desktop layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: title,
        ),
        actionButton,
      ],
    );
  }

  // ================================================================
  // ACTION BUTTON
  // ================================================================

  Widget _buildActionButton({
    required bool isMobile,
  }) {
    // --------------------------------------------------------------
    // CURRENT STOCK
    // --------------------------------------------------------------

    if (selectedTab == 0) {
      return const SizedBox.shrink();
    }

    // --------------------------------------------------------------
    // INVENTORY ADJUSTMENTS
    // --------------------------------------------------------------

    if (selectedTab == 1) {
      return SizedBox(
        width: isMobile ? double.infinity : null,
        child: ElevatedButton.icon(
          onPressed: _openAddAdjustmentDialog,
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
          label: const Text(
            'Add Adjustment',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17395C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      );
    }

    // --------------------------------------------------------------
    // RETURNABLE ASSETS
    // --------------------------------------------------------------

    if (selectedTab == 2) {
      return SizedBox(
        width: isMobile ? double.infinity : null,
        child: ElevatedButton.icon(
          onPressed: _openAddAssetDialog,
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
          label: const Text(
            'Add Asset',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17395C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ================================================================
  // MAIN TABS
  // ================================================================

  Widget _buildMainTabs({
    required bool isMobile,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMainTab(
            title: 'Current Stock',
            index: 0,
            isMobile: isMobile,
          ),

          _buildMainTab(
            title: 'Inventory Adjustments',
            index: 1,
            isMobile: isMobile,
          ),

          _buildMainTab(
            title: 'Returnable Assets',
            index: 2,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SINGLE MAIN TAB
  // ================================================================

  Widget _buildMainTab({
    required String title,
    required int index,
    required bool isMobile,
  }) {
    final bool isSelected = selectedTab == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _changeTab(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF17395C)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF17395C)
                  : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // TAB CONTENT
  // ================================================================

  Widget _buildTabContent({
    required bool isMobile,
  }) {
    // --------------------------------------------------------------
    // CURRENT STOCK
    // --------------------------------------------------------------

    if (selectedTab == 0) {
      return CurrentStockTab(
        isMobile: isMobile,
      );
    }

    // --------------------------------------------------------------
    // INVENTORY ADJUSTMENTS
    // --------------------------------------------------------------

    if (selectedTab == 1) {
      return InventoryAdjustmentsTab(
        isMobile: isMobile,
      );
    }

    // --------------------------------------------------------------
    // RETURNABLE ASSETS
    // --------------------------------------------------------------

    if (selectedTab == 2) {
      return ReturnableAssetsTab(
        isMobile: isMobile,
      );
    }

    // Fallback
    return CurrentStockTab(
      isMobile: isMobile,
    );
  }

  // ================================================================
  // ADD INVENTORY ADJUSTMENT
  // ================================================================

  Future<void> _openAddAdjustmentDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AddInventoryAdjustmentDialog();
      },
    );
  }

  // ================================================================
  // ADD RETURNABLE ASSET
  // ================================================================

  Future<void> _openAddAssetDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AddReturnableAssetDialog();
      },
    );
  }
}