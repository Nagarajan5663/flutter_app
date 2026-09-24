import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../shared/glass_modal_shell.dart';
import '../../vendors/vendor_model.dart';
import '../../vendors/vendor_repository.dart';
import '../purchase_order_item_model.dart';
import '../purchase_order_model.dart';
import '../purchase_order_repository.dart';

class _ItemRow {
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final qtyController = TextEditingController(text: '1');
  final rateController = TextEditingController(text: '0.00');

  double get amount {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;
    return qty * rate;
  }

  void dispose() {
    itemNameController.dispose();
    descriptionController.dispose();
    qtyController.dispose();
    rateController.dispose();
  }
}

class AddPurchaseOrderDialog extends StatefulWidget {
  const AddPurchaseOrderDialog({super.key});

  @override
  State<AddPurchaseOrderDialog> createState() => _AddPurchaseOrderDialogState();
}

class _AddPurchaseOrderDialogState extends State<AddPurchaseOrderDialog> {
  final VendorRepository _vendorRepository = InMemoryVendorRepository();
  final PurchaseOrderRepository _orderRepository = InMemoryPurchaseOrderRepository();

  final poNumberController = TextEditingController();
  final referenceNumberController = TextEditingController();

  List<VendorModel> _vendors = [];
  VendorModel? selectedVendor;

  DateTime date = DateTime.now();
  DateTime? deliveryExpectedDate;
  DateTime? dueDate;

  final List<String> paymentTermsOptions = const [
    '100% Advance',
    '50% Advance, 50% on Delivery',
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
  ];
  String paymentTerms = '100% Advance';

  final List<_ItemRow> rows = [_ItemRow()];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final vendors = await _vendorRepository.getVendors();
    final poNumber = await _orderRepository.nextPoNumber();

    if (!mounted) return;
    setState(() {
      _vendors = vendors;
      poNumberController.text = poNumber;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    poNumberController.dispose();
    referenceNumberController.dispose();
    for (final row in rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => rows.add(_ItemRow()));
  }

  void _removeRow(int index) {
    if (rows.length == 1) return;
    setState(() {
      rows[index].dispose();
      rows.removeAt(index);
    });
  }

  double get _subTotal => rows.fold(0.0, (sum, row) => sum + row.amount);

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  void _saveOrder() {
    if (selectedVendor == null) {
      setState(() => _errorText = 'Please select a vendor');
      return;
    }
    if (poNumberController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter a purchase order number');
      return;
    }

    final items = rows
        .where((row) => row.itemNameController.text.trim().isNotEmpty)
        .map((row) => PurchaseOrderItemModel(
              itemName: row.itemNameController.text.trim(),
              description: row.descriptionController.text.trim(),
              qty: double.tryParse(row.qtyController.text) ?? 0,
              rate: double.tryParse(row.rateController.text) ?? 0,
            ))
        .toList();

    if (items.isEmpty) {
      setState(() => _errorText = 'Please add at least one item');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final order = PurchaseOrderModel(
      poNumber: poNumberController.text.trim(),
      vendorId: selectedVendor!.id ?? '',
      vendorName: selectedVendor!.vendorName,
      date: date,
      deliveryExpectedDate: deliveryExpectedDate,
      paymentTerms: paymentTerms,
      dueDate: dueDate,
      referenceNumber: referenceNumberController.text.trim(),
      items: items,
    );

    Navigator.pop(context, order);
  }

  @override
  Widget build(BuildContext context) {
    return GlassModalShell(
      maxWidth: 800,
      maxHeight: 820,
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(60),
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassDialogHeader(
                    title: 'New Purchase Order',
                    icon: Icons.shopping_cart_outlined,
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),

                    if (_errorText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4E3E3),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(color: Color(0xFFAB2A2A)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // TOP ROW: Vendor / PO# / Date / Delivery Expected Date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledField(
                            label: 'Vendor Name *',
                            child: DropdownSearch<VendorModel>(
                              items: (filter, infiniteScrollProps) => _vendors,
                              itemAsString: (v) => v.vendorName,
                              compareFn: (a, b) => a.id == b.id,
                              selectedItem: selectedVendor,
                              onChanged: (v) => setState(() => selectedVendor = v),
                              popupProps: const PopupProps.menu(showSearchBox: true),
                              decoratorProps: DropDownDecoratorProps(
                                decoration: _fieldDecoration(hint: 'Select or type to search...'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Purchase Order # *',
                            child: _textField(controller: poNumberController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledField(
                            label: 'Date *',
                            child: _dateField(
                              value: date,
                              onTap: () => _pickDate(
                                initial: date,
                                onPicked: (d) => setState(() => date = d),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Delivery Expected Date',
                            child: _dateField(
                              value: deliveryExpectedDate,
                              onTap: () => _pickDate(
                                initial: deliveryExpectedDate,
                                onPicked: (d) => setState(() => deliveryExpectedDate = d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledField(
                            label: 'Payment Terms',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: const Color(0xFFD9DEE5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: paymentTerms,
                                  isExpanded: true,
                                  items: paymentTermsOptions
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => paymentTerms = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Due Date',
                            child: _dateField(
                              value: dueDate,
                              onTap: () => _pickDate(
                                initial: dueDate,
                                onPicked: (d) => setState(() => dueDate = d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _labeledField(
                      label: 'Reference # (optional)',
                      child: _textField(controller: referenceNumberController),
                    ),
                    const SizedBox(height: 24),

                    // ITEM DETAILS TABLE
                    const Text(
                      'Item Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D4147),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Expanded(flex: 4, child: _SmallHeader('ITEM / DESCRIPTION')),
                        Expanded(flex: 2, child: _SmallHeader('QTY')),
                        Expanded(flex: 2, child: _SmallHeader('RATE')),
                        Expanded(flex: 2, child: _SmallHeader('AMOUNT')),
                        SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ...rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _textField(
                                    controller: row.itemNameController,
                                    hint: 'Item name...',
                                  ),
                                  const SizedBox(height: 6),
                                  _textField(
                                    controller: row.descriptionController,
                                    hint: 'Description',
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.qtyController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.rateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: GlassSurface.fill(emphasized: true),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(row.amount.toStringAsFixed(2)),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: IconButton(
                                onPressed: () => _removeRow(index),
                                icon: const Icon(Icons.close, color: Color(0xFFAB2A2A), size: 18),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    TextButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Row'),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7DD1)),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Sub Total: ${_subTotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text(
                            'Total: INR ${_subTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.close,
                        label: 'Cancel',
                        primary: false,
                      ),
                      const SizedBox(width: 16),
                      GlassButton(
                        onPressed: _isSaving ? null : _saveOrder,
                        icon: Icons.save,
                        label: 'Save Purchase Order',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3D4147),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: GlassSurface.fill(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: GlassSurface.border()),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: GlassSurface.border(focused: true), width: 2),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: _fieldDecoration(hint: hint),
    );
  }

  Widget _dateField({required DateTime? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: GlassSurface.fill(),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: GlassSurface.border()),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: TextStyle(color: value == null ? Colors.grey : Colors.black),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}

class _SmallHeader extends StatelessWidget {
  final String text;
  const _SmallHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5B5B5B)),
    );
  }
}