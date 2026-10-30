import 'package:flutter/material.dart';

import '../shared/glass_modal_shell.dart';
import '../bills/bill_model.dart';
import '../bills/bill_repository.dart';
import '../bills/widgets/add_bill_dialog.dart';
import '../vendors/vendor_model.dart';
import '../vendors/vendor_repository.dart';
import 'purchase_order_filter.dart';
import 'purchase_order_model.dart';
import 'purchase_order_repository.dart';
import 'widgets/add_purchase_order_dialog.dart';
import 'widgets/purchase_order_preview_dialog.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  final PurchaseOrderRepository _repository = InMemoryPurchaseOrderRepository();
  final BillRepository _billRepository = InMemoryBillRepository();
  final VendorRepository _vendorRepository = InMemoryVendorRepository();

  List<PurchaseOrderModel> _orders = [];
  final Set<String> _updatingStatusIds = <String>{};
  bool _isLoading = true;

  final vendorController = TextEditingController();
  final referenceController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  String statusFilter = 'All';
  final statusOptions = const [
    'All',
    'Draft',
    'Sent',
    'Closed',
    'Ordered',
    'Received',
    'Cancelled'
  ];
  static const List<String> _editableStatusOptions = [
    'Draft',
    'Sent',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    vendorController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  PurchaseOrderFilter get _currentFilter => PurchaseOrderFilter(
        status: statusFilter,
        vendorName: vendorController.text,
        referenceNumber: referenceController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadOrders() async {
    if (dateFrom != null && dateTo != null && dateTo!.isBefore(dateFrom!)) {
      final corrected = dateFrom!;
      setState(() => dateTo = corrected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Date To cannot be earlier than Date From')),
        );
      }
    }

    setState(() => _isLoading = true);
    final result = await _repository.getPurchaseOrders(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _orders = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddOrder() async {
    final order = await showDialog<PurchaseOrderModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddPurchaseOrderDialog(),
    );

    if (!mounted || order == null) return;

    await _repository.addPurchaseOrder(order);
    await _loadOrders();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase order created successfully')),
    );
  }

  Future<void> _deleteOrder(PurchaseOrderModel order) async {
    if (order.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete purchase order?'),
        content: Text('Delete purchase order ${order.poNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFAB2A2A),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _repository.deletePurchaseOrder(order.id!);
      await _loadOrders();
    } catch (error) {
      _showActionError('delete purchase order', error);
    }
  }

  Future<void> _editOrder(PurchaseOrderModel currentOrder) async {
    final updated = await showDialog<PurchaseOrderModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddPurchaseOrderDialog(initialOrder: currentOrder),
    );
    if (updated == null || !mounted) return;

    try {
      await _repository.updatePurchaseOrder(updated);
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order updated successfully')),
      );
    } catch (error) {
      _showActionError('update purchase order', error);
    }
  }

  Future<void> _updateOrderStatus(
    PurchaseOrderModel order,
    String status,
  ) async {
    final id = order.id;
    if (id == null || id.trim().isEmpty) {
      _showActionError(
        'update purchase order status',
        Exception('Purchase order ID is missing'),
      );
      return;
    }

    setState(() => _updatingStatusIds.add(id));
    try {
      await _repository.updateStatus(id, status);
      if (!mounted) return;
      setState(() {
        _orders = _orders
            .map(
              (candidate) => candidate.id == id
                  ? candidate.copyWith(status: status)
                  : candidate,
            )
            .where(
              (candidate) =>
                  statusFilter == 'All' || candidate.status == statusFilter,
            )
            .toList();
      });
    } catch (error) {
      _showActionError('update purchase order status', error);
    } finally {
      if (mounted) {
        setState(() => _updatingStatusIds.remove(id));
      }
    }
  }

  Future<void> _duplicateOrder(PurchaseOrderModel order) async {
    try {
      final duplicate = PurchaseOrderModel(
        poNumber: await _repository.nextPoNumber(),
        vendorId: order.vendorId,
        vendorName: order.vendorName,
        date: DateTime.now(),
        deliveryExpectedDate: order.deliveryExpectedDate,
        paymentTerms: order.paymentTerms,
        dueDate: order.dueDate,
        referenceNumber: order.referenceNumber,
        items: order.items,
      );
      await _repository.addPurchaseOrder(duplicate);
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase order duplicated successfully'),
        ),
      );
    } catch (error) {
      _showActionError('duplicate purchase order', error);
    }
  }

  void _showActionError(String action, Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to $action: $error')),
    );
  }

  Future<void> _previewOrder(PurchaseOrderModel order) async {
    VendorModel? vendor;
    try {
      vendor = await _vendorRepository.getVendorById(order.vendorId);
    } catch (error) {
      _showActionError('load vendor contact details', error);
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => PurchaseOrderPreviewDialog(
        order: order,
        vendor: vendor,
        onConvertToBill: () => _convertOrderToBill(order),
        onVoid: () => _voidOrder(order),
      ),
    );
  }

  Future<bool> _convertOrderToBill(PurchaseOrderModel order) async {
    try {
      final purchaseOrderId = order.id;
      if (purchaseOrderId == null || purchaseOrderId.trim().isEmpty) {
        throw Exception('Purchase order ID is missing');
      }

      final bills = await _billRepository.getBills();
      if (bills.any((bill) => bill.purchaseOrderId == purchaseOrderId)) {
        throw Exception(
            'This purchase order has already been converted to a bill');
      }
      if (!mounted) return false;

      final BillModelDraft? draft = await showDialog<BillModelDraft>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddBillDialog(initialPurchaseOrder: order),
      );
      if (!mounted || draft == null) return false;

      final bill = BillModel(
        billNumber: draft.billNumber,
        vendorInvoiceNumber: draft.vendorInvoiceNumber,
        invoiceAttachmentPath: draft.invoiceAttachmentPath,
        vendorId: draft.vendorId,
        vendorName: draft.vendorName,
        purchaseOrderId: purchaseOrderId,
        purchaseOrderNumber: order.poNumber,
        billDate: draft.billDate,
        dueDate: draft.dueDate,
        items: draft.items,
        taxAmount: draft.taxAmount,
      );
      await _billRepository.addBill(bill);
      await _loadOrders();
      if (!mounted) return false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Bill saved successfully')),
        );
      return true;
    } catch (error) {
      _showActionError('convert purchase order to bill', error);
      return false;
    }
  }

  Future<bool> _voidOrder(PurchaseOrderModel order) async {
    try {
      final id = order.id;
      if (id == null || id.trim().isEmpty) {
        throw Exception('Purchase order ID is missing');
      }
      await _repository.updateStatus(id, 'Cancelled');
      await _loadOrders();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order marked as Cancelled')),
      );
      return true;
    } catch (error) {
      _showActionError('void purchase order', error);
      return false;
    }
  }

  void _clearFilters() {
    statusFilter = 'All';
    vendorController.clear();
    referenceController.clear();
    dateFrom = null;
    dateTo = null;
    _loadOrders();
  }

  Future<void> _pickDate(
    DateTime? initial,
    ValueChanged<DateTime?> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    onPicked(picked);
  }

  Future<void> _openDateMenu({
    required DateTime? currentValue,
    required ValueChanged<DateTime?> onPicked,
    required bool isDarkMode,
    required BuildContext anchorContext,
  }) async {
    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    final overlay = Navigator.of(anchorContext)
        .overlay
        ?.context
        .findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) {
      await _pickDate(currentValue, onPicked);
      return;
    }

    final rect = Rect.fromPoints(
      renderBox.localToGlobal(Offset.zero, ancestor: overlay),
      renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay),
    );

    await showMenu<DateTime?>(
      context: anchorContext,
      position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
      color: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 320),
      items: [
        _CalendarPopupMenuEntry(
          initialDate: currentValue,
          isDarkMode: isDarkMode,
          onPicked: onPicked,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final labelTextColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final fieldFillColor = isDarkMode
        ? const Color(0xFF111827).withOpacity(0.82)
        : Colors.white;
    final fieldBorderColor =
        isDarkMode ? const Color(0xFF475569) : const Color(0xFFD9DEE5);
    final placeholderColor =
        isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final menuBackgroundColor =
        isDarkMode ? const Color(0xFF111827) : Colors.white;
    final selectedOptionBackground = const Color(0xFFEAF3FF);
    final hoverOptionBackground =
        isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);

    return GlassPageBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Purchase Orders',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                GlassButton(
                  onPressed: _openAddOrder,
                  icon: Icons.add,
                  label: 'New Purchase Order',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FILTER CARD
            GlassPanel(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterField(
                    label: 'Status',
                    labelColor: labelTextColor,
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: fieldFillColor,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: fieldBorderColor),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dropdownMenuTheme: DropdownMenuThemeData(
                            menuStyle: MenuStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(menuBackgroundColor),
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: statusFilter,
                            isExpanded: true,
                            dropdownColor: menuBackgroundColor,
                            iconEnabledColor: textColor,
                            iconDisabledColor: placeholderColor,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            items: statusOptions
                                .map(
                                  (status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: status == statusFilter
                                            ? selectedOptionBackground
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: status == statusFilter
                                              ? const Color(0xFF1F2937)
                                              : textColor,
                                          fontWeight: status == statusFilter
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => statusFilter = value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Vendor Name',
                    labelColor: labelTextColor,
                    child: SizedBox(
                        width: 170,
                        child: _filterTextField(
                            vendorController, 'Vendor name...',
                            textColor: textColor,
                            placeholderColor: placeholderColor,
                            fillColor: fieldFillColor,
                            borderColor: fieldBorderColor,
                            focusedBorderColor: isDarkMode
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF123456))),
                  ),
                  _filterField(
                    label: 'Reference #',
                    labelColor: labelTextColor,
                    child: SizedBox(
                        width: 150,
                        child: _filterTextField(
                            referenceController, 'Reference...',
                            textColor: textColor,
                            placeholderColor: placeholderColor,
                            fillColor: fieldFillColor,
                            borderColor: fieldBorderColor,
                            focusedBorderColor: isDarkMode
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF123456))),
                  ),
                  _filterField(
                    label: 'Date From',
                    labelColor: labelTextColor,
                    child: SizedBox(
                      width: 150,
                      child: _filterDateField(
                        dateFrom,
                        (d) => setState(() => dateFrom = d),
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        placeholderColor: placeholderColor,
                        fillColor: fieldFillColor,
                        borderColor: fieldBorderColor,
                        onOpen: () => _openDateMenu(
                          currentValue: dateFrom,
                          onPicked: (d) => setState(() => dateFrom = d),
                          isDarkMode: isDarkMode,
                          anchorContext: context,
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Date To',
                    labelColor: labelTextColor,
                    child: SizedBox(
                      width: 150,
                      child: _filterDateField(
                        dateTo,
                        (d) => setState(() => dateTo = d),
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        placeholderColor: placeholderColor,
                        fillColor: fieldFillColor,
                        borderColor: fieldBorderColor,
                        onOpen: () => _openDateMenu(
                          currentValue: dateTo,
                          onPicked: (d) => setState(() => dateTo = d),
                          isDarkMode: isDarkMode,
                          anchorContext: context,
                        ),
                      ),
                    ),
                  ),
                  GlassButton(
                    onPressed: _loadOrders,
                    icon: Icons.filter_alt_outlined,
                    label: 'Filter',
                  ),
                  GlassButton(
                    onPressed: _clearFilters,
                    icon: Icons.refresh,
                    label: 'Clear',
                    primary: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TABLE CARD
            GlassPanel(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: FittedBox(
                      alignment: Alignment.topLeft,
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 1000,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 1000,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.35),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14)),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 2, child: _HeaderText('DATE')),
                                  Expanded(flex: 2, child: _HeaderText('PO #')),
                                  Expanded(
                                      flex: 3,
                                      child: _HeaderText('VENDOR NAME')),
                                  Expanded(
                                      flex: 2, child: _HeaderText('STATUS')),
                                  Expanded(
                                      flex: 2,
                                      child: _HeaderText('REFERENCE #')),
                                  Expanded(
                                      flex: 2, child: _HeaderText('AMOUNT')),
                                  Expanded(
                                      flex: 2, child: _HeaderText('ACTIONS')),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFD9DEE5)),
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (_orders.isEmpty)
                              Container(
                                width: 1000,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 24),
                                child: const Text(
                                  'No purchase orders found. Click "+ New Purchase Order" to add one!',
                                  style: TextStyle(
                                      fontSize: 16, color: Color(0xFF42474D)),
                                ),
                              )
                            else
                              ..._orders.map((order) {
                                return Column(
                                  children: [
                                    Container(
                                      width: 1000,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${order.date.day.toString().padLeft(2, '0')}-${order.date.month.toString().padLeft(2, '0')}-${order.date.year}',
                                            ),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Text(order.poNumber)),
                                          Expanded(
                                              flex: 3,
                                              child: Text(order.vendorName)),
                                          Expanded(
                                            flex: 2,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE7EEF6),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      value: order.status,
                                                      isDense: true,
                                                      icon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 18,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF123456),
                                                      ),
                                                      items: [
                                                        ..._editableStatusOptions,
                                                        if (!_editableStatusOptions
                                                            .contains(
                                                          order.status,
                                                        ))
                                                          order.status,
                                                      ]
                                                          .map(
                                                            (status) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                              value: status,
                                                              child: Text(
                                                                status,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                      onChanged: order.status ==
                                                                  'Cancelled' ||
                                                              order.id ==
                                                                  null ||
                                                              _updatingStatusIds
                                                                  .contains(
                                                                order.id,
                                                              )
                                                          ? null
                                                          : (status) {
                                                              if (status !=
                                                                  null) {
                                                                _updateOrderStatus(
                                                                  order,
                                                                  status,
                                                                );
                                                              }
                                                            },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                                order.referenceNumber.isEmpty
                                                    ? '-'
                                                    : order.referenceNumber),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                  'INR ${order.total.toStringAsFixed(2)}')),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  onPressed: () =>
                                                      _previewOrder(order),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  constraints:
                                                      const BoxConstraints
                                                          .tightFor(
                                                    width: 30,
                                                    height: 32,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.visibility_outlined,
                                                    color: Color(0xFF7A8490),
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      'View purchase order',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _editOrder(order),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  constraints:
                                                      const BoxConstraints
                                                          .tightFor(
                                                    width: 30,
                                                    height: 32,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Color(0xFF7A8490),
                                                    size: 19,
                                                  ),
                                                  tooltip:
                                                      'Edit purchase order',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _duplicateOrder(order),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  constraints:
                                                      const BoxConstraints
                                                          .tightFor(
                                                    width: 30,
                                                    height: 32,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.content_copy_outlined,
                                                    color: Color(0xFF7A8490),
                                                    size: 18,
                                                  ),
                                                  tooltip:
                                                      'Duplicate purchase order',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _deleteOrder(order),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  constraints:
                                                      const BoxConstraints
                                                          .tightFor(
                                                    width: 30,
                                                    height: 32,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Color(0xFFAB2A2A),
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      'Delete purchase order',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFEDEFF2)),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField({
    required String label,
    required Color labelColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _filterTextField(
    TextEditingController controller,
    String hint, {
    required Color textColor,
    required Color placeholderColor,
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor),
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: placeholderColor),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
      ),
    );
  }

  Widget _filterDateField(
    DateTime? value,
    ValueChanged<DateTime?> onPicked, {
    required bool isDarkMode,
    required Color textColor,
    required Color placeholderColor,
    required Color fillColor,
    required Color borderColor,
    required VoidCallback onOpen,
  }) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: TextStyle(
                  color: value == null ? placeholderColor : textColor,
                  fontSize: 14,
                ),
              ),
            ),
            GestureDetector(
              onTap: onOpen,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarPopupMenuEntry extends PopupMenuEntry<DateTime?> {
  final DateTime? initialDate;
  final bool isDarkMode;
  final ValueChanged<DateTime?> onPicked;

  const _CalendarPopupMenuEntry({
    required this.initialDate,
    required this.isDarkMode,
    required this.onPicked,
  });

  @override
  State<_CalendarPopupMenuEntry> createState() =>
      _CalendarPopupMenuEntryState();

  @override
  double get height => 360;

  @override
  bool represents(DateTime? value) => value == initialDate;
}

class _CalendarPopupMenuEntryState extends State<_CalendarPopupMenuEntry> {
  late DateTime _viewMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? now;
    _viewMonth = DateTime(
        _selectedDate?.year ?? now.year, _selectedDate?.month ?? now.month, 1);
  }

  void _goToMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta, 1);
    });
  }

  void _selectDate(DateTime day) {
    setState(() {
      _selectedDate = DateTime(day.year, day.month, day.day);
      _viewMonth = DateTime(day.year, day.month, 1);
    });
    widget.onPicked(_selectedDate);
    Navigator.of(context).pop(_selectedDate);
  }

  void _selectToday() {
    final today = DateTime.now();
    widget.onPicked(today);
    Navigator.of(context).pop(today);
  }

  void _clearSelection() {
    widget.onPicked(null);
    Navigator.of(context).pop(null);
  }

  List<DateTime> _buildDaysInMonth() {
    final firstDayOfMonth = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final start = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    return List.generate(42, (index) => start.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isDarkMode ? const Color(0xFF111827) : Colors.white;
    final panelBorder =
        widget.isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final textColor =
        widget.isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final mutedText =
        widget.isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    final adjacentText =
        widget.isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFFB0B7C3);
    final selectedFill = const Color(0xFF2F80ED);
    final selectedText = Colors.white;

    final days = _buildDaysInMonth();

    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: panelBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _goToMonth(-1),
                icon: Icon(Icons.chevron_left, color: textColor, size: 20),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthName(_viewMonth.month)} ${_viewMonth.year}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _goToMonth(1),
                icon: Icon(Icons.chevron_right, color: textColor, size: 20),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (index) {
              final weekday =
                  ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index];
              return Expanded(
                child: Center(
                  child: Text(
                    weekday,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _viewMonth.month;
              final isSelected = _selectedDate != null &&
                  day.year == _selectedDate!.year &&
                  day.month == _selectedDate!.month &&
                  day.day == _selectedDate!.day;
              final isToday = DateTime.now().year == day.year &&
                  DateTime.now().month == day.month &&
                  DateTime.now().day == day.day;

              return InkWell(
                onTap: () => _selectDate(day),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: const Color(0xFF93C5FD), width: 1)
                        : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected
                          ? selectedText
                          : isCurrentMonth
                              ? textColor
                              : adjacentText,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearSelection,
                child: Text(
                  'Clear',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _selectToday,
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5B5B5B)),
    );
  }
}
