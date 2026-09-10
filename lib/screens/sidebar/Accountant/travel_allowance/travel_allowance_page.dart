import 'package:flutter/material.dart';

class TravelAllowancePage extends StatefulWidget {
  const TravelAllowancePage({super.key});

  @override
  State<TravelAllowancePage> createState() => _TravelAllowancePageState();
}

class _TravelAllowancePageState extends State<TravelAllowancePage> {
  final List<_TravelAllowance> _allowances = [];

  void _openNewTravelAllowance() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _TravelAllowanceDialog(
          onSave: (allowance) {
            setState(() {
              _allowances.add(allowance);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6F8),
      child: Column(
        children: [
          // =========================================================
          // PAGE HEADER
          // =========================================================
          Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Travel Allowance',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF243B53),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _openNewTravelAllowance,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                  ),
                  label: const Text(
                    'New Travel Allowance',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E73BE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // TABLE
          // =========================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFFDDE2E8),
                  ),
                ),
                child: Column(
                  children: [
                    // TABLE HEADER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFDDE2E8),
                          ),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'DATE',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'ALLOWANCE #',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'CATEGORY',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'PAYEE',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'STATUS',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'AMOUNT',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ACTIONS',
                              style: _TableHeaderStyle.style,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _allowances.isEmpty
                          ? const Center(
                              child: Text(
                                'No travel allowances found.',
                                style: TextStyle(
                                  color: Color(0xFF777777),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _allowances.length,
                              separatorBuilder: (_, __) {
                                return const Divider(
                                  height: 1,
                                  color: Color(0xFFE5E7EB),
                                );
                              },
                              itemBuilder: (_, index) {
                                final item = _allowances[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(item.date),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(item.allowanceNumber),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(item.category),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(item.payee),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text('Draft'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'INR ${item.total.toStringAsFixed(2)}',
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.more_vert,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TravelAllowanceDialog extends StatefulWidget {
  final ValueChanged<_TravelAllowance> onSave;

  const _TravelAllowanceDialog({
    required this.onSave,
  });

  @override
  State<_TravelAllowanceDialog> createState() =>
      _TravelAllowanceDialogState();
}

class _TravelAllowanceDialogState
    extends State<_TravelAllowanceDialog> {
  // ===============================================================
  // CONTROLLERS
  // ===============================================================

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _allowanceController =
      TextEditingController(
    text: 'TRAV-1',
  );

  final TextEditingController _referenceController =
      TextEditingController();

  final TextEditingController _fromController =
      TextEditingController();

  final TextEditingController _toController =
      TextEditingController();

  final TextEditingController _kmController =
      TextEditingController();

  final TextEditingController _valueController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _remarksController =
      TextEditingController();

  final TextEditingController _overallRemarksController =
      TextEditingController();

  // ===============================================================
  // VALUES
  // ===============================================================

  String? _expenseCategory;
  String? _paymentAccount;
  String? _payee;
  String _customer = '';

  String _mode = 'Bike';
  String _tax = 'No Tax';

  bool _taxInclusive = false;
  bool _billableToCustomer = false;

  final List<_TravelDetailRow> _travelRows = [];

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _dateController.text =
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }

  // ===============================================================

  Future<void> _pickDate(
    TextEditingController controller,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      controller.text =
          '${selectedDate.day.toString().padLeft(2, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.year}';
    });
  }

  // ===============================================================
  // ADD ROW
  // ===============================================================

  void _addTravelRow() {
    setState(() {
      _travelRows.add(
        _TravelDetailRow(),
      );
    });
  }

  // ===============================================================
  // REMOVE ROW
  // ===============================================================

  void _removeTravelRow(int index) {
    setState(() {
      _travelRows.removeAt(index);
    });
  }

  // ===============================================================
  // TOTAL
  // ===============================================================

  double get _total {
    double total = 0;

    for (final row in _travelRows) {
      total += row.amount;
    }

    if (_amountController.text.isNotEmpty) {
      total += double.tryParse(
            _amountController.text,
          ) ??
          0;
    }

    return total;
  }

  // ===============================================================
  // SAVE
  // ===============================================================

  void _save() {
    final allowance = _TravelAllowance(
      date: _dateController.text,
      allowanceNumber: _allowanceController.text,
      category: _expenseCategory ?? '-',
      payee: _payee ?? '-',
      total: _total,
    );

    widget.onSave(allowance);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Travel allowance saved successfully.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _allowanceController.dispose();
    _referenceController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _kmController.dispose();
    _valueController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    _overallRemarksController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.70,
        child: Column(
          children: [
            // =======================================================
            // HEADER
            // =======================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                10,
                10,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'New Travel Allowance',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            // =======================================================
            // SCROLLABLE FORM
            // =======================================================

            Expanded(
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // =================================================
                    // TOP ROW
                    // =================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _dateField(
                            label: 'Date *',
                            controller: _dateController,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _dropdownField(
                            label: 'Expense Category *',
                            value: _expenseCategory,
                            hint: 'Select or type to search...',
                            items: const [
                              'Travel',
                              'Fuel',
                              'Food',
                              'Accommodation',
                              'Other',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _expenseCategory = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _dropdownField(
                            label: 'Payment Account *',
                            value: _paymentAccount,
                            hint: 'Select or type to search...',
                            items: const [
                              'Cash',
                              'Bank Account',
                              'Credit Card',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _paymentAccount = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            label: 'Allowance #',
                            controller:
                                _allowanceController,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _dropdownField(
                            label: 'Payee *',
                            value: _payee,
                            hint: 'Select or type to search...',
                            items: const [
                              'Employee',
                              'Vendor',
                              'Other',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _payee = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _textField(
                            label: 'Reference #',
                            controller:
                                _referenceController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // TRAVEL DETAILS
                    // =================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Travel Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    _buildTravelTable(),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _addTravelRow,
                        icon: const Icon(
                          Icons.add,
                          size: 15,
                        ),
                        label: const Text(
                          'Add Row',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF20A464),
                          side: const BorderSide(
                            color: Color(0xFF20A464),
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // =================================================
                    // TAX
                    // =================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tax (Applied to Total)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _tax,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            decoration: _inputDecoration(),
                            items: const [
                              DropdownMenuItem(
                                value: 'No Tax',
                                child: Text(
                                  '-- No Tax --',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'GST 5%',
                                child: Text(
                                  'GST 5%',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'GST 12%',
                                child: Text(
                                  'GST 12%',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'GST 18%',
                                child: Text(
                                  'GST 18%',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                _tax = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _taxInclusive,
                                onChanged: (value) {
                                  setState(() {
                                    _taxInclusive =
                                        value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Tax Inclusive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // TOTALS
                    // =================================================

                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 330,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF8F9FA),
                          borderRadius:
                              BorderRadius.circular(3),
                          border: Border.all(
                            color:
                                const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          children: [
                            _totalRow(
                              'Sub-Total',
                              'INR ${_total.toStringAsFixed(2)}',
                              false,
                            ),

                            const SizedBox(height: 8),

                            _totalRow(
                              'Tax',
                              'INR 0.00',
                              false,
                            ),

                            const Divider(),

                            _totalRow(
                              'Total',
                              'INR ${_total.toStringAsFixed(2)}',
                              true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // BILLABLE
                    // =================================================

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _billableToCustomer,
                          onChanged: (value) {
                            setState(() {
                              _billableToCustomer = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Billable to Customer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        if (_billableToCustomer) ...[
                          const SizedBox(width: 28),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Customer',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: _customer,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                  onChanged: (value) {
                                    _customer = value;
                                  },
                                  decoration:
                                      _inputDecoration().copyWith(
                                    hintText:
                                        'Select or type to search...',
                                    hintStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // =================================================
                    // OVERALL REMARKS
                    // =================================================

                    _textField(
                      label: 'Remarks (Overall)',
                      controller:
                          _overallRemarksController,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // ATTACH FILE
                    // =================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Attach Supporting Docs',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      width: double.infinity,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFD8DDE3),
                        ),
                        borderRadius:
                            BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color:
                                      Color(0xFFD8DDE3),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Choose Files',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'No file chosen',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =======================================================
            // FOOTER BUTTONS
            // =======================================================

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF555555),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1E73BE),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                    ),
                    child: const Text(
                      'Save Travel Allowance',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // TRAVEL TABLE
  // ===============================================================

  Widget _buildTravelTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            border: Border.all(
              color: const Color(0xFFE1E5E9),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 14,
                child: Text('Date *'),
              ),
              Expanded(
                flex: 12,
                child: Text('Mode *'),
              ),
              Expanded(
                flex: 12,
                child: Text('From'),
              ),
              Expanded(
                flex: 12,
                child: Text('To'),
              ),
              Expanded(
                flex: 7,
                child: Text('KM'),
              ),
              Expanded(
                flex: 7,
                child: Text('Value'),
              ),
              Expanded(
                flex: 10,
                child: Text('Amount *'),
              ),
              Expanded(
                flex: 13,
                child: Text('Remarks'),
              ),
              SizedBox(width: 30),
            ],
          ),
        ),

        _buildMainTravelRow(),

        ...List.generate(
          _travelRows.length,
          (index) {
            return _buildAdditionalTravelRow(
              index,
              _travelRows[index],
            );
          },
        ),
      ],
    );
  }

  // ===============================================================
  // MAIN ROW
  // ===============================================================

  Widget _buildMainTravelRow() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE1E5E9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 14,
            child: _smallDateField(
              _dateController,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 12,
            child: _smallModeDropdown(),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 12,
            child: _smallTextField(
              _fromController,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 12,
            child: _smallTextField(
              _toController,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 7,
            child: _smallTextField(
              _kmController,
              number: true,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 7,
            child: _smallTextField(
              _valueController,
              number: true,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 10,
            child: _smallTextField(
              _amountController,
              number: true,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 13,
            child: _smallTextField(
              _remarksController,
            ),
          ),

          const SizedBox(width: 5),

          const SizedBox(
            width: 30,
            child: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ADDITIONAL ROW
  // ===============================================================

  Widget _buildAdditionalTravelRow(
    int index,
    _TravelDetailRow row,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE1E5E9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 14,
            child: _smallDateField(
              row.dateController,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 12,
            child: DropdownButtonFormField<String>(
              initialValue: row.mode,
              isDense: true,
              decoration: _smallDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'Bike',
                  child: Text('Bike'),
                ),
                DropdownMenuItem(
                  value: 'Car',
                  child: Text('Car'),
                ),
                DropdownMenuItem(
                  value: 'Bus',
                  child: Text('Bus'),
                ),
                DropdownMenuItem(
                  value: 'Train',
                  child: Text('Train'),
                ),
                DropdownMenuItem(
                  value: 'Flight',
                  child: Text('Flight'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  row.mode = value ?? 'Bike';
                });
              },
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 12,
            child: _smallTextField(
              row.fromController,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 12,
            child: _smallTextField(
              row.toController,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 7,
            child: _smallTextField(
              row.kmController,
              number: true,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 7,
            child: _smallTextField(
              row.valueController,
              number: true,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 10,
            child: _smallTextField(
              row.amountController,
              number: true,
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 13,
            child: _smallTextField(
              row.remarksController,
            ),
          ),

          const SizedBox(width: 5),

          SizedBox(
            width: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _removeTravelRow(index);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SMALL DATE FIELD
  // ===============================================================

  Widget _smallDateField(
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.black,
      ),
      decoration: _smallDecoration().copyWith(
        suffixIcon: IconButton(
          iconSize: 14,
          onPressed: () {
            _pickDate(controller);
          },
          icon: const Icon(
            Icons.calendar_today_outlined,
          ),
        ),
      ),
      onTap: () {
        _pickDate(controller);
      },
    );
  }

  // ===============================================================
  // MODE DROPDOWN
  // ===============================================================

  Widget _smallModeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _mode,
      isDense: true,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 10,
      ),
      decoration: _smallDecoration(),
      items: const [
        DropdownMenuItem(
          value: 'Bike',
          child: Text('Bike'),
        ),
        DropdownMenuItem(
          value: 'Car',
          child: Text('Car'),
        ),
        DropdownMenuItem(
          value: 'Bus',
          child: Text('Bus'),
        ),
        DropdownMenuItem(
          value: 'Train',
          child: Text('Train'),
        ),
        DropdownMenuItem(
          value: 'Flight',
          child: Text('Flight'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _mode = value ?? 'Bike';
        });
      },
    );
  }

  // ===============================================================
  // SMALL TEXT FIELD
  // ===============================================================

  Widget _smallTextField(
    TextEditingController controller, {
    bool number = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(
              decimal: true,
            )
          : TextInputType.text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.black,
      ),
      decoration: _smallDecoration(),
      onChanged: onChanged,
    );
  }

  // ===============================================================
  // NORMAL DATE FIELD
  // ===============================================================

  Widget _dateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _labelStyle,
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: _inputDecoration().copyWith(
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today_outlined,
                size: 16,
              ),
              onPressed: () {
                _pickDate(controller);
              },
            ),
          ),
          onTap: () {
            _pickDate(controller);
          },
        ),
      ],
    );
  }

  // ===============================================================
  // NORMAL TEXT FIELD
  // ===============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _labelStyle,
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  // ===============================================================
  // NORMAL DROPDOWN
  // ===============================================================

  Widget _dropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _labelStyle,
        ),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          initialValue: value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          decoration: _inputDecoration(),
          hint: Text(
            hint,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF999999),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ===============================================================
  // TOTAL ROW
  // ===============================================================

  Widget _totalRow(
    String title,
    String amount,
    bool bold,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),

        const SizedBox(width: 25),

        SizedBox(
          width: 100,
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // INPUT DECORATION
  // ===============================================================

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintStyle: const TextStyle(
        color: Colors.black54,
      ),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(3),
        borderSide: const BorderSide(
          color: Color(0xFFD6DCE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(3),
        borderSide: const BorderSide(
          color: Color(0xFFD6DCE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(3),
        borderSide: const BorderSide(
          color: Color(0xFF2C73B9),
        ),
      ),
    );
  }

  InputDecoration _smallDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(2),
        borderSide: const BorderSide(
          color: Color(0xFFD6DCE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(2),
        borderSide: const BorderSide(
          color: Color(0xFFD6DCE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(2),
        borderSide: const BorderSide(
          color: Color(0xFF2C73B9),
        ),
      ),
    );
  }

  static const TextStyle _labelStyle =
      TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
}

// ===================================================================
// TRAVEL ROW MODEL
// ===================================================================

class _TravelDetailRow {
  final TextEditingController dateController =
      TextEditingController();

  final TextEditingController fromController =
      TextEditingController();

  final TextEditingController toController =
      TextEditingController();

  final TextEditingController kmController =
      TextEditingController();

  final TextEditingController valueController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  String mode = 'Bike';

  double get amount {
    return double.tryParse(
          amountController.text,
        ) ??
        0;
  }
}

// ===================================================================
// ALLOWANCE MODEL
// ===================================================================

class _TravelAllowance {
  final String date;
  final String allowanceNumber;
  final String category;
  final String payee;
  final double total;

  const _TravelAllowance({
    required this.date,
    required this.allowanceNumber,
    required this.category,
    required this.payee,
    required this.total,
  });
}

// ===================================================================
// TABLE HEADER STYLE
// ===================================================================

class _TableHeaderStyle {
  static const TextStyle style =
      TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Color(0xFF555555),
  );
}