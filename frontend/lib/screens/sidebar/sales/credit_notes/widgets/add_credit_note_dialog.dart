import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../customer/customer_model.dart';
import '../../customer/customer_repository.dart';
import '../../customer/widgets/add_customer_dialog.dart';
import '../../widgets/sales_dialog_helpers.dart';
import '../../widgets/sales_glass_widgets.dart';
import '../credit_notes_page.dart';

class AddCreditNoteDialog extends StatefulWidget {
  const AddCreditNoteDialog({super.key, required this.creditNoteNumber});

  final String creditNoteNumber;

  @override
  State<AddCreditNoteDialog> createState() => _AddCreditNoteDialogState();
}

class _AddCreditNoteDialogState extends State<AddCreditNoteDialog> {
  static const _usersUrl = 'http://localhost:3000/api/users';
  static const _reasons = [
    'Sales return',
    'Damaged goods',
    'Order cancellation',
    'Pricing adjustment',
    'Overpayment',
    'Other',
  ];

  final CustomerRepository _customerRepository = ApiCustomerRepository();
  late final creditNoteNumberController =
      TextEditingController(text: widget.creditNoteNumber);
  final referenceController = TextEditingController();

  List<CustomerModel> _customers = [];
  List<String> _salespeople = [];
  CustomerModel? _selectedCustomer;
  String? _selectedSalesperson;
  String? _reason;
  DateTime _date = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final results = await Future.wait([
        _customerRepository.getCustomers(),
        _loadSalespeople(),
      ]);
      if (!mounted) return;

      setState(() {
        _customers = results[0] as List<CustomerModel>;
        _salespeople = results[1] as List<String>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<String>> _loadSalespeople() async {
    final response = await http.get(
      Uri.parse(_usersUrl),
      headers: const {'Accept': 'application/json'},
    );
    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode != 200 ||
        decoded is! Map<String, dynamic> ||
        decoded['success'] != true ||
        decoded['data'] is! List) {
      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Failed to load salespeople'
            : 'Invalid salespeople response',
      );
    }

    return (decoded['data'] as List)
        .whereType<Map>()
        .where((user) => user['active'] == true || user['active'] == 1)
        .map((user) => user['email']?.toString() ?? '')
        .where((email) => email.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    creditNoteNumberController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save({required bool submit}) {
    if (_selectedCustomer == null) {
      setState(() => _errorText = 'Please select a customer');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final customer = _selectedCustomer!;
    Navigator.pop(
      context,
      CreditNoteData(
        date: _date,
        creditNoteNumber: widget.creditNoteNumber,
        customerId: customer.id ?? '',
        customerName: customer.customerName,
        referenceNumber: referenceController.text.trim(),
        salesperson: _selectedSalesperson ?? '',
        amount: 0,
        tax: 0,
        items: const [],
        reason: _reason?.trim() ?? '',
        status: submit ? CreditNoteStatus.open : CreditNoteStatus.draft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SalesGlassDialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050, maxHeight: 900),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 26, 30, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'New Credit Note',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123456),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.close, color: Color(0xFF777777)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: salesLabeledField(
                            label: 'Customer Name *',
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownSearch<CustomerModel>(
                                    items: (filter, infiniteScrollProps) =>
                                        _customers,
                                    itemAsString: (customer) =>
                                        customer.customerName,
                                    compareFn: (a, b) => a.id == b.id,
                                    selectedItem: _selectedCustomer,
                                    onChanged: (customer) => setState(
                                      () => _selectedCustomer = customer,
                                    ),
                                    popupProps: const PopupProps.menu(
                                      showSearchBox: true,
                                      menuProps: MenuProps(
                                        align: MenuAlign.bottomStart,
                                      ),
                                    ),
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: salesFieldDecoration(
                                        hint: 'Select or search customer...',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  onPressed: _addCustomer,
                                  tooltip: 'Add customer',
                                  icon: const Icon(
                                    Icons.person_add_alt_1,
                                    color: Color(0xFF168A76),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Reason',
                            child: Autocomplete<String>(
                              initialValue:
                                  TextEditingValue(text: _reason ?? ''),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                final query = textEditingValue.text.trim();
                                if (query.isEmpty) {
                                  return _reasons;
                                }

                                final lowerQuery = query.toLowerCase();
                                final matches = _reasons
                                    .where((reason) => reason
                                        .toLowerCase()
                                        .contains(lowerQuery))
                                    .toList();

                                if (matches.isNotEmpty) {
                                  return matches;
                                }

                                return [query];
                              },
                              onSelected: (value) =>
                                  setState(() => _reason = value),
                              fieldViewBuilder: (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                textEditingController.text = _reason ?? '';

                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onChanged: (value) =>
                                      setState(() => _reason = value),
                                  decoration: salesFieldDecoration(
                                    hint: 'Select or type reason',
                                  ),
                                );
                              },
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
                          child: salesLabeledField(
                            label: 'Credit Note # *',
                            child: InputDecorator(
                              decoration: salesFieldDecoration(),
                              child: Text(
                                creditNoteNumberController.text,
                                style: const TextStyle(
                                  color: Color(0xFF243B4C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Reference #',
                            child: salesTextField(
                              controller: referenceController,
                              hint: 'Optional reference number',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Credit Note Date *',
                            child: salesDateField(
                              value: _date,
                              onTap: _pickDate,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 330,
                      child: salesLabeledField(
                        label: 'Salesperson',
                        child: _dropdown<String>(
                          value: _selectedSalesperson,
                          hint: 'Select salesperson',
                          values: _salespeople,
                          label: (value) => value,
                          onChanged: (value) =>
                              setState(() => _selectedSalesperson = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed:
                              _isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        OutlinedButton(
                          onPressed:
                              _isSaving ? null : () => _save(submit: false),
                          child: const Text('Save as Draft'),
                        ),
                        ElevatedButton(
                          onPressed:
                              _isSaving ? null : () => _save(submit: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF168A76),
                            foregroundColor: Colors.white,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save and Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _addCustomer() async {
    final draft = await showDialog<CustomerModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddCustomerDialog(),
    );
    if (!mounted || draft == null) return;

    try {
      final customer = await _customerRepository.addCustomer(draft);
      if (!mounted) return;
      setState(() {
        _customers.insert(0, customer);
        _selectedCustomer = customer;
        _errorText = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<T> values,
    required String Function(T) label,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x6EFFFFFF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xC7FFFFFF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          style: const TextStyle(color: Color(0xFF243B4C)),
          items: values
              .map((option) => DropdownMenuItem<T>(
                    value: option,
                    child: Text(label(option)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
