import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/accountant_glass_widgets.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({
    super.key,
  });

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final List<_LoanData> loans = [];

  // ================================================================
  // OPEN NEW LOAN
  // ================================================================

  void _openNewLoanDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x9A12202C),
      builder: (context) {
        return _NewLoanDialog(
          onSave: (loan) {
            setState(() {
              loans.add(loan);
            });
          },
        );
      },
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return AccountantGlassBackground(
      child: Column(
        children: [
          // ==========================================================
          // PAGE HEADER
          // ==========================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              28,
              25,
              28,
              18,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Loans Received',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17395C),
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _openNewLoanDialog,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text(
                    'New Loan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF1F8BCB,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // LOANS TABLE
          // ==========================================================

          Expanded(
            child: AccountantGlassHoverCard(
              margin: const EdgeInsets.fromLTRB(
                28,
                0,
                28,
                28,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(
                  12,
                ),
                border: Border.all(
                  color: const Color(0xFFE2E7EC),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  _buildTableHeader(),

                  Expanded(
                    child: loans.isEmpty
                        ? _buildEmptyRow()
                        : ListView.builder(
                            itemCount: loans.length,
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              return _buildLoanRow(
                                loans[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TABLE CELL
  // ================================================================

  Widget _tableCell({
    required Widget child,
    required int flex,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: child,
      ),
    );
  }

  // ================================================================
  // TABLE HEADER
  // ================================================================

  Widget _buildTableHeader() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      color: Color(0xFF555555),
    );

    Widget headerText(
      String text,
    ) {
      return Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: headerStyle,
      );
    }

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF1),
          ),
        ),
      ),
      child: Row(
        children: [
          // DATE
          _tableCell(
            flex: 12,
            child: headerText(
              'DATE',
            ),
          ),

          // LOAN #
          _tableCell(
            flex: 13,
            child: headerText(
              'LOAN #',
            ),
          ),

          // LENDER
          _tableCell(
            flex: 18,
            child: headerText(
              'LENDER',
            ),
          ),

          // PRINCIPAL
          _tableCell(
            flex: 15,
            child: headerText(
              'PRINCIPAL',
            ),
          ),

          // REPAYMENT
          _tableCell(
            flex: 15,
            child: headerText(
              'REPAYMENT',
            ),
          ),

          // STATUS
          _tableCell(
            flex: 12,
            child: headerText(
              'STATUS',
            ),
          ),

          // ACTIONS
          _tableCell(
            flex: 13,
            child: headerText(
              'ACTIONS',
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // EMPTY ROW
  // ================================================================

  Widget _buildEmptyRow() {
    return const SizedBox.expand();
  }

  // ================================================================
  // LOAN ROW
  // ================================================================

  Widget _buildLoanRow(
    _LoanData loan,
  ) {
    const valueStyle = TextStyle(
      color: Color(0xFF34495E),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    Widget valueText(
      String text,
    ) {
      return Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: valueStyle,
      );
    }

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF1),
          ),
        ),
      ),
      child: Row(
        children: [
          // DATE
          _tableCell(
            flex: 12,
            child: valueText(
              loan.date,
            ),
          ),

          // LOAN NUMBER
          _tableCell(
            flex: 13,
            child: valueText(
              loan.loanNumber,
            ),
          ),

          // LENDER
          _tableCell(
            flex: 18,
            child: valueText(
              loan.lender,
            ),
          ),

          // PRINCIPAL
          _tableCell(
            flex: 15,
            child: valueText(
              '₹ ${loan.principal}',
            ),
          ),

          // REPAYMENT / EMI
          _tableCell(
            flex: 15,
            child: valueText(
              '₹ ${loan.emi}',
            ),
          ),

          // STATUS
          _tableCell(
            flex: 12,
            child: valueText(
              '-',
            ),
          ),

          // ACTIONS
          _tableCell(
            flex: 13,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  onPressed: () {
                    // Edit logic can remain connected here.
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: Color(0xFF17395C),
                  ),
                ),

                const SizedBox(
                  width: 4,
                ),

                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      loans.remove(
                        loan,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: Color(0xFFD9534F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// NEW LOAN DIALOG
// =====================================================================

class _NewLoanDialog extends StatefulWidget {
  final ValueChanged<_LoanData> onSave;

  const _NewLoanDialog({
    required this.onSave,
  });

  @override
  State<_NewLoanDialog> createState() =>
      _NewLoanDialogState();
}

class _NewLoanDialogState
    extends State<_NewLoanDialog> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _lenderController =
      TextEditingController();

  final TextEditingController _accountController =
      TextEditingController();

  final TextEditingController _loanNumberController =
      TextEditingController(
    text: 'LOAN-11',
  );

  final TextEditingController _referenceController =
      TextEditingController();

  final TextEditingController _principalController =
      TextEditingController();

  final TextEditingController _interestController =
      TextEditingController();

  final TextEditingController _termController =
      TextEditingController();

  final TextEditingController _emiController =
      TextEditingController(
    text: '0.00',
  );

  final TextEditingController _remarksController =
      TextEditingController();

  String _selectedLoanType =
      'EMI (Monthly Repayment)';

  String _selectedFileName =
      'No file chosen';

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _dateController.text =
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';

    _principalController.addListener(
      _calculateEmi,
    );

    _interestController.addListener(
      _calculateEmi,
    );

    _termController.addListener(
      _calculateEmi,
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _dateController.dispose();
    _lenderController.dispose();
    _accountController.dispose();
    _loanNumberController.dispose();
    _referenceController.dispose();
    _principalController.dispose();
    _interestController.dispose();
    _termController.dispose();
    _emiController.dispose();
    _remarksController.dispose();

    super.dispose();
  }

  // ==========================================================
  // EMI CALCULATION
  // ==========================================================

  void _calculateEmi() {
    final principal =
        double.tryParse(
          _principalController.text,
        ) ??
        0;

    final annualInterest =
        double.tryParse(
          _interestController.text,
        ) ??
        0;

    final months =
        int.tryParse(
          _termController.text,
        ) ??
        0;

    if (principal <= 0 || months <= 0) {
      _emiController.text = '0.00';
      return;
    }

    final monthlyRate =
        annualInterest / 12 / 100;

    double emi;

    if (monthlyRate == 0) {
      emi = principal / months;
    } else {
      final power = pow(
        1 + monthlyRate,
        months,
      );

      emi =
          principal *
          monthlyRate *
          power /
          (power - 1);
    }

    _emiController.text =
        emi.toStringAsFixed(
      2,
    );
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> _selectDate() async {
    final selectedDate =
        await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(
        2000,
      ),
      lastDate: DateTime(
        2100,
      ),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _dateController.text =
          '${selectedDate.day.toString().padLeft(2, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.year}';
    });
  }

  // ==========================================================
  // SAVE LOAN
  // ==========================================================

  void _saveLoan() {
    if (_lenderController.text.trim().isEmpty ||
        _principalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill the required fields.',
          ),
        ),
      );

      return;
    }

    final loan = _LoanData(
      date: _dateController.text,
      lender: _lenderController.text.trim(),
      account: _accountController.text.trim(),
      loanNumber:
          _loanNumberController.text.trim(),
      reference:
          _referenceController.text.trim(),
      loanType: _selectedLoanType,
      principal:
          _principalController.text.trim(),
      interestRate:
          _interestController.text.trim(),
      loanTerm:
          _termController.text.trim(),
      emi: _emiController.text,
      remarks:
          _remarksController.text.trim(),
    );

    widget.onSave(
      loan,
    );

    Navigator.pop(
      context,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final dialogWidth =
        screenWidth > 1000
        ? 720.0
        : screenWidth * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(
        20,
      ),
      child: SizedBox(
        width: dialogWidth,
        child: AccountantGlassDialogCard(
          constraints: const BoxConstraints(
            maxHeight: 780,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              _buildHeader(),

              const Divider(
                height: 1,
              ),

              // ==================================================
              // FORM
              // ==================================================

              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      18,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // ROW 1
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                label:
                                    'Date of Loan *',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: _buildTextField(
                                label:
                                    'Lender (From) *',
                                controller:
                                    _lenderController,
                                hint:
                                    'Select or type to add...',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: _buildTextField(
                                label:
                                    'Deposited To Account *',
                                controller:
                                    _accountController,
                                hint:
                                    'Select or type to add...',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // ROW 2
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Loan # *',
                                controller:
                                    _loanNumberController,
                                readOnly: true,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: _buildTextField(
                                label:
                                    'Reference #',
                                controller:
                                    _referenceController,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  _buildLoanTypeDropdown(),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // PRINCIPAL
                        // ==================================================

                        _buildTextField(
                          label:
                              'Principal Amount *',
                          controller:
                              _principalController,
                          keyboardType:
                              TextInputType.number,
                          hint: '0',
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // ROW 3
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label:
                                    'Interest Rate (p.a.) *',
                                controller:
                                    _interestController,
                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal: true,
                                ),
                                hint:
                                    'e.g. 12.5',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: _buildTextField(
                                label:
                                    'Loan Term (Months) *',
                                controller:
                                    _termController,
                                keyboardType:
                                    TextInputType.number,
                                hint: '0',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: _buildTextField(
                                label:
                                    'Calculated EMI',
                                controller:
                                    _emiController,
                                readOnly: true,
                                hint: '0.00',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // REMARKS
                        // ==================================================

                        _buildRemarksField(),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // ATTACHMENT
                        // ==================================================

                        _buildAttachmentSection(),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(
                height: 1,
              ),

              // ==================================================
              // BUTTONS
              // ==================================================

              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        10,
        14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'New Loan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(
                  0xFF263E56,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            icon: const Icon(
              Icons.close,
              color: Color(
                0xFF666666,
              ),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DATE FIELD
  // ==========================================================

  Widget _buildDateField({
    required String label,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        SizedBox(
          height: 39,
          child: TextField(
            controller: _dateController,
            readOnly: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              suffixIcon: IconButton(
                onPressed: _selectDate,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.black,
                ),
              ),
              border: _inputBorder(),
              enabledBorder:
                  _inputBorder(),
              focusedBorder:
                  _focusedBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // NORMAL INPUT
  // ==========================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        SizedBox(
          height: 39,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black,
                fontSize: 11,
              ),
              filled: readOnly,
              fillColor: readOnly
                  ? const Color(0xFFF3F3F3)
                  : Colors.white.withValues(
                      alpha: 0.45,
                    ),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: _inputBorder(),
              enabledBorder:
                  _inputBorder(),
              focusedBorder:
                  _focusedBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOAN TYPE
  // ==========================================================

  Widget _buildLoanTypeDropdown() {
    const loanTypes = [
      'EMI (Monthly Repayment)',
      'Bullet Repayment',
      'Interest Only',
      'Custom Repayment',
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Loan Type *',
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        SizedBox(
          height: 39,
          child: DropdownButtonFormField<String>(
            initialValue:
                _selectedLoanType,
            isExpanded: true,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              border: _inputBorder(),
              enabledBorder:
                  _inputBorder(),
              focusedBorder:
                  _focusedBorder(),
            ),
            items: loanTypes
                .map(
                  (type) =>
                      DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedLoanType =
                    value;
              });
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // REMARKS
  // ==========================================================

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Remarks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        TextField(
          controller:
              _remarksController,
          minLines: 4,
          maxLines: 4,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: '',
            border: _inputBorder(),
            enabledBorder:
                _inputBorder(),
            focusedBorder:
                _focusedBorder(),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ATTACHMENT
  // ==========================================================

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Loan Agreement / Docs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Row(
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedFileName =
                      'No file chosen';
                });
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                foregroundColor:
                    Colors.black,
                side: const BorderSide(
                  color: Color(
                    0xFFBFC6CE,
                  ),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    3,
                  ),
                ),
              ),
              child: const Text(
                'Choose Files',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child: Text(
                _selectedFileName,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // BUTTONS
  // ==========================================================

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(
        12,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFE5E7EA,
                ),
                foregroundColor:
                    const Color(
                  0xFF333333,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(
                    0xFF333333,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: _saveLoan,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF2C8AC4,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                ),
              ),
              child: const Text(
                'Save Loan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BORDERS
  // ==========================================================

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        3,
      ),
      borderSide: const BorderSide(
        color: Color(
          0xFFD7DCE1,
        ),
      ),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        3,
      ),
      borderSide: const BorderSide(
        color: Color(
          0xFF17395C,
        ),
        width: 1.3,
      ),
    );
  }
}

// =====================================================================
// LOAN DATA MODEL
// =====================================================================

class _LoanData {
  final String date;
  final String lender;
  final String account;
  final String loanNumber;
  final String reference;
  final String loanType;
  final String principal;
  final String interestRate;
  final String loanTerm;
  final String emi;
  final String remarks;

  const _LoanData({
    required this.date,
    required this.lender,
    required this.account,
    required this.loanNumber,
    required this.reference,
    required this.loanType,
    required this.principal,
    required this.interestRate,
    required this.loanTerm,
    required this.emi,
    required this.remarks,
  });
}