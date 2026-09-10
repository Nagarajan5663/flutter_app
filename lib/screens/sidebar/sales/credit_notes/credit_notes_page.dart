import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =====================================================================
// CREDIT NOTES PAGE
// =====================================================================

class CreditNotesPage extends StatefulWidget {
  const CreditNotesPage({
    super.key,
  });

  @override
  State<CreditNotesPage> createState() => _CreditNotesPageState();
}

class _CreditNotesPageState extends State<CreditNotesPage> {
  final List<CreditNoteData> _creditNotes = [];

  int _creditNoteCounter = 1;

  // ================================================================
  // FILTER STATE
  // ================================================================

  String _statusFilter = 'All';
  final TextEditingController _customerFilterController =
      TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final List<String> _statusOptions = [
    'All',
    'Open',
    'Partially Applied',
    'Closed',
  ];

  List<CreditNoteData> get _filteredCreditNotes {
    return _creditNotes.where(
      (note) {
        if (_statusFilter != 'All' && note.status.label != _statusFilter) {
          return false;
        }

        if (_customerFilterController.text.trim().isNotEmpty) {
          final query = _customerFilterController.text.trim().toLowerCase();
          if (!note.customerName.toLowerCase().contains(query)) {
            return false;
          }
        }

        if (_dateFrom != null && note.date.isBefore(_dateFrom!)) {
          return false;
        }

        if (_dateTo != null && note.date.isAfter(_dateTo!)) {
          return false;
        }

        return true;
      },
    ).toList();
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = 'All';
      _customerFilterController.clear();
      _dateFrom = null;
      _dateTo = null;
    });
  }

  @override
  void dispose() {
    _customerFilterController.dispose();
    super.dispose();
  }

  // ================================================================
  // NEW CREDIT NOTE
  // ================================================================

  void _openNewCreditNoteForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NewCreditNoteDialog(
          nextNumber: 'CN-$_creditNoteCounter',
          onSave: (note) {
            setState(() {
              _creditNotes.add(note);
              _creditNoteCounter++;
            });
          },
        );
      },
    );
  }

  void _deleteCreditNote(CreditNoteData note) {
    setState(() {
      _creditNotes.remove(note);
    });
  }

  void _updateStatus(
    CreditNoteData note,
    CreditNoteStatus status,
  ) {
    setState(() {
      note.status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final creditNotes = _filteredCreditNotes;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F6F9),
      child: Stack(
        children: [
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
                      'Credit Notes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17395C),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _openNewCreditNoteForm,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: const Text(
                        'New Credit Note',
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

                const SizedBox(height: 20),

                // ===================================================
                // FILTER BAR
                // ===================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE1E5EA),
                    ),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      SizedBox(
                        width: 150,
                        child: _buildFilterDropdown(),
                      ),

                      SizedBox(
                        width: 200,
                        child: _buildFilterTextField(),
                      ),

                      SizedBox(
                        width: 170,
                        child: _buildFilterDateField(
                          label: 'Date From:',
                          value: _dateFrom,
                          onChanged: (value) {
                            setState(() {
                              _dateFrom = value;
                            });
                          },
                        ),
                      ),

                      SizedBox(
                        width: 170,
                        child: _buildFilterDateField(
                          label: 'Date To:',
                          value: _dateTo,
                          onChanged: (value) {
                            setState(() {
                              _dateTo = value;
                            });
                          },
                        ),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E78B7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: const Text('Filter'),
                          ),

                          const SizedBox(width: 10),

                          OutlinedButton(
                            onPressed: _clearFilters,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF444444),
                              side: const BorderSide(
                                color: Color(0xFFD7DCE2),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: _tableMinWidth(context),
                        ),
                        child: creditNotes.isEmpty
                            ? _buildEmptyTable()
                            : _buildCreditNoteTable(creditNotes),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // FIXED COLUMN WIDTHS - table scrolls horizontally instead of
  // wrapping ACTIONS onto a new line on narrow screens.
  // ==================================================================

  static const double _colDate = 120;
  static const double _colCreditNoteNumber = 120;
  static const double _colCustomer = 200;
  static const double _colStatus = 150;
  static const double _colAmount = 130;
  static const double _colAmountRemaining = 160;
  static const double _colActions = 70;

  double _tableMinWidth(BuildContext context) {
    const fixedColumnsWidth = _colDate +
        _colCreditNoteNumber +
        _colCustomer +
        _colStatus +
        _colAmount +
        _colAmountRemaining +
        _colActions +
        40;

    final screenWidth = MediaQuery.of(context).size.width;
    final available = screenWidth - 90;

    return available > fixedColumnsWidth ? available : fixedColumnsWidth;
  }

  // ==================================================================
  // FILTER WIDGETS
  // ==================================================================

  Widget _buildFilterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status:',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _statusFilter,
          isExpanded: true,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          decoration: _filterInputDecoration(),
          items: _statusOptions.map(
            (status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            },
          ).toList(),
          onChanged: (value) {
            setState(() {
              _statusFilter = value ?? 'All';
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Name:',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _customerFilterController,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          decoration: _filterInputDecoration().copyWith(
            hintText: 'Customer name...',
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildFilterDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              onChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: _filterInputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? 'dd-mm-yyyy'
                        : DateFormat('dd-MM-yyyy').format(value),
                    style: TextStyle(
                      color: value == null
                          ? const Color(0xFF9AA3AD)
                          : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _filterInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD7DCE2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD7DCE2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF1E78B7), width: 1.5),
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

        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        const SizedBox(height: 45),

        const Icon(
          Icons.receipt_long_outlined,
          size: 55,
          color: Color(0xFFB0B8C2),
        ),

        const SizedBox(height: 15),

        const Text(
          'No credit notes found. Click "+ New Credit Note" to add one!',
          style: TextStyle(color: Color(0xFF777777), fontSize: 16),
        ),

        const SizedBox(height: 45),
      ],
    );
  }

  // ==================================================================
  // TABLE
  // ==================================================================

  Widget _buildCreditNoteTable(List<CreditNoteData> creditNotes) {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        ...creditNotes.map(
          (note) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _colDate,
                        child: Text(
                          DateFormat('dd-MM-yyyy').format(note.date),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colCreditNoteNumber,
                        child: Text(
                          note.creditNoteNumber,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colCustomer,
                        child: Text(
                          note.customerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colStatus,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(status: note.status),
                        ),
                      ),

                      SizedBox(
                        width: _colAmount,
                        child: Text(
                          'INR ${note.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF17395C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colAmountRemaining,
                        child: Text(
                          'INR ${note.amountRemaining.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colActions,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'partial':
                                _updateStatus(
                                  note,
                                  CreditNoteStatus.partiallyApplied,
                                );
                                break;

                              case 'closed':
                                _updateStatus(
                                  note,
                                  CreditNoteStatus.closed,
                                );
                                break;

                              case 'delete':
                                _deleteCreditNote(note);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'partial',
                                child: Text('Mark as Partially Applied'),
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
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE5E7EB)),
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
          SizedBox(width: _colDate, child: _TableHeaderText('DATE')),
          SizedBox(
            width: _colCreditNoteNumber,
            child: _TableHeaderText('CREDIT NOTE #'),
          ),
          SizedBox(
            width: _colCustomer,
            child: _TableHeaderText('CUSTOMER NAME'),
          ),
          SizedBox(width: _colStatus, child: _TableHeaderText('STATUS')),
          SizedBox(width: _colAmount, child: _TableHeaderText('AMOUNT')),
          SizedBox(
            width: _colAmountRemaining,
            child: _TableHeaderText('AMOUNT REMAINING'),
          ),
          SizedBox(width: _colActions, child: _TableHeaderText('ACTIONS')),
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
  final CreditNoteStatus status;

  const _StatusBadge({
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case CreditNoteStatus.open:
        return const Color(0xFFE3F2FD);
      case CreditNoteStatus.partiallyApplied:
        return const Color(0xFFFFF3E0);
      case CreditNoteStatus.closed:
        return const Color(0xFFE6F7EC);
    }
  }

  Color get _textColor {
    switch (status) {
      case CreditNoteStatus.open:
        return const Color(0xFF1E78B7);
      case CreditNoteStatus.partiallyApplied:
        return const Color(0xFFB07A15);
      case CreditNoteStatus.closed:
        return const Color(0xFF1F9254);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
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
// CREDIT NOTE STATUS
// ===================================================================

enum CreditNoteStatus {
  open,
  partiallyApplied,
  closed;

  String get label {
    switch (this) {
      case CreditNoteStatus.open:
        return 'Open';
      case CreditNoteStatus.partiallyApplied:
        return 'Partially Applied';
      case CreditNoteStatus.closed:
        return 'Closed';
    }
  }
}

// ===================================================================
// DATA MODEL
// ===================================================================

class CreditNoteData {
  final DateTime date;
  final String creditNoteNumber;
  final String customerName;
  final double amount;
  final String reason;
  CreditNoteStatus status;
  double amountRemaining;

  CreditNoteData({
    required this.date,
    required this.creditNoteNumber,
    required this.customerName,
    required this.amount,
    this.reason = '',
    this.status = CreditNoteStatus.open,
    double? amountRemaining,
  }) : amountRemaining = amountRemaining ?? amount;
}

// ===================================================================
// NEW CREDIT NOTE DIALOG
// ===================================================================

class NewCreditNoteDialog extends StatefulWidget {
  final String nextNumber;
  final ValueChanged<CreditNoteData> onSave;

  const NewCreditNoteDialog({
    super.key,
    required this.nextNumber,
    required this.onSave,
  });

  @override
  State<NewCreditNoteDialog> createState() => _NewCreditNoteDialogState();
}

class _NewCreditNoteDialogState extends State<NewCreditNoteDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController creditNoteNumberController =
      TextEditingController(text: widget.nextNumber);

  final TextEditingController customerController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    creditNoteNumberController.dispose();
    customerController.dispose();
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (customerController.text.trim().isEmpty) {
      _showMessage('Please select or enter a customer name.');
      return;
    }

    widget.onSave(
      CreditNoteData(
        date: selectedDate,
        creditNoteNumber: creditNoteNumberController.text.trim(),
        customerName: customerController.text.trim(),
        amount: double.tryParse(amountController.text.trim()) ?? 0,
        reason: reasonController.text.trim(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'New Credit Note',
                        style: TextStyle(
                          color: Color(0xFF17395C),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF777777)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE0E0E0)),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildSearchField(
                              label: 'Customer Name *',
                              controller: customerController,
                              hint: 'Select or type to search...',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Credit Note # *',
                              controller: creditNoteNumberController,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Date *',
                              value: selectedDate,
                              onTap: _selectDate,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAmountField(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Reason (Optional)',
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.black),
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: _save,
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
                        'Save',
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          decoration: _inputDecoration().copyWith(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
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

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(value),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount *',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          style: const TextStyle(color: Colors.black),
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
        borderSide: const BorderSide(color: Color(0xFFD7DCE2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFD7DCE2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF1E78B7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}