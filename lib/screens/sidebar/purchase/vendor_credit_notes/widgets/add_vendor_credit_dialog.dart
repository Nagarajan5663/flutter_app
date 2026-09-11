import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../vendors/vendor_model.dart';
import '../../vendors/vendor_repository.dart';
import '../vendor_credit_repository.dart';

class AddVendorCreditDialog extends StatefulWidget {
  const AddVendorCreditDialog({super.key});

  @override
  State<AddVendorCreditDialog> createState() => _AddVendorCreditDialogState();
}

class _AddVendorCreditDialogState extends State<AddVendorCreditDialog> {
  final VendorRepository _vendorRepository = InMemoryVendorRepository();
  final VendorCreditRepository _creditRepository = InMemoryVendorCreditRepository();

  final creditNoteNumberController = TextEditingController();
  final amountController = TextEditingController();
  final reasonController = TextEditingController();

  List<VendorModel> _vendors = [];
  VendorModel? selectedVendor;

  DateTime date = DateTime.now();

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
    final creditNoteNumber = await _creditRepository.nextCreditNoteNumber();

    if (!mounted) return;
    setState(() {
      _vendors = vendors;
      creditNoteNumberController.text = creditNoteNumber;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    creditNoteNumberController.dispose();
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => date = picked);
  }

  void _save() {
    if (selectedVendor == null) {
      setState(() => _errorText = 'Please select a vendor');
      return;
    }
    if (creditNoteNumberController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter a vendor credit note number');
      return;
    }
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final draft = VendorCreditDraft(
      creditNoteNumber: creditNoteNumberController.text.trim(),
      vendorId: selectedVendor!.id ?? '',
      vendorName: selectedVendor!.vendorName,
      date: date,
      amount: amount,
      reason: reasonController.text.trim(),
    );

    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'New Vendor Credit Note',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123456),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Color(0xFFAAAAAA), size: 25),
                        ),
                      ],
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

                    // ROW 1: Vendor Name / Vendor Credit Note #
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
                            label: 'Vendor Credit Note # *',
                            child: _textField(controller: creditNoteNumberController, enabled: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ROW 2: Date / Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledField(
                            label: 'Date *',
                            child: _dateField(value: date, onTap: _pickDate),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Amount *',
                            child: _textField(
                              controller: amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _labeledField(
                      label: 'Reason (Optional)',
                      child: _textField(controller: reasonController, maxLines: 4),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C757D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7DD1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
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
      hintStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF123456), width: 2),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
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
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}

/// Plain data carrier returned by the dialog — VendorCreditNotesPage turns
/// this into a real VendorCreditModel via the repository (assigns the id).
class VendorCreditDraft {
  final String creditNoteNumber;
  final String vendorId;
  final String vendorName;
  final DateTime date;
  final double amount;
  final String reason;

  VendorCreditDraft({
    required this.creditNoteNumber,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    required this.amount,
    this.reason = '',
  });
}