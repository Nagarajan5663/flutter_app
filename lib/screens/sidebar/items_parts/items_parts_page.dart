import 'package:flutter/material.dart';

import 'widgets/add_item_dialog.dart';
import 'widgets/add_part_dialog.dart';
import 'widgets/items_tab.dart';

class ItemsPartsPage extends StatefulWidget {
  /// 0 = Items
  /// 1 = Parts
  final int initialTab;

  /// Tells DashboardPage when the internal tab changes.
  ///
  /// Example:
  /// onSectionChanged: (section) {
  ///   _selectMenu(section);
  /// }
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

    // If DashboardPage changes the requested tab,
    // update this page as well.
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
    if (tab < 0) {
      return 0;
    }

    if (tab > 1) {
      return 1;
    }

    return tab;
  }

  // ============================================================
  // CHANGE TAB
  // ============================================================

  void _changeTab(int index) {
    final int validIndex = _validTab(index);

    if (selectedTab == validIndex) {
      // Even if the tab is already selected, make sure
      // DashboardPage knows the current section.
      widget.onSectionChanged?.call(
        validIndex == 0 ? 'Items' : 'Parts',
      );
      return;
    }

    setState(() {
      selectedTab = validIndex;
    });

    // IMPORTANT:
    // Tell DashboardPage about the internal tab change.
    //
    // Items tab  -> sidebar selects "Items"
    // Parts tab  -> sidebar selects "Parts"
    widget.onSectionChanged?.call(
      validIndex == 0 ? 'Items' : 'Parts',
    );
  }

  // ============================================================
  // OPEN ADD ITEM FORM
  // ============================================================

  void _openAddItem() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AddItemDialog();
      },
    );
  }

  // ============================================================
  // OPEN ADD PART FORM
  // ============================================================

  void _openAddPart() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AddPartDialog();
      },
    );
  }

  // ============================================================
  // BUILD PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isItemsTab = selectedTab == 0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F6F8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isMobile ? 16 : 20,
            ),
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // PAGE HEADER
                  // ==================================================

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 20 : 30,
                      isMobile ? 22 : 28,
                      isMobile ? 20 : 30,
                      18,
                    ),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Manage Items & Parts',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF123456),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildAddButton(
                                isItemsTab: isItemsTab,
                                isMobile: true,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Manage Items & Parts',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF123456),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _buildAddButton(
                                isItemsTab: isItemsTab,
                                isMobile: false,
                              ),
                            ],
                          ),
                  ),

                  // ==================================================
                  // TABS
                  // ==================================================

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 30,
                    ),
                    child: Row(
                      children: [
                        _buildTab(
                          title: 'Items',
                          index: 0,
                          isMobile: isMobile,
                        ),
                        _buildTab(
                          title: 'Parts',
                          index: 1,
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // TAB DIVIDER
                  // ==================================================

                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFD9DEE5),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // TAB CONTENT
                  // ==================================================

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 30,
                    ),
                    child: isItemsTab
                        ? ItemsTab(
                            onAddItem: _openAddItem,
                          )
                        : _buildPartsContent(
                            isMobile: isMobile,
                          ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget _buildAddButton({
    required bool isItemsTab,
    required bool isMobile,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isItemsTab ? _openAddItem : _openAddPart,
        icon: const Icon(
          Icons.add,
          size: 20,
        ),
        label: Text(
          isItemsTab ? 'Add New Item' : 'Add New Part',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF123456),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD TAB
  // ============================================================

  Widget _buildTab({
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
            horizontal: isMobile ? 16 : 22,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF123456)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF123456)
                  : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PARTS CONTENT
  // ============================================================

  Widget _buildPartsContent({
    required bool isMobile,
  }) {
    // On smaller screens, give the table a finite width
    // so horizontal scrolling does not create infinite constraints.
    final double tableWidth = isMobile ? 700 : 850;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // PARTS TABLE HEADER
            // ======================================================

            Container(
              width: tableWidth,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              color: const Color(0xFFF7F8FA),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'NAME',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B5B5B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'SKU',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B5B5B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'PURCHASE PRICE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B5B5B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ACTIONS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B5B5B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // DIVIDER
            // ======================================================

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFD9DEE5),
            ),

            // ======================================================
            // EMPTY STATE
            // ======================================================

            Container(
              width: tableWidth,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              child: const Text(
                'No parts found.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF42474D),
                ),
              ),
            ),

            // ======================================================
            // BOTTOM DIVIDER
            // ======================================================

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFD9DEE5),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}