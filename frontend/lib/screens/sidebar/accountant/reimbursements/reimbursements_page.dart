import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/accountant_glass_widgets.dart';
// =====================================================================
// REIMBURSEMENTS PAGE
// =====================================================================

class ReimbursementsPage extends StatefulWidget {
  const ReimbursementsPage({
    super.key,
  });

  @override
  State<ReimbursementsPage> createState() =>
      _ReimbursementsPageState();
}

class _ReimbursementsPageState extends State<ReimbursementsPage> {
  final List<ReimbursementData> _reimbursements = [];

  int _reimbursementCounter = 1;

  void _openNewReimbursementForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x9A12202C),
      builder: (context) {
        return NewReimbursementDialog(
          nextNumber: 'REIM-$_reimbursementCounter',
          onSave: (reimbursement) {
            setState(() {
              _reimbursements.add(reimbursement);
              _reimbursementCounter++;
            });
          },
        );
      },
    );
  }

  void _deleteReimbursement(ReimbursementData reimbursement) {
    setState(() {
      _reimbursements.remove(reimbursement);
    });
  }

  void _updateStatus(
    ReimbursementData reimbursement,
    ReimbursementStatus status,
  ) {
    setState(() {
      reimbursement.status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AccountantGlassBackground(
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
                color: Colors.white.withValues(alpha: 0.06),
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
                color: Colors.white.withValues(alpha: 0.06),
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
                      'Reimbursements',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17395C),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _openNewReimbursementForm,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: const Text(
                        'New Reimbursement',
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

                AccountantGlassHoverCard(
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
                  child: _reimbursements.isEmpty
                      ? _buildEmptyTable()
                      : _buildReimbursementTable(),
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
          Icons.currency_exchange,
          size: 55,
          color: Color(0xFFB0B8C2),
        ),

        const SizedBox(height: 15),

        const Text(
          'No reimbursements found.',
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

  Widget _buildReimbursementTable() {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),

        ..._reimbursements.map(
          (reimbursement) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _buildActionsMenu(reimbursement),

                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat(
                            'dd-MM-yyyy',
                          ).format(reimbursement.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          reimbursement.reimbursementNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          reimbursement.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text(
                          reimbursement.claimant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            status: reimbursement.status,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          'INR ${reimbursement.total.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF17395C),
                            fontWeight: FontWeight.w700,
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

  Widget _buildActionsMenu(ReimbursementData reimbursement) {
    return SizedBox(
      width: 44,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'approve':
              _updateStatus(
                reimbursement,
                ReimbursementStatus.approved,
              );
              break;
            case 'reject':
              _updateStatus(
                reimbursement,
                ReimbursementStatus.rejected,
              );
              break;
            case 'paid':
              _updateStatus(
                reimbursement,
                ReimbursementStatus.paid,
              );
              break;
            case 'delete':
              _deleteReimbursement(reimbursement);
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem(
              value: 'approve',
              child: Text('Mark as Approved'),
            ),
            PopupMenuItem(
              value: 'paid',
              child: Text('Mark as Paid'),
            ),
            PopupMenuItem(
              value: 'reject',
              child: Text('Reject'),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 44,
            child: _TableHeaderText('ACTIONS'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('DATE'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('REIMBURSEMENT #'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('CATEGORY'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('CLAIMANT'),
          ),

          Expanded(
            flex: 2,
            child: _TableHeaderText('STATUS'),
          ),

          Expanded(
            child: _TableHeaderText('AMOUNT'),
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
// STATUS BADGE
// ===================================================================

class _StatusBadge extends StatelessWidget {
  final ReimbursementStatus status;

  const _StatusBadge({
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case ReimbursementStatus.pending:
        return const Color(0xFFFFF3E0);
      case ReimbursementStatus.approved:
        return const Color(0xFFE3F2FD);
      case ReimbursementStatus.paid:
        return const Color(0xFFE6F7EC);
      case ReimbursementStatus.rejected:
        return const Color(0xFFFDEAEA);
    }
  }

  Color get _textColor {
    switch (status) {
      case ReimbursementStatus.pending:
        return const Color(0xFFB07A15);
      case ReimbursementStatus.approved:
        return const Color(0xFF1E78B7);
      case ReimbursementStatus.paid:
        return const Color(0xFF1F9254);
      case ReimbursementStatus.rejected:
        return const Color(0xFFC0392B);
    }
  }

  String get _label {
    switch (status) {
      case ReimbursementStatus.pending:
        return 'Pending';
      case ReimbursementStatus.approved:
        return 'Approved';
      case ReimbursementStatus.paid:
        return 'Paid';
      case ReimbursementStatus.rejected:
        return 'Rejected';
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
// REIMBURSEMENT STATUS
// ===================================================================

enum ReimbursementStatus {
  pending,
  approved,
  paid,
  rejected,
}

// ===================================================================
// REIMBURSEMENT DATA MODEL
// ===================================================================

class ReimbursementData {
  final DateTime date;
  final String reimbursementNumber;
  final String category;
  final String claimantAccount;
  final String claimant;
  final String referenceNumber;
  final double amount;
  final String tax;
  final bool taxInclusive;
  final double subTotal;
  final double taxAmount;
  final double total;
  final bool billable;
  final String? customer;
  final String remarks;
  ReimbursementStatus status;

  ReimbursementData({
    required this.date,
    required this.reimbursementNumber,
    required this.category,
    required this.claimantAccount,
    required this.claimant,
    required this.referenceNumber,
    required this.amount,
    required this.tax,
    required this.taxInclusive,
    required this.subTotal,
    required this.taxAmount,
    required this.total,
    required this.billable,
    this.customer,
    required this.remarks,
    this.status = ReimbursementStatus.pending,
  });
}

// ===================================================================
// NEW REIMBURSEMENT DIALOG
// ===================================================================

class NewReimbursementDialog extends StatefulWidget {
  final String nextNumber;
  final ValueChanged<ReimbursementData> onSave;

  const NewReimbursementDialog({
    super.key,
    required this.nextNumber,
    required this.onSave,
  });

  @override
  State<NewReimbursementDialog> createState() =>
      _NewReimbursementDialogState();
}

class _NewReimbursementDialogState
    extends State<NewReimbursementDialog> {
  // ================================================================
  // FORM KEY
  // ================================================================

  final _formKey = GlobalKey<FormState>();

  // ================================================================
  // CONTROLLERS
  // ================================================================

  late final TextEditingController reimbursementNumberController =
      TextEditingController(
    text: widget.nextNumber,
  );

  final TextEditingController claimantController =
      TextEditingController();

  final TextEditingController referenceController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  final TextEditingController customerController =
      TextEditingController();

  // ================================================================
  // FORM VALUES
  // ================================================================

  DateTime selectedDate = DateTime.now();

  String? selectedCategory;
  String? selectedClaimantAccount;

  String selectedTax = '-- No Tax --';

  bool taxInclusive = false;
  bool billable = false;

  final String _attachedFileName = 'No file chosen';

  // ================================================================
  // DROPDOWN OPTIONS
  // ================================================================

  final List<String> expenseCategories = [
    'Travel',
    'Food & Meals',
    'Medical',
    'Office Supplies',
    'Communication',
    'Client Entertainment',
    'Training',
    'Software & Subscriptions',
    'Other',
  ];

  final List<String> claimantAccountOptions = [
    'Employee Reimbursement Payable',
    'Cash',
    'Bank Account',
    'Petty Cash',
    'Credit Card',
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
    reimbursementNumberController.dispose();
    claimantController.dispose();
    referenceController.dispose();
    amountController.dispose();
    remarksController.dispose();
    customerController.dispose();

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
          'Receipt attachment can be connected to a file picker next.',
        ),
      ),
    );
  }

  // ================================================================
  // SAVE
  // ================================================================

  void _saveReimbursement() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      _showMessage('Please select an expense category.');
      return;
    }

    if (selectedClaimantAccount == null) {
      _showMessage('Please select a claimant account.');
      return;
    }

    if (claimantController.text.trim().isEmpty) {
      _showMessage('Please select or enter a claimant.');
      return;
    }

    widget.onSave(
      ReimbursementData(
        date: selectedDate,
        reimbursementNumber: reimbursementNumberController.text.trim(),
        category: selectedCategory!,
        claimantAccount: selectedClaimantAccount!,
        claimant: claimantController.text.trim(),
        referenceNumber: referenceController.text.trim(),
        amount: amount,
        tax: selectedTax,
        taxInclusive: taxInclusive,
        subTotal: subTotal,
        taxAmount: calculatedTax,
        total: total,
        billable: billable,
        customer: billable ? customerController.text.trim() : null,
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
          maxHeight: 620,
        ),
        child: AccountantGlassDialogCard(
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
                        'New Reimbursement',
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
                        // ROW 1: DATE / EXPENSE CATEGORY / CLAIMANT ACCOUNT
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
                                label: 'Expense Category *',
                                value: selectedCategory,
                                hint: 'Select or type to add...',
                                items: expenseCategories,
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
                                label: 'Claimant Account *',
                                value: selectedClaimantAccount,
                                hint: 'Select or type to add...',
                                items: claimantAccountOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedClaimantAccount = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // ROW 2: REIMBURSEMENT # / CLAIMANT / REFERENCE #
                        // =================================================

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Reimbursement # *',
                                controller: reimbursementNumberController,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: _buildSearchField(
                                label: 'Claimant (Employee/Vendor) *',
                                controller: claimantController,
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

                        const Divider(
                          color: Color(0xFFE0E0E0),
                        ),

                        const SizedBox(height: 8),

                        // =================================================
                        // BILLABLE TO CUSTOMER
                        // =================================================

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: billable,
                              activeColor: const Color(0xFF1D78C9),
                              onChanged: (value) {
                                setState(() {
                                  billable = value ?? false;
                                });
                              },
                            ),

                            const Text(
                              'Billable to Customer',
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
                        // ATTACH RECEIPTS
                        // =================================================

                        const Text(
                          'Attach Receipts',
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
                      onPressed: _saveReimbursement,
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
                        'Save Reimbursement',
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
  // SEARCH-STYLE FIELD (Claimant)
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
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
  // CUSTOMER FIELD (shown when Billable to Customer is checked)
  // ================================================================

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
          controller: customerController,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
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
      fillColor: Colors.white.withValues(alpha: 0.45),

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