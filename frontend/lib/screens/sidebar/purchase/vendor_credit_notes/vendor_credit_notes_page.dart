import 'package:flutter/material.dart';

import '../shared/glass_modal_shell.dart';
import 'vendor_credit_filter.dart';
import 'vendor_credit_model.dart';
import 'vendor_credit_repository.dart';
import 'widgets/add_vendor_credit_dialog.dart';

class VendorCreditNotesPage extends StatefulWidget {
  const VendorCreditNotesPage({super.key});

  @override
  State<VendorCreditNotesPage> createState() => _VendorCreditNotesPageState();
}

class _VendorCreditNotesPageState extends State<VendorCreditNotesPage> {
  final VendorCreditRepository _repository = InMemoryVendorCreditRepository();

  List<VendorCreditModel> _credits = [];
  bool _isLoading = true;

  final vendorController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  String statusFilter = 'All';
  final statusOptions = const ['All', 'Open', 'Closed'];

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  @override
  void dispose() {
    vendorController.dispose();
    super.dispose();
  }

  VendorCreditFilter get _currentFilter => VendorCreditFilter(
        status: statusFilter,
        vendorName: vendorController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadCredits() async {
    setState(() => _isLoading = true);
    final result = await _repository.getVendorCredits(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _credits = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddVendorCredit() async {
    final draft = await showDialog<VendorCreditDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddVendorCreditDialog(),
    );

    if (!mounted || draft == null) return;

    await _repository.addVendorCredit(
      VendorCreditModel(
        creditNoteNumber: draft.creditNoteNumber,
        vendorId: draft.vendorId,
        vendorName: draft.vendorName,
        date: draft.date,
        amount: draft.amount,
        reason: draft.reason,
      ),
    );
    await _loadCredits();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vendor credit note created successfully')),
    );
  }

  Future<void> _deleteCredit(VendorCreditModel credit) async {
    if (credit.id == null) return;
    await _repository.deleteVendorCredit(credit.id!);
    await _loadCredits();
  }

  void _clearFilters() {
    statusFilter = 'All';
    vendorController.clear();
    dateFrom = null;
    dateTo = null;
    _loadCredits();
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
      case 'Closed':
        return const Color(0xFFEDEFF2);
      default: // Open
        return const Color(0xFFE7EEF6);
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'Closed':
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
                    'Vendor Credit Notes',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                GlassButton(
                  onPressed: _openAddVendorCredit,
                  icon: Icons.add,
                  label: 'New Vendor Credit',
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
                            if (value != null) setState(() => statusFilter = value);
                          },
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Vendor Name',
                    child: SizedBox(
                      width: 200,
                      child: _filterTextField(vendorController, 'Vendor name...'),
                    ),
                  ),
                  _filterField(
                    label: 'Date From',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(
                        dateFrom,
                        (d) => setState(() => dateFrom = d),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Date To',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(
                        dateTo,
                        (d) => setState(() => dateTo = d),
                      ),
                    ),
                  ),
                  GlassButton(
                    onPressed: _loadCredits,
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
                            Expanded(flex: 3, child: _HeaderText('VENDOR CREDIT NOTE #')),
                            Expanded(flex: 3, child: _HeaderText('VENDOR NAME')),
                            Expanded(flex: 2, child: _HeaderText('STATUS')),
                            Expanded(flex: 2, child: _HeaderText('AMOUNT')),
                            Expanded(flex: 2, child: _HeaderText('AMOUNT REMAINING')),
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
                      else if (_credits.isEmpty)
                        Container(
                          width: 1080,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No vendor credit notes found. Click "+ New Vendor Credit" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._credits.map((credit) {
                          return Column(
                            children: [
                              Container(
                                width: 1080,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(_fmt(credit.date))),
                                    Expanded(flex: 3, child: Text(credit.creditNoteNumber)),
                                    Expanded(flex: 3, child: Text(credit.vendorName)),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusBg(credit.status),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            credit.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _statusFg(credit.status),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Text('INR ${credit.amount.toStringAsFixed(2)}')),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            'INR ${credit.amountRemaining.toStringAsFixed(2)}')),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deleteCredit(credit),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete vendor credit note',
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
                  );
                },
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