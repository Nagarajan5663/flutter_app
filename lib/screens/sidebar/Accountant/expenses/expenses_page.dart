import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({
    super.key,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final List<ExpenseData> _expenses = [];

  void _openNewExpenseForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NewOperationExpenseDialog(
          onSave: (expense) {
            setState(() {
              _expenses.add(expense);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F6F9),
      child: Stack(
        children: [
          // =========================================================
          // BACKGROUND SHAPES
          // =========================================================

          Positioned(
            left: -250,
            top: 0,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),

          Positioned(
            right: -250,
            top: -100,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),

          // =========================================================
          // MAIN CONTENT
          // =========================================================

          SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===================================================
                // HEADER
                // ===================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Operation Expense',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17395C),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _openNewExpenseForm,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: const Text(
                        'New Operation Expense',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF17395C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 17,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ===================================================
                // TABLE CARD
                // ===================================================

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 350,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE1E5EA),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.03,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: _expenses.isEmpty
                      ? _buildEmptyTable()
                      : _buildExpenseTable(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTable() {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),

        const SizedBox(height: 45),

        const Icon(
          Icons.receipt_long_outlined,
          size: 55,
          color: Color(0xFFB0B8C2),
        ),

        const SizedBox(height: 15),

        const Text(
          'No operation expenses found',
          style: TextStyle(
            color: Color(0xFF777777),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTable() {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),

        ..._expenses.map(
          (expense) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat(
                            'dd-MM-yyyy',
                          ).format(expense.date),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.expenseNumber,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.category,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.paidTo,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.status,
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          'INR ${expense.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF17395C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 64,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFE5E7EB),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: _TableHeaderText('DATE'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('EXPENSE #'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('CATEGORY'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('PAID TO (VENDOR)'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('STATUS'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('AMOUNT'),
          ),

          SizedBox(
            width: 64,
            child: _TableHeaderText('ACTIONS'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// TABLE HEADER
// ===================================================================

class _TableHeaderText extends StatelessWidget {
  final String text;

  const _TableHeaderText(
    this.text,
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF555555),
      ),
    );
  }
}

// ===================================================================
// EXPENSE DATA MODEL
// ===================================================================

class ExpenseData {
  final DateTime date;
  final String expenseNumber;
  final String category;
  final String paidTo;
  final String status;
  final double total;

  ExpenseData({
    required this.date,
    required this.expenseNumber,
    required this.category,
    required this.paidTo,
    required this.status,
    required this.total,
  });
}

// ===================================================================
// NEW OPERATION EXPENSE DIALOG
// ===================================================================

class NewOperationExpenseDialog
    extends StatefulWidget {
  final ValueChanged<ExpenseData> onSave;

  const NewOperationExpenseDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<NewOperationExpenseDialog>
      createState() =>
          _NewOperationExpenseDialogState();
}

class _NewOperationExpenseDialogState
    extends State<NewOperationExpenseDialog> {
  // ================================================================
  // FORM KEY
  // ================================================================

  final _formKey = GlobalKey<FormState>();

  // ================================================================
  // CONTROLLERS
  // ================================================================

  final TextEditingController expenseNumberController =
      TextEditingController(
    text: 'OPEX-1',
  );

  final TextEditingController referenceController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  // ================================================================
  // FORM VALUES
  // ================================================================

  DateTime selectedDate = DateTime.now();

  String? selectedCategory;
  String? selectedPaidTo;
  String? selectedCustomer;

  String selectedTax = '-- No Tax --';

  bool taxInclusive = false;
  bool billable = false;

  // ================================================================
  // DROPDOWN OPTIONS
  // ================================================================

  final List<String> expenseCategories = [
    'Travel',
    'Food & Meals',
    'Office Supplies',
    'Rent',
    'Utilities',
    'Fuel',
    'Marketing',
    'Maintenance',
    'Other',
  ];

  final List<String> paidToOptions = [
    'Vendor',
    'Employee',
    'Other Payee',
  ];

  final List<String> taxOptions = [
    '-- No Tax --',
    'GST 5%',
    'GST 12%',
    'GST 18%',
    'GST 28%',
  ];

  // ================================================================
  // TAX CALCULATION
  // ================================================================

  double get amount {
    return double.tryParse(
          amountController.text.trim(),
        ) ??
        0;
  }

  double get taxRate {
    switch (selectedTax) {
      case 'GST 5%':
        return 5;

      case 'GST 12%':
        return 12;

      case 'GST 18%':
        return 18;

      case 'GST 28%':
        return 28;

      default:
        return 0;
    }
  }

  double get calculatedTax {
    if (taxRate == 0) {
      return 0;
    }

    if (taxInclusive) {
      return amount -
          (amount / (1 + (taxRate / 100)));
    }

    return amount * taxRate / 100;
  }

  double get subTotal {
    if (taxInclusive && taxRate > 0) {
      return amount - calculatedTax;
    }

    return amount;
  }

  double get total {
    if (taxInclusive) {
      return amount;
    }

    return amount + calculatedTax;
  }

  @override
  void dispose() {
    expenseNumberController.dispose();
    referenceController.dispose();
    amountController.dispose();
    remarksController.dispose();

    super.dispose();
  }

  // ================================================================
  // DATE PICKER
  // ================================================================

  Future<void> _selectDate() async {
    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ================================================================
  // SAVE
  // ================================================================

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      _showMessage(
        'Please select an expense category.',
      );
      return;
    }

    widget.onSave(
      ExpenseData(
        date: selectedDate,
        expenseNumber:
            expenseNumberController.text.trim(),
        category: selectedCategory!,
        paidTo: selectedPaidTo ?? 'Not Assigned',
        status: 'Pending',
        total: total,
      ),
    );

    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 720,
          maxHeight: 570,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  10,
                  10,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'New Operation Expense',
                        style: TextStyle(
                          color: Color(0xFF17395C),
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w800,
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

              const Divider(
                height: 1,
                color: Color(0xFFE0E0E0),
              ),

              // =====================================================
              // SCROLLABLE FORM
              // =====================================================

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding:
                      const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // =================================================
                        // ROW 1
                        // =================================================

                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child:
                                  _buildDropdownField(
                                label:
                                    'Expense Category *',
                                value:
                                    selectedCategory,
                                hint:
                                    'Select or type to add...',
                                items:
                                    expenseCategories,
                                onChanged:
                                    (value) {
                                  setState(() {
                                    selectedCategory =
                                        value;
                                  });
                                },
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // ROW 2
                        // =================================================

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Expense # *',
                                controller:
                                    expenseNumberController,
                                readOnly: false,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child:
                                  _buildDropdownField(
                                label:
                                    'Paid To (Vendor)',
                                value:
                                    selectedPaidTo,
                                hint:
                                    'Select or type to search...',
                                items: paidToOptions,
                                onChanged:
                                    (value) {
                                  setState(() {
                                    selectedPaidTo =
                                        value;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildTextField(
                                label: 'Reference #',
                                controller:
                                    referenceController,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        const Divider(
                          color: Color(0xFFE0E0E0),
                        ),

                        const SizedBox(height: 8),

                        // =================================================
                        // AMOUNT + TAX
                        // =================================================

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _buildAmountField(),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child:
                                  _buildDropdownField(
                                label: 'Tax',
                                value: selectedTax,
                                hint: '-- No Tax --',
                                items: taxOptions,
                                onChanged:
                                    (value) {
                                  setState(() {
                                    selectedTax =
                                        value ??
                                            '-- No Tax --';
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 18),

                            SizedBox(
                              width: 170,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value:
                                          taxInclusive,
                                      activeColor:
                                          const Color(
                                        0xFF1D78C9,
                                      ),
                                      onChanged:
                                          (value) {
                                        setState(() {
                                          taxInclusive =
                                              value ??
                                                  false;
                                        });
                                      },
                                    ),

                                    const Expanded(
                                      child: Text(
                                        'Tax Inclusive',
                                        style: TextStyle(
                                          color:
                                              Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // TOTAL SUMMARY
                        // =================================================

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF9FAFB),
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                            border: Border.all(
                              color:
                                  const Color(0xFFDDE1E6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              _buildTotalRow(
                                'Sub-Total',
                                subTotal,
                              ),

                              const SizedBox(height: 7),

                              _buildTotalRow(
                                'Tax',
                                calculatedTax,
                              ),

                              const SizedBox(height: 7),

                              _buildTotalRow(
                                'Total',
                                total,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Divider(
                          color: Color(0xFFE0E0E0),
                        ),

                        const SizedBox(height: 8),

                        // =================================================
                        // BILLABLE
                        // =================================================

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: billable,
                              activeColor:
                                  const Color(0xFF1D78C9),
                              onChanged: (value) {
                                setState(() {
                                  billable =
                                      value ?? false;
                                });
                              },
                            ),

                            const Text(
                              'Billable',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),

                            if (billable) ...[
                              const SizedBox(width: 28),
                              Expanded(
                                child: _buildCustomerField(),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // REMARKS
                        // =================================================

                        const Text(
                          'Remarks',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller:
                              remarksController,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration:
                              _inputDecoration(),
                        ),

                        const SizedBox(height: 10),

                        // =================================================
                        // ATTACH RECEIPTS
                        // =================================================

                        const Text(
                          'Attach Receipts',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          height: 40,
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  const Color(0xFFD7DCE2),
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              7,
                            ),
                          ),
                          child: Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Receipt attachment can be connected to file picker next.',
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    const Text(
                                  'Choose Files',
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Text(
                                'No file chosen',
                                style: TextStyle(
                                  color:
                                      Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =====================================================
              // FOOTER BUTTONS
              // =====================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF747B82),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 11,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            7,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: _saveExpense,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1E78B7),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 11,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            7,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Save Operation Expense',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DATE FIELD
  // ================================================================

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Date *',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat(
                      'dd-MM-yyyy',
                    ).format(selectedDate),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),

                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  // ================================================================
  // AMOUNT FIELD
  // ================================================================

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount *',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: amountController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          style: const TextStyle(
            color: Colors.black,
          ),
          onChanged: (_) {
            setState(() {});
          },
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Amount is required';
            }

            if (double.tryParse(value) ==
                null) {
              return 'Enter valid amount';
            }

            return null;
          },
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildCustomerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          initialValue: selectedCustomer,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          onChanged: (value) {
            selectedCustomer = value;
          },
          decoration: _inputDecoration().copyWith(
            hintText: 'Select or type to search',
            hintStyle: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DROPDOWN
  // ================================================================

  Widget _buildDropdownField({
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
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: Colors.white,

          hint: Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
            ),
          ),

          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),

          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),

          decoration: _inputDecoration(),

          items: items.map(
            (item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }

  // ================================================================
  // TOTAL ROW
  // ================================================================

  Widget _buildTotalRow(
    String label,
    double value, {
    bool isBold = false,
  }) {
    return SizedBox(
      width: 250,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF444444),
                fontSize: isBold ? 17 : 15,
                fontWeight: isBold
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 25),

          SizedBox(
            width: 105,
            child: Text(
              'INR ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: const Color(0xFF17395C),
                fontSize: isBold ? 18 : 15,
                fontWeight: isBold
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // INPUT DECORATION
  // ================================================================

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFF1E78B7),
          width: 1.5,
        ),
      ),
    );
  }
}