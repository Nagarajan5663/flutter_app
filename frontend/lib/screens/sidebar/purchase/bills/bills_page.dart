import 'package:flutter/material.dart';

import '../shared/glass_modal_shell.dart';
import 'bill_filter.dart';
import 'bill_model.dart';
import 'bill_repository.dart';
import 'widgets/add_bill_dialog.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final BillRepository _repository = InMemoryBillRepository();

  List<BillModel> _bills = [];
  bool _isLoading = true;

  final vendorController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  String statusFilter = 'All';
  final statusOptions = const ['All', 'Draft', 'Open', 'Paid', 'Overdue'];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  @override
  void dispose() {
    vendorController.dispose();
    super.dispose();
  }

  BillFilter get _currentFilter => BillFilter(
        status: statusFilter,
        vendorName: vendorController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    final result = await _repository.getBills(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _bills = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddBill() async {
    final draft = await showDialog<BillModelDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddBillDialog(),
    );

    if (!mounted || draft == null) return;

    final bill = BillModel(
      billNumber: draft.billNumber,
      vendorInvoiceNumber: draft.vendorInvoiceNumber,
      invoiceAttachmentPath: draft.invoiceAttachmentPath,
      vendorId: draft.vendorId,
      vendorName: draft.vendorName,
      purchaseOrderId: draft.purchaseOrderId,
      purchaseOrderNumber: draft.purchaseOrderNumber,
      billDate: draft.billDate,
      dueDate: draft.dueDate,
      items: draft.items,
      taxAmount: draft.taxAmount,
    );

    await _repository.addBill(bill);
    await _loadBills();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill created successfully')),
    );
  }

  Future<void> _deleteBill(BillModel bill) async {
    if (bill.id == null) return;
    await _repository.deleteBill(bill.id!);
    await _loadBills();
  }

  void _clearFilters() {
    statusFilter = 'All';
    vendorController.clear();
    dateFrom = null;
    dateTo = null;
    _loadBills();
  }

  Future<void> _pickDate(DateTime? initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFE3F6E8);
      case 'Overdue':
        return const Color(0xFFF4E3E3);
      case 'Draft':
        return const Color(0xFFEDEFF2);
      default: // Open
        return const Color(0xFFE7EEF6);
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF1E7B34);
      case 'Overdue':
        return const Color(0xFFAB2A2A);
      case 'Draft':
        return const Color(0xFF5B5B5B);
      default: // Open
        return const Color(0xFF123456);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Vendor Bills',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                GlassButton(
                  onPressed: _openAddBill,
                  icon: Icons.add,
                  label: 'New Bill',
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
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: const Color(0xFFD9DEE5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusFilter,
                          isExpanded: true,
                          items: statusOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => statusFilter = value);
                          },
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Vendor Name',
                    child: SizedBox(
                        width: 180, child: _filterTextField(vendorController, 'Vendor name...')),
                  ),
                  _filterField(
                    label: 'Date From',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(dateFrom, (d) => setState(() => dateFrom = d)),
                    ),
                  ),
                  _filterField(
                    label: 'Date To',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(dateTo, (d) => setState(() => dateTo = d)),
                    ),
                  ),
                  GlassButton(
                    onPressed: _loadBills,
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1080,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1080,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: _HeaderText('DATE')),
                            Expanded(flex: 2, child: _HeaderText('BILL #')),
                            Expanded(flex: 3, child: _HeaderText('VENDOR NAME')),
                            Expanded(flex: 2, child: _HeaderText('DUE DATE')),
                            Expanded(flex: 2, child: _HeaderText('STATUS')),
                            Expanded(flex: 2, child: _HeaderText('AMOUNT DUE')),
                            Expanded(flex: 2, child: _HeaderText('TOTAL')),
                            Expanded(flex: 1, child: _HeaderText('ACTIONS')),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFD9DEE5)),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_bills.isEmpty)
                        Container(
                          width: 1080,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No bills found. Click "+ New Bill" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._bills.map((bill) {
                          return Column(
                            children: [
                              Container(
                                width: 1080,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(_fmt(bill.billDate))),
                                    Expanded(flex: 2, child: Text(bill.billNumber)),
                                    Expanded(flex: 3, child: Text(bill.vendorName)),
                                    Expanded(flex: 2, child: Text(_fmt(bill.dueDate))),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusBg(bill.status),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            bill.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _statusFg(bill.status),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Text('INR ${bill.amountDue.toStringAsFixed(2)}')),
                                    Expanded(
                                        flex: 2,
                                        child: Text('INR ${bill.total.toStringAsFixed(2)}')),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deleteBill(bill),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete bill',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFEDEFF2)),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _filterTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF123456), width: 2),
        ),
      ),
    );
  }

  Widget _filterDateField(DateTime? value, ValueChanged<DateTime> onPicked) {
    return GestureDetector(
      onTap: () => _pickDate(value, onPicked),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFD9DEE5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: TextStyle(color: value == null ? Colors.grey : Colors.black, fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5B5B5B)),
    );
  }
}