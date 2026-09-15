import 'package:flutter/material.dart';

import '../widgets/sales_glass_widgets.dart';
import 'package:intl/intl.dart';

// =====================================================================
// ESTIMATES PAGE
// =====================================================================

class EstimatesPage extends StatefulWidget {
  const EstimatesPage({
    super.key,
  });

  @override
  State<EstimatesPage> createState() => _EstimatesPageState();
}

class _EstimatesPageState extends State<EstimatesPage> {
  final List<EstimateData> _estimates = [];

  int _estimateCounter = 1;

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
    'Draft',
    'Sent',
    'Accepted',
    'Declined',
    'Expired',
  ];

  List<EstimateData> get _filteredEstimates {
    return _estimates.where(
      (estimate) {
        if (_statusFilter != 'All' &&
            estimate.status.label != _statusFilter) {
          return false;
        }

        if (_customerFilterController.text.trim().isNotEmpty) {
          final query = _customerFilterController.text.trim().toLowerCase();
          if (!estimate.customerName.toLowerCase().contains(query)) {
            return false;
          }
        }

        if (_dateFrom != null && estimate.date.isBefore(_dateFrom!)) {
          return false;
        }

        if (_dateTo != null && estimate.date.isAfter(_dateTo!)) {
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
  // NEW ESTIMATE
  // ================================================================

  void _openNewEstimateForm() {
    showDialog(
      context: context,
      barrierColor: const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (context) {
        return NewEstimateDialog(
          nextNumber: 'EST-$_estimateCounter',
          onSave: (estimate) {
            setState(() {
              _estimates.add(estimate);
              _estimateCounter++;
            });
          },
        );
      },
    );
  }

  void _deleteEstimate(EstimateData estimate) {
    setState(() {
      _estimates.remove(estimate);
    });
  }

  void _updateStatus(
    EstimateData estimate,
    EstimateStatus status,
  ) {
    setState(() {
      estimate.status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final estimates = _filteredEstimates;

    return SalesGlassPageFrame(
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
                color: Colors.white.withValues(alpha: 0.31),
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
                color: Colors.white.withValues(alpha: 0.31),
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
                      'Estimates',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17395C),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _openNewEstimateForm,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: const Text(
                        'New Estimate',
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
                    color: const Color(0x4FFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xD0FFFFFF),
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
                                borderRadius: BorderRadius.circular(11),
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
                                borderRadius: BorderRadius.circular(11),
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
                    color: const Color(0x4FFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xD0FFFFFF),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: _tableMinWidth(context),
                        ),
                        child: estimates.isEmpty
                            ? _buildEmptyTable()
                            : _buildEstimateTable(estimates),
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
  // MIN TABLE WIDTH so ACTIONS never wraps to the next line.
  // The table has a fixed set of column widths (see _col* constants
  // below plus horizontal padding) - we sum those up as the floor,
  // and additionally never go below the available viewport so the
  // table still stretches to fill wide screens.
  // ==================================================================

  double _tableMinWidth(BuildContext context) {
    const fixedColumnsWidth = _colDate +
        _colEstimateNumber +
        _colCustomer +
        _colSalesPerson +
        _colStatus +
        _colAmount +
        _colActions +
        40; // horizontal padding (20 left + 20 right)

    final screenWidth = MediaQuery.of(context).size.width;
    final available = screenWidth - 90; // sidebar + page padding allowance

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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
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
      hintStyle: const TextStyle(color: Colors.black),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      filled: true,
      fillColor: const Color(0x7AFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF1E78B7),
          width: 1.5,
        ),
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
          Icons.request_quote_outlined,
          size: 55,
          color: Color(0xFFB0B8C2),
        ),

        const SizedBox(height: 15),

        const Text(
          'No estimates found. Click "+ New Estimate" to add one!',
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

  static const double _colDate = 130;
  static const double _colEstimateNumber = 130;
  static const double _colCustomer = 220;
  static const double _colSalesPerson = 170;
  static const double _colStatus = 140;
  static const double _colAmount = 140;
  static const double _colActions = 70;

  Widget _buildEstimateTable(List<EstimateData> estimates) {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),

        ...estimates.map(
          (estimate) {
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
                          DateFormat(
                            'dd-MM-yyyy',
                          ).format(estimate.date),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colEstimateNumber,
                        child: Text(
                          estimate.estimateNumber,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colCustomer,
                        child: Text(
                          estimate.customerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colSalesPerson,
                        child: Text(
                          estimate.salesPerson.isEmpty
                              ? '-'
                              : estimate.salesPerson,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colStatus,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(
                            status: estimate.status,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colAmount,
                        child: Text(
                          'INR ${estimate.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF17395C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colActions,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'sent':
                                _updateStatus(
                                  estimate,
                                  EstimateStatus.sent,
                                );
                                break;

                              case 'accepted':
                                _updateStatus(
                                  estimate,
                                  EstimateStatus.accepted,
                                );
                                break;

                              case 'declined':
                                _updateStatus(
                                  estimate,
                                  EstimateStatus.declined,
                                );
                                break;

                              case 'delete':
                                _deleteEstimate(estimate);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'sent',
                                child: Text('Mark as Sent'),
                              ),
                              PopupMenuItem(
                                value: 'accepted',
                                child: Text('Mark as Accepted'),
                              ),
                              PopupMenuItem(
                                value: 'declined',
                                child: Text('Mark as Declined'),
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
        children: [
          const SizedBox(
            width: _colDate,
            child: _TableHeaderText('DATE'),
          ),

          const SizedBox(
            width: _colEstimateNumber,
            child: _TableHeaderText('ESTIMATE #'),
          ),

          const SizedBox(
            width: _colCustomer,
            child: _TableHeaderText('CUSTOMER NAME'),
          ),

          const SizedBox(
            width: _colSalesPerson,
            child: _TableHeaderText('SALES PERSON'),
          ),

          const SizedBox(
            width: _colStatus,
            child: _TableHeaderText('STATUS'),
          ),

          const SizedBox(
            width: _colAmount,
            child: _TableHeaderText('AMOUNT'),
          ),

          const SizedBox(
            width: _colActions,
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
  final EstimateStatus status;

  const _StatusBadge({
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case EstimateStatus.draft:
        return const Color(0xFFF1F1F1);
      case EstimateStatus.sent:
        return const Color(0xFFE3F2FD);
      case EstimateStatus.accepted:
        return const Color(0xFFE6F7EC);
      case EstimateStatus.declined:
        return const Color(0xFFFDEAEA);
      case EstimateStatus.expired:
        return const Color(0xFFFFF3E0);
    }
  }

  Color get _textColor {
    switch (status) {
      case EstimateStatus.draft:
        return const Color(0xFF6B7280);
      case EstimateStatus.sent:
        return const Color(0xFF1E78B7);
      case EstimateStatus.accepted:
        return const Color(0xFF1F9254);
      case EstimateStatus.declined:
        return const Color(0xFFC0392B);
      case EstimateStatus.expired:
        return const Color(0xFFB07A15);
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
// ESTIMATE STATUS
// ===================================================================

enum EstimateStatus {
  draft,
  sent,
  accepted,
  declined,
  expired;

  String get label {
    switch (this) {
      case EstimateStatus.draft:
        return 'Draft';
      case EstimateStatus.sent:
        return 'Sent';
      case EstimateStatus.accepted:
        return 'Accepted';
      case EstimateStatus.declined:
        return 'Declined';
      case EstimateStatus.expired:
        return 'Expired';
    }
  }
}

// ===================================================================
// ESTIMATE ITEM MODEL
// ===================================================================

class EstimateItem {
  String itemName;
  String description;
  double qty;
  double rate;

  EstimateItem({
    this.itemName = '',
    this.description = '',
    this.qty = 1,
    this.rate = 0,
  });

  double get amount => qty * rate;
}

// ===================================================================
// ESTIMATE DATA MODEL
// ===================================================================

class EstimateData {
  final DateTime date;
  final String estimateNumber;
  final String customerName;
  final String salesPerson;
  final DateTime? expiryDate;
  final List<EstimateItem> items;
  final double subTotal;
  final double total;
  EstimateStatus status;

  EstimateData({
    required this.date,
    required this.estimateNumber,
    required this.customerName,
    required this.salesPerson,
    this.expiryDate,
    required this.items,
    required this.subTotal,
    required this.total,
    this.status = EstimateStatus.draft,
  });
}

// ===================================================================
// NEW ESTIMATE DIALOG
// ===================================================================

class NewEstimateDialog extends StatefulWidget {
  final String nextNumber;
  final ValueChanged<EstimateData> onSave;

  const NewEstimateDialog({
    super.key,
    required this.nextNumber,
    required this.onSave,
  });

  @override
  State<NewEstimateDialog> createState() => _NewEstimateDialogState();
}

class _NewEstimateDialogState extends State<NewEstimateDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController estimateNumberController =
      TextEditingController(
    text: widget.nextNumber,
  );

  final TextEditingController customerController = TextEditingController();
  final TextEditingController salesPersonController =
      TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime? expiryDate;

  final List<_ItemRow> _itemRows = [];

  @override
  void initState() {
    super.initState();
    _itemRows.add(_ItemRow());
  }

  @override
  void dispose() {
    estimateNumberController.dispose();
    customerController.dispose();
    salesPersonController.dispose();

    for (final row in _itemRows) {
      row.dispose();
    }

    super.dispose();
  }

  void _addRow() {
    setState(() {
      _itemRows.add(_ItemRow());
    });
  }

  void _removeRow(_ItemRow row) {
    if (_itemRows.length == 1) {
      // Keep at least one row - just clear it instead of removing.
      setState(() {
        row.itemController.clear();
        row.descriptionController.clear();
        row.qtyController.text = '1';
        row.rateController.text = '0.00';
      });
      return;
    }

    setState(() {
      _itemRows.remove(row);
      row.dispose();
    });
  }

  double get subTotal {
    double sum = 0;
    for (final row in _itemRows) {
      sum += row.amount;
    }
    return sum;
  }

  double get total => subTotal;

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

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _saveEstimate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (customerController.text.trim().isEmpty) {
      _showMessage('Please select or enter a customer name.');
      return;
    }

    final items = _itemRows
        .where(
          (row) => row.itemController.text.trim().isNotEmpty,
        )
        .map(
          (row) => EstimateItem(
            itemName: row.itemController.text.trim(),
            description: row.descriptionController.text.trim(),
            qty: double.tryParse(row.qtyController.text.trim()) ?? 1,
            rate: double.tryParse(row.rateController.text.trim()) ?? 0,
          ),
        )
        .toList();

    widget.onSave(
      EstimateData(
        date: selectedDate,
        estimateNumber: estimateNumberController.text.trim(),
        customerName: customerController.text.trim(),
        salesPerson: salesPersonController.text.trim(),
        expiryDate: expiryDate,
        items: items,
        subTotal: subTotal,
        total: total,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SalesGlassDialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 640,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x4FFFFFFF),
            borderRadius: BorderRadius.circular(16),
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
                        'New Estimate',
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
                        // ROW 1: CUSTOMER / ESTIMATE # / SALES PERSON / DATE
                        // =================================================

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

                            const SizedBox(width: 14),

                            Expanded(
                              child: _buildTextField(
                                label: 'Estimate # *',
                                controller: estimateNumberController,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: _buildTextField(
                                label: 'Sales Person Name',
                                controller: salesPersonController,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: _buildDateField(
                                label: 'Date *',
                                value: selectedDate,
                                onTap: _selectDate,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // EXPIRY DATE
                        // =================================================

                        SizedBox(
                          width: 220,
                          child: _buildOptionalDateField(
                            label: 'Expiry Date',
                            value: expiryDate,
                            onTap: _selectExpiryDate,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // =================================================
                        // ITEM DETAILS TABLE
                        // =================================================

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xD0FFFFFF),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              // Header row
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF7F8FA),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        'Item Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        'Qty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        'Rate',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 36),
                                  ],
                                ),
                              ),

                              const Divider(
                                height: 1,
                                color: Color(0xFFE1E5EA),
                              ),

                              // Item rows
                              ..._itemRows.map(
                                (row) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller:
                                                    row.itemController,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                                decoration:
                                                    _cellInputDecoration()
                                                        .copyWith(
                                                  hintText:
                                                      'Select or type to search...',
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              TextFormField(
                                                controller: row
                                                    .descriptionController,
                                                minLines: 1,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                                decoration:
                                                    _cellInputDecoration()
                                                        .copyWith(
                                                  hintText: 'Description',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 70,
                                          child: TextFormField(
                                            controller: row.qtyController,
                                            keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                              decimal: true,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            onChanged: (_) {
                                              setState(() {});
                                            },
                                            decoration:
                                                _cellInputDecoration(),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 90,
                                          child: TextFormField(
                                            controller: row.rateController,
                                            keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                              decimal: true,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            onChanged: (_) {
                                              setState(() {});
                                            },
                                            decoration:
                                                _cellInputDecoration(),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 100,
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 13,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  const Color(0xFFF2F3F5),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFFD7DCE2,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'INR${row.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 36,
                                          child: IconButton(
                                            onPressed: () {
                                              _removeRow(row);
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: _addRow,
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                          ),
                          label: const Text('Add Row'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E78B7),
                            foregroundColor: Colors.white,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // =================================================
                        // TOTAL SUMMARY
                        // =================================================

                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 260,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                _buildTotalRow(
                                  'Sub Total',
                                  subTotal,
                                ),

                                const SizedBox(height: 8),

                                _buildTotalRow(
                                  'Total',
                                  total,
                                  isBold: true,
                                ),
                              ],
                            ),
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
                          borderRadius: BorderRadius.circular(11),
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
                      onPressed: _saveEstimate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E78B7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Text(
                        'Save Estimate',
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
  // FIELD BUILDERS
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
            fontSize: 14,
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          decoration: _inputDecoration().copyWith(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 14, 6, 6),
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

  Widget _buildOptionalDateField({
    required String label,
    required DateTime? value,
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

  Widget _buildTotalRow(
    String label,
    double value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF444444),
            fontSize: isBold ? 17 : 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),

        Text(
          isBold
              ? 'INR${value.toStringAsFixed(2)}'
              : 'INR ${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: const Color(0xFF17395C),
            fontSize: isBold ? 19 : 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintStyle: const TextStyle(color: Colors.black),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),
      filled: true,
      fillColor: const Color(0x7AFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFF1E78B7),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  InputDecoration _cellInputDecoration() {
    return InputDecoration(
      hintStyle: const TextStyle(color: Colors.black),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      filled: true,
      fillColor: const Color(0x7AFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD7DCE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF1E78B7),
          width: 1.5,
        ),
      ),
    );
  }
}

// ===================================================================
// ITEM ROW (internal controller bundle for a single line item)
// ===================================================================

class _ItemRow {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController qtyController = TextEditingController(
    text: '1',
  );
  final TextEditingController rateController = TextEditingController(
    text: '0.00',
  );

  double get amount {
    final qty = double.tryParse(qtyController.text.trim()) ?? 0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0;
    return qty * rate;
  }

  void dispose() {
    itemController.dispose();
    descriptionController.dispose();
    qtyController.dispose();
    rateController.dispose();
  }
}