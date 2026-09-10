import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =====================================================================
// INVESTMENTS PAGE
// =====================================================================

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({
    super.key,
  });

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  final List<InvestmentData> _investments = [];

  int _investmentCounter = 1;

  void _openNewInvestmentForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NewInvestmentDialog(
          nextNumber: 'INV-$_investmentCounter',
          onSave: (investment) {
            setState(() {
              _investments.add(investment);
              _investmentCounter++;
            });
          },
        );
      },
    );
  }

  void _deleteInvestment(InvestmentData investment) {
    setState(() {
      _investments.remove(investment);
    });
  }

  void _updateStatus(
    InvestmentData investment,
    InvestmentStatus status,
  ) {
    setState(() {
      investment.status = status;
    });
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Investments',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17395C),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _openNewInvestmentForm,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: const Text(
                        'New Investment',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17395C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 17,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
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
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE1E5EA),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: _investments.isEmpty
                      ? _buildEmptyTable()
                      : _buildInvestmentTable(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // EMPTY STATE
  // ==================================================================

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
          Icons.trending_up,
          size: 55,
          color: Color(0xFFB0B8C2),
        ),

        const SizedBox(height: 15),

        const Text(
          'No investments found.',
          style: TextStyle(
            color: Color(0xFF777777),
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 45),
      ],
    );
  }

  // ==================================================================
  // TABLE
  // ==================================================================

  Widget _buildInvestmentTable() {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),

        ..._investments.map(
          (investment) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
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
                          ).format(investment.date),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          investment.investmentNumber,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          investment.category,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          investment.payer.isEmpty
                              ? '-'
                              : investment.payer,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(
                            status: investment.status,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          'INR ${investment.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF17395C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 48,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'active':
                                _updateStatus(
                                  investment,
                                  InvestmentStatus.active,
                                );
                                break;

                              case 'matured':
                                _updateStatus(
                                  investment,
                                  InvestmentStatus.matured,
                                );
                                break;

                              case 'closed':
                                _updateStatus(
                                  investment,
                                  InvestmentStatus.closed,
                                );
                                break;

                              case 'delete':
                                _deleteInvestment(investment);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'active',
                                child: Text('Mark as Active'),
                              ),
                              PopupMenuItem(
                                value: 'matured',
                                child: Text('Mark as Matured'),
                              ),
                              PopupMenuItem(
                                value: 'closed',
                                child: Text('Mark as Closed'),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ];
                          },
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
            child: _TableHeaderText('INVESTMENT #'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('CATEGORY'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('PAYER'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('STATUS'),
          ),

          Expanded(
            child: _TableHeaderText('AMOUNT'),
          ),

          SizedBox(
            width: 48,
            child: _TableHeaderText('ACTIONS'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// TABLE HEADER TEXT
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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF555555),
      ),
    );
  }
}

// ===================================================================
// STATUS BADGE
// ===================================================================

class _StatusBadge extends StatelessWidget {
  final InvestmentStatus status;

  const _StatusBadge({
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case InvestmentStatus.active:
        return const Color(0xFFE3F2FD);
      case InvestmentStatus.matured:
        return const Color(0xFFE6F7EC);
      case InvestmentStatus.closed:
        return const Color(0xFFF1F1F1);
    }
  }

  Color get _textColor {
    switch (status) {
      case InvestmentStatus.active:
        return const Color(0xFF1E78B7);
      case InvestmentStatus.matured:
        return const Color(0xFF1F9254);
      case InvestmentStatus.closed:
        return const Color(0xFF6B7280);
    }
  }

  String get _label {
    switch (status) {
      case InvestmentStatus.active:
        return 'Active';
      case InvestmentStatus.matured:
        return 'Matured';
      case InvestmentStatus.closed:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ===================================================================
// INVESTMENT STATUS
// ===================================================================

enum InvestmentStatus {
  active,
  matured,
  closed,
}

// ===================================================================
// INVESTMENT DATA MODEL
// ===================================================================

class InvestmentData {
  final DateTime date;
  final String investmentNumber;
  final String category;
  final String depositedToAccount;
  final String payer;
  final String referenceNumber;
  final double amount;
  final String tax;
  final bool taxInclusive;
  final double subTotal;
  final double taxAmount;
  final double total;
  final String remarks;
  InvestmentStatus status;

  InvestmentData({
    required this.date,
    required this.investmentNumber,
    required this.category,
    required this.depositedToAccount,
    required this.payer,
    required this.referenceNumber,
    required this.amount,
    required this.tax,
    required this.taxInclusive,
    required this.subTotal,
    required this.taxAmount,
    required this.total,
    required this.remarks,
    this.status = InvestmentStatus.active,
  });
}

// ===================================================================
// NEW INVESTMENT DIALOG
// ===================================================================

class NewInvestmentDialog extends StatefulWidget {
  final String nextNumber;
  final ValueChanged<InvestmentData> onSave;

  const NewInvestmentDialog({
    super.key,
    required this.nextNumber,
    required this.onSave,
  });

  @override
  State<NewInvestmentDialog> createState() =>
      _NewInvestmentDialogState();
}

class _NewInvestmentDialogState extends State<NewInvestmentDialog> {
  // ================================================================
  // FORM KEY
  // ================================================================

  final _formKey = GlobalKey<FormState>();

  // ================================================================
  // CONTROLLERS
  // ================================================================

  late final TextEditingController investmentNumberController =
      TextEditingController(
    text: widget.nextNumber,
  );

  final TextEditingController payerController = TextEditingController();

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
  String? selectedDepositedToAccount;

  String selectedTax = '-- No Tax --';

  bool taxInclusive = false;

  final String _attachedFileName = 'No file chosen';

  // ================================================================
  // DROPDOWN OPTIONS
  // ================================================================

  final List<String> investmentCategories = [
    'Mutual Funds',
    'Fixed Deposit',
    'Stocks',
    'Bonds',
    'Real Estate',
    'Gold',
    'PPF',
    'Recurring Deposit',
    'Other',
  ];

  final List<String> depositedToAccountOptions = [
    'Bank Account',
    'Cash',
    'Demat Account',
    'Corporate Account',
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
      return amount - (amount / (1 + (taxRate / 100)));
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
    investmentNumberController.dispose();
    payerController.dispose();
    referenceController.dispose();
    amountController.dispose();
    remarksController.dispose();

    super.dispose();
  }

  // ================================================================
  // DATE PICKER
  // ================================================================

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
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
  // FILE ATTACHMENT (placeholder - wire to file_picker if needed)
  // ================================================================

  void _chooseFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Document attachment can be connected to a file picker next.',
        ),
      ),
    );
  }

  // ================================================================
  // SAVE
  // ================================================================

  void _saveInvestment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      _showMessage('Please select an investment category.');
      return;
    }

    if (selectedDepositedToAccount == null) {
      _showMessage('Please select a deposited to account.');
      return;
    }

    widget.onSave(
      InvestmentData(
        date: selectedDate,
        investmentNumber: investmentNumberController.text.trim(),
        category: selectedCategory!,
        depositedToAccount: selectedDepositedToAccount!,
        payer: payerController.text.trim(),
        referenceNumber: referenceController.text.trim(),
        amount: amount,
        tax: selectedTax,
        taxInclusive: taxInclusive,
        subTotal: subTotal,
        taxAmount: calculatedTax,
        total: total,
        remarks: remarksController.text.trim(),
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
          maxHeight: 600,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'New Investment',
                        style: TextStyle(
                          color: Color(0xFF17395C),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
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
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =================================================
                        // ROW 1: DATE / INVESTMENT CATEGORY / DEPOSITED TO
                        // =================================================

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDateField(),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildDropdownField(
                                label: 'Investment Category *',
                                value: selectedCategory,
                                hint: 'Select or type to add...',
                                items: investmentCategories,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildDropdownField(
                                label: 'Deposited To Account *',
                                value: selectedDepositedToAccount,
                                hint: 'Select or type to add...',
                                items: depositedToAccountOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDepositedToAccount = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // ROW 2: INVESTMENT # / PAYER / REFERENCE #
                        // =================================================

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Investment # *',
                                controller: investmentNumberController,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildSearchField(
                                label: 'Payer (Customer)',
                                controller: payerController,
                                hint: 'Select or type to search...',
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildTextField(
                                label: 'Reference #',
                                controller: referenceController,
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _buildAmountField(),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildDropdownField(
                                label: 'Tax',
                                value: selectedTax,
                                hint: '-- No Tax --',
                                items: taxOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTax =
                                        value ?? '-- No Tax --';
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 18),

                            SizedBox(
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: taxInclusive,
                                      activeColor:
                                          const Color(0xFF1D78C9),
                                      onChanged: (value) {
                                        setState(() {
                                          taxInclusive =
                                              value ?? false;
                                        });
                                      },
                                    ),

                                    const Expanded(
                                      child: Text(
                                        'Tax Inclusive',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDDE1E6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
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

                        // =================================================
                        // REMARKS
                        // =================================================

                        const Text(
                          'Remarks',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: remarksController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: _inputDecoration(),
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // ATTACH SUPPORTING DOCS
                        // =================================================

                        const Text(
                          'Attach Supporting Docs',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          height: 40,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD7DCE2),
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            children: [
                              OutlinedButton(
                                onPressed: _chooseFile,
                                child: const Text(
                                  'Choose Files',
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                _attachedFileName,
                                style: const TextStyle(
                                  color: Color(0xFF666666),
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
                padding: const EdgeInsets.symmetric(
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF747B82),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: _saveInvestment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E78B7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Save Investment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    DateFormat('dd-MM-yyyy').format(selectedDate),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
  // SEARCH-STYLE FIELD (Payer) - optional, no asterisk / no validator
  // ================================================================

  Widget _buildSearchField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          decoration: _inputDecoration().copyWith(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
            ),
            suffixIcon: const Icon(
              Icons.search,
              size: 18,
              color: Color(0xFF9AA3AD),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // AMOUNT FIELD
  // ================================================================

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          style: const TextStyle(
            color: Colors.black,
          ),
          onChanged: (_) {
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Amount is required';
            }

            if (double.tryParse(value) == null) {
              return 'Enter valid amount';
            }

            return null;
          },
          decoration: _inputDecoration(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w500,
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
                fontWeight:
                    isBold ? FontWeight.w800 : FontWeight.w500,
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

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFF1E78B7),
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}