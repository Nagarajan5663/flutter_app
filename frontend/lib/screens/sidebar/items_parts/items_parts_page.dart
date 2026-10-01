import 'package:flutter/material.dart';

import '../../dashboard/widgets/read_only_preview_scope.dart';
import 'item_model.dart';
import 'part_model.dart';
import 'services/items_parts_api.dart';
import 'widgets/add_item_dialog.dart';
import 'widgets/add_part_dialog.dart';
import 'widgets/items_tab.dart';
import 'widgets/parts_tab.dart';

class ItemsPartsPage extends StatefulWidget {
  /// 0 = Items
  /// 1 = Parts
  final int initialTab;

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

  final List<ItemModel> _items = [];
  final List<PartModel> _parts = [];

  bool _isLoading = true;
  String? _errorMessage;

  bool get isItemsTab => selectedTab == 0;

  @override
  void initState() {
    super.initState();

    selectedTab = _validateTab(
      widget.initialTab,
    );

    _loadData();
  }

  @override
  void didUpdateWidget(
    covariant ItemsPartsPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTab != widget.initialTab) {
      final newTab = _validateTab(
        widget.initialTab,
      );

      if (newTab != selectedTab) {
        setState(() {
          selectedTab = newTab;
        });
      }
    }
  }

  int _validateTab(int value) {
    return value == 1 ? 1 : 0;
  }

  // ============================================================
  // LOAD ITEMS + PARTS FROM DATABASE
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ItemsPartsApi.getItems(),
        ItemsPartsApi.getParts(),
      ]);

      if (!mounted) return;

      final items = results[0] as List<ItemModel>;

      final parts = results[1] as List<PartModel>;

      setState(() {
        _items
          ..clear()
          ..addAll(items);

        _parts
          ..clear()
          ..addAll(parts);

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  // ============================================================
  // TAB
  // ============================================================

  void _changeTab(int index) {
    final value = _validateTab(index);

    if (selectedTab != value) {
      setState(() {
        selectedTab = value;
      });
    }

    widget.onSectionChanged?.call(
      value == 0 ? 'Items' : 'Parts',
    );
  }

  // ============================================================
  // ADD / EDIT ITEM
  // ============================================================

  Future<void> _openItemDialog({
    int? editIndex,
  }) async {
    final ItemModel? existingItem =
        editIndex == null ? null : _items[editIndex];

    final ItemModel? result = await showDialog<ItemModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddItemDialog(
          initialItem: existingItem,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      if (editIndex == null) {
        // CREATE
        final createdItem = await ItemsPartsApi.createItem(
          result,
        );

        if (!mounted) return;

        setState(() {
          // API GET uses newest first.
          _items.insert(0, createdItem);
        });

        _showSuccess(
          'Item added successfully.',
        );
      } else {
        // UPDATE
        final currentItem = _items[editIndex];

        if (currentItem.id == null) {
          throw Exception(
            'Item ID is missing',
          );
        }

        final itemToUpdate = result.copyWith(
          id: currentItem.id,
        );

        final updatedItem = await ItemsPartsApi.updateItem(
          itemToUpdate,
        );

        if (!mounted) return;

        setState(() {
          _items[editIndex] = updatedItem;
        });

        _showSuccess(
          'Item updated successfully.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showError(
        _cleanError(error),
      );
    }
  }

  // ============================================================
  // ADD / EDIT PART
  // ============================================================

  Future<void> _openPartDialog({
    int? editIndex,
  }) async {
    final PartModel? existingPart =
        editIndex == null ? null : _parts[editIndex];

    final PartModel? result = await showDialog<PartModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddPartDialog(
          initialPart: existingPart,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      if (editIndex == null) {
        // CREATE
        final createdPart = await ItemsPartsApi.createPart(
          result,
        );

        if (!mounted) return;

        setState(() {
          _parts.insert(0, createdPart);
        });

        _showSuccess(
          'Part added successfully.',
        );
      } else {
        // UPDATE
        final currentPart = _parts[editIndex];

        if (currentPart.id == null) {
          throw Exception(
            'Part ID is missing',
          );
        }

        final partToUpdate = result.copyWith(
          id: currentPart.id,
        );

        final updatedPart = await ItemsPartsApi.updatePart(
          partToUpdate,
        );

        if (!mounted) return;

        setState(() {
          _parts[editIndex] = updatedPart;
        });

        _showSuccess(
          'Part updated successfully.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showError(
        _cleanError(error),
      );
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<bool> _confirmDelete({
    required String type,
    required String name,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete $type?',
          ),
          content: Text(
            'Are you sure you want to delete "$name"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(
                  0xFFC65555,
                ),
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // DELETE ITEM
  // ============================================================

  Future<void> _deleteItem(
    int index,
  ) async {
    final item = _items[index];

    if (item.id == null) {
      _showError(
        'Item ID is missing.',
      );
      return;
    }

    final confirmed = await _confirmDelete(
      type: 'Item',
      name: item.name,
    );

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await ItemsPartsApi.deleteItem(
        item.id!,
      );

      if (!mounted) return;

      setState(() {
        _items.removeAt(index);
      });

      _showSuccess(
        'Item deleted successfully.',
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        _cleanError(error),
      );
    }
  }

  // ============================================================
  // DELETE PART
  // ============================================================

  Future<void> _deletePart(
    int index,
  ) async {
    final part = _parts[index];

    if (part.id == null) {
      _showError(
        'Part ID is missing.',
      );
      return;
    }

    final confirmed = await _confirmDelete(
      type: 'Part',
      name: part.name,
    );

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await ItemsPartsApi.deletePart(
        part.id!,
      );

      if (!mounted) return;

      setState(() {
        _parts.removeAt(index);
      });

      _showSuccess(
        'Part deleted successfully.',
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        _cleanError(error),
      );
    }
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  String _cleanError(Object error) {
    return error.toString().replaceFirst(
          'Exception: ',
          '',
        );
  }

  void _showSuccess(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(
            0xFF163F5E,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(
            0xFFA94442,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        final bool isMobile = constraints.maxWidth < 700;

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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMobile ? 14 : 30,
            ),
            child: ReadOnlyPreviewScope.blockActions(
              context,
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.48,
                  ),
                  borderRadius: BorderRadius.circular(
                    isMobile ? 20 : 28,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.75,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF173D59,
                      ).withValues(
                        alpha: 0.09,
                      ),
                      blurRadius: 35,
                      offset: const Offset(
                        0,
                        14,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      isMobile,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 38,
                      ),
                      child: _buildTabs(
                        isMobile,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 38,
                      ),
                      child: _buildInfoBox(),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 18 : 38,
                        0,
                        isMobile ? 18 : 38,
                        isMobile ? 20 : 38,
                      ),
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Color(0xFFA65B5B),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Unable to load data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25394B),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF748693),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 250,
      ),
      child: isItemsTab
          ? ItemsTab(
              key: const ValueKey(
                'items',
              ),
              items: _items,
              onAddItem: () {
                _openItemDialog();
              },
              onEditItem: (index) {
                _openItemDialog(
                  editIndex: index,
                );
              },
              onDeleteItem: _deleteItem,
            )
          : PartsTab(
              key: const ValueKey(
                'parts',
              ),
              parts: _parts,
              onAddPart: () {
                _openPartDialog();
              },
              onEditPart: (index) {
                _openPartDialog(
                  editIndex: index,
                );
              },
              onDeletePart: _deletePart,
            ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    bool isMobile,
  ) {
    final titleContent = Row(
      children: [
        if (!isMobile) ...[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF123F61),
                  Color(0xFF3E83B6),
                ],
              ),
              borderRadius: BorderRadius.circular(
                17,
              ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(
                      0xFF438DC0,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'INVENTORY MANAGEMENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Color(
                        0xFF60778A,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Manage Items & Parts',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 35,
                  fontWeight: FontWeight.w800,
                  color: const Color(
                    0xFF123456,
                  ),
                ),
              ),
              const SizedBox(
                height: 9,
              ),
              Text(
                isItemsTab
                    ? 'Create and manage your inventory items in one place.'
                    : 'Manage components and individual parts in your inventory.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(
                    0xFF6F8292,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final addButton = ElevatedButton.icon(
      onPressed: _isLoading
          ? null
          : isItemsTab
              ? () {
                  _openItemDialog();
                }
              : () {
                  _openPartDialog();
                },
      icon: const Icon(
        Icons.add_rounded,
      ),
      label: Text(
        isItemsTab ? 'Add New Item' : 'Add New Part',
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(
          0xFF194E75,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 23,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            13,
          ),
        ),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleContent,
                const SizedBox(
                  height: 22,
                ),
                SizedBox(
                  width: double.infinity,
                  child: addButton,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: titleContent,
                ),
                const SizedBox(
                  width: 24,
                ),
                addButton,
              ],
            ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs(
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.34,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.68,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _tabButton(
            title: 'Items',
            icon: Icons.inventory_2_outlined,
            index: 0,
            isMobile: isMobile,
          ),
          _tabButton(
            title: 'Parts',
            icon: Icons.settings_outlined,
            index: 1,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
    required bool isMobile,
  }) {
    final bool selected = selectedTab == index;

    final button = InkWell(
      onTap: () {
        _changeTab(index);
      },
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 23,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(
                  alpha: 0.86,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            11,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(
              width: 8,
            ),
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
    );

    return isMobile
        ? Expanded(
            child: button,
          )
        : button;
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoBox() {
    String message;

    if (_isLoading) {
      message = 'Loading inventory data...';
    } else if (isItemsTab) {
      message = _items.isEmpty
          ? 'Your inventory items will appear below.'
          : '${_items.length} item${_items.length == 1 ? '' : 's'} available.';
    } else {
      message = _parts.isEmpty
          ? 'Your available parts will appear below.'
          : '${_parts.length} part${_parts.length == 1 ? '' : 's'} available.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.28,
        ),
        borderRadius: BorderRadius.circular(13),
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
              color: const Color(
                0xFF3F82B4,
              ).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              isItemsTab
                  ? Icons.inventory_2_outlined
                  : Icons.precision_manufacturing_outlined,
              size: 19,
              color: const Color(
                0xFF3979A7,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(
                  0xFF667A8A,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Color(
                0xFF3979A7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
