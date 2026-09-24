import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';

import '../../shared/glass_modal_shell.dart';
import '../../purchase_orders/purchase_order_item_model.dart';
import '../../vendors/vendor_model.dart';
import '../../vendors/vendor_repository.dart';
import '../bill_repository.dart';

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

class AddBillDialog extends StatefulWidget {
  const AddBillDialog({super.key});

  @override
  State<AddBillDialog> createState() => _AddBillDialogState();
}

class _AddBillDialogState extends State<AddBillDialog> {
  final VendorRepository _vendorRepository = InMemoryVendorRepository();
  final BillRepository _billRepository = InMemoryBillRepository();

  final billNumberController = TextEditingController();
  final vendorInvoiceController = TextEditingController();
  final taxController = TextEditingController(text: '0.00');

  List<VendorModel> _vendors = [];
  VendorModel? selectedVendor;

  DateTime billDate = DateTime.now();
  DateTime? dueDate;

  String? _attachedFileName;

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
    final billNumber = await _billRepository.nextBillNumber();

    if (!mounted) return;
    setState(() {
      _vendors = vendors;
      billNumberController.text = billNumber;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    billNumberController.dispose();
    vendorInvoiceController.dispose();
    taxController.dispose();
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
  double get _tax => double.tryParse(taxController.text) ?? 0;
  double get _total => _subTotal + _tax;

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

  Future<void> _pickInvoiceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _attachedFileName = result.files.single.name);
  }

  void _saveBill() {
    if (selectedVendor == null) {
      setState(() => _errorText = 'Please select a vendor');
      return;
    }
    if (billNumberController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter a bill number');
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

    final bill = BillModelDraft(
      billNumber: billNumberController.text.trim(),
      vendorInvoiceNumber: vendorInvoiceController.text.trim(),
      invoiceAttachmentPath: _attachedFileName,
      vendorId: selectedVendor!.id ?? '',
      vendorName: selectedVendor!.vendorName,
      billDate: billDate,
      dueDate: dueDate,
      items: items,
      taxAmount: _tax,
    );

    Navigator.pop(context, bill);
  }

  @override
  Widget build(BuildContext context) {
    return GlassModalShell(
      maxWidth: 900,
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
                    title: 'New Bill',
                    icon: Icons.receipt_long_outlined,
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
                        child: Text(_errorText!, style: const TextStyle(color: Color(0xFFAB2A2A))),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ROW 1: Vendor Name / Bill # / Vendor Invoice # / Date
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledField(
                            label: 'Bill # *',
                            child: _textField(controller: billNumberController, enabled: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledField(
                            label: 'Vendor Invoice #',
                            child: _textField(controller: vendorInvoiceController),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledField(
                            label: 'Date *',
                            child: _dateField(
                              value: billDate,
                              onTap: () => _pickDate(
                                initial: billDate,
                                onPicked: (d) => setState(() => billDate = d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ROW 2: Due Date / Attach Invoice
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledField(
                            label: 'Attach Invoice',
                            child: Row(
                              children: [
                                OutlinedButton(
                                  onPressed: _pickInvoiceFile,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    side: const BorderSide(color: Color(0xFFD9DEE5)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  child: const Text('Choose File'),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _attachedFileName ?? 'No file chosen',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF5B5B5B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Item Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3D4147)),
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
                                  _textField(controller: row.itemNameController, hint: 'Select or type to search...'),
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
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.rateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                    // SUB TOTAL / TAX / TOTAL
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sub Total', style: TextStyle(color: Color(0xFF5B5B5B))),
                                Text('INR ${_subTotal.toStringAsFixed(2)}'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Tax', style: TextStyle(color: Color(0xFF5B5B5B))),
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: taxController,
                                    textAlign: TextAlign.right,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      prefixText: 'INR ',
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      filled: true,
                                      fillColor: GlassSurface.fill(),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: BorderSide(color: GlassSurface.border()),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: Color(0xFFD9DEE5)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  'INR ${_total.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                        onPressed: _isSaving ? null : _saveBill,
                        icon: Icons.save,
                        label: 'Save Bill',
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3D4147))),
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
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
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

/// Plain data carrier returned by the dialog — BillsPage turns this into
/// a real BillModel via the repository (which assigns the id).
class BillModelDraft {
  final String billNumber;
  final String vendorInvoiceNumber;
  final String? invoiceAttachmentPath;
  final String vendorId;
  final String vendorName;
  final String? purchaseOrderId;
  final String? purchaseOrderNumber;
  final DateTime billDate;
  final DateTime? dueDate;
  final List<PurchaseOrderItemModel> items;
  final double taxAmount;

  BillModelDraft({
    required this.billNumber,
    this.vendorInvoiceNumber = '',
    this.invoiceAttachmentPath,
    required this.vendorId,
    required this.vendorName,
    this.purchaseOrderId,
    this.purchaseOrderNumber,
    required this.billDate,
    this.dueDate,
    required this.items,
    this.taxAmount = 0,
  });
}