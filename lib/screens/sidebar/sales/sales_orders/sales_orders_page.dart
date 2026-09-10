import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =====================================================================
// SALES ORDER PAGE
// =====================================================================

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({
    super.key,
  });

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final List<SalesOrderData> _orders = [];

  int _orderCounter = 1;

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
    'Confirmed',
    'Fulfilled',
    'Cancelled',
  ];

  List<SalesOrderData> get _filteredOrders {
    return _orders.where(
      (order) {
        if (_statusFilter != 'All' && order.status.label != _statusFilter) {
          return false;
        }

        if (_customerFilterController.text.trim().isNotEmpty) {
          final query = _customerFilterController.text.trim().toLowerCase();
          if (!order.customerName.toLowerCase().contains(query)) {
            return false;
          }
        }

        if (_dateFrom != null && order.date.isBefore(_dateFrom!)) {
          return false;
        }

        if (_dateTo != null && order.date.isAfter(_dateTo!)) {
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
  // NEW SALES ORDER
  // ================================================================

  void _openNewOrderForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NewSalesOrderDialog(
          nextNumber: 'SO-$_orderCounter',
          onSave: (order) {
            setState(() {
              _orders.add(order);
              _orderCounter++;
            });
          },
        );
      },
    );
  }

  void _deleteOrder(SalesOrderData order) {
    setState(() {
      _orders.remove(order);
    });
  }

  void _updateStatus(
    SalesOrderData order,
    SalesOrderStatus status,
  ) {
    setState(() {
      order.status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

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
                      'Sales Orders',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17395C),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _openNewOrderForm,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: const Text(
                        'New Sales Order',
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
                        child: orders.isEmpty
                            ? _buildEmptyTable()
                            : _buildOrderTable(orders),
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
  static const double _colSoNumber = 90;
  static const double _colEstimateNumber = 110;
  static const double _colCustomer = 200;
  static const double _colSalesPerson = 150;
  static const double _colStatus = 120;
  static const double _colPurchaseStatus = 140;
  static const double _colAmount = 130;
  static const double _colActions = 70;

  double _tableMinWidth(BuildContext context) {
    const fixedColumnsWidth = _colDate +
        _colSoNumber +
        _colEstimateNumber +
        _colCustomer +
        _colSalesPerson +
        _colStatus +
        _colPurchaseStatus +
        _colAmount +
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
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      filled: true,
      fillColor: Colors.white,
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
          Icons.shopping_cart_outlined,
          size: 55,
          color: Color(0xFFB0B8C2),
        ),

        const SizedBox(height: 15),

        const Text(
          'No sales orders found. Click "+ New Sales Order" to add one!',
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

  Widget _buildOrderTable(List<SalesOrderData> orders) {
    return Column(
      children: [
        _buildTableHeader(),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),

        ...orders.map(
          (order) {
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
                          DateFormat('dd-MM-yyyy').format(order.date),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colSoNumber,
                        child: Text(
                          order.orderNumber,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colEstimateNumber,
                        child: Text(
                          order.estimateNumber.isEmpty
                              ? '-'
                              : order.estimateNumber,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colCustomer,
                        child: Text(
                          order.customerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colSalesPerson,
                        child: Text(
                          order.salesPerson.isEmpty
                              ? '-'
                              : order.salesPerson,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        width: _colStatus,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(status: order.status),
                        ),
                      ),

                      SizedBox(
                        width: _colPurchaseStatus,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _PurchaseStatusBadge(
                            status: order.purchaseStatus,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colAmount,
                        child: Text(
                          'INR ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF17395C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _colActions,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'confirmed':
                                _updateStatus(
                                  order,
                                  SalesOrderStatus.confirmed,
                                );
                                break;

                              case 'fulfilled':
                                _updateStatus(
                                  order,
                                  SalesOrderStatus.fulfilled,
                                );
                                break;

                              case 'cancelled':
                                _updateStatus(
                                  order,
                                  SalesOrderStatus.cancelled,
                                );
                                break;

                              case 'delete':
                                _deleteOrder(order);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'confirmed',
                                child: Text('Mark as Confirmed'),
                              ),
                              PopupMenuItem(
                                value: 'fulfilled',
                                child: Text('Mark as Fulfilled'),
                              ),
                              PopupMenuItem(
                                value: 'cancelled',
                                child: Text('Mark as Cancelled'),
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
          SizedBox(width: _colDate, child: _TableHeaderText('DATE')),
          SizedBox(width: _colSoNumber, child: _TableHeaderText('SO #')),
          SizedBox(
            width: _colEstimateNumber,
            child: _TableHeaderText('ESTIMATE #'),
          ),
          SizedBox(
            width: _colCustomer,
            child: _TableHeaderText('CUSTOMER NAME'),
          ),
          SizedBox(
            width: _colSalesPerson,
            child: _TableHeaderText('SALES PERSON'),
          ),
          SizedBox(width: _colStatus, child: _TableHeaderText('STATUS')),
          SizedBox(
            width: _colPurchaseStatus,
            child: _TableHeaderText('PURCHASE STATUS'),
          ),
          SizedBox(width: _colAmount, child: _TableHeaderText('AMOUNT')),
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
// STATUS BADGES
// ===================================================================

class _StatusBadge extends StatelessWidget {
  final SalesOrderStatus status;

  const _StatusBadge({
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case SalesOrderStatus.draft:
        return const Color(0xFFF1F1F1);
      case SalesOrderStatus.confirmed:
        return const Color(0xFFE3F2FD);
      case SalesOrderStatus.fulfilled:
        return const Color(0xFFE6F7EC);
      case SalesOrderStatus.cancelled:
        return const Color(0xFFFDEAEA);
    }
  }

  Color get _textColor {
    switch (status) {
      case SalesOrderStatus.draft:
        return const Color(0xFF6B7280);
      case SalesOrderStatus.confirmed:
        return const Color(0xFF1E78B7);
      case SalesOrderStatus.fulfilled:
        return const Color(0xFF1F9254);
      case SalesOrderStatus.cancelled:
        return const Color(0xFFC0392B);
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

class _PurchaseStatusBadge extends StatelessWidget {
  final PurchaseStatus status;

  const _PurchaseStatusBadge({
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case PurchaseStatus.notStarted:
        return const Color(0xFFF1F1F1);
      case PurchaseStatus.partial:
        return const Color(0xFFFFF3E0);
      case PurchaseStatus.completed:
        return const Color(0xFFE6F7EC);
    }
  }

  Color get _textColor {
    switch (status) {
      case PurchaseStatus.notStarted:
        return const Color(0xFF6B7280);
      case PurchaseStatus.partial:
        return const Color(0xFFB07A15);
      case PurchaseStatus.completed:
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
// ENUMS
// ===================================================================

enum SalesOrderStatus {
  draft,
  confirmed,
  fulfilled,
  cancelled;

  String get label {
    switch (this) {
      case SalesOrderStatus.draft:
        return 'Draft';
      case SalesOrderStatus.confirmed:
        return 'Confirmed';
      case SalesOrderStatus.fulfilled:
        return 'Fulfilled';
      case SalesOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PurchaseStatus {
  notStarted,
  partial,
  completed;

  String get label {
    switch (this) {
      case PurchaseStatus.notStarted:
        return 'Not Started';
      case PurchaseStatus.partial:
        return 'Partial';
      case PurchaseStatus.completed:
        return 'Completed';
    }
  }
}

// ===================================================================
// DATA MODELS
// ===================================================================

class SalesOrderItem {
  String itemName;
  String description;
  double qty;
  double rate;

  SalesOrderItem({
    this.itemName = '',
    this.description = '',
    this.qty = 1,
    this.rate = 0,
  });

  double get amount => qty * rate;
}

class SalesOrderData {
  final DateTime date;
  final String orderNumber;
  final String estimateNumber;
  final String customerName;
  final String salesPerson;
  final DateTime? expectedShipmentDate;
  final List<SalesOrderItem> items;
  final double subTotal;
  final double total;
  final String notes;
  final String termsAndConditions;
  SalesOrderStatus status;
  PurchaseStatus purchaseStatus;

  SalesOrderData({
    required this.date,
    required this.orderNumber,
    this.estimateNumber = '',
    required this.customerName,
    required this.salesPerson,
    this.expectedShipmentDate,
    required this.items,
    required this.subTotal,
    required this.total,
    this.notes = '',
    this.termsAndConditions = '',
    this.status = SalesOrderStatus.draft,
    this.purchaseStatus = PurchaseStatus.notStarted,
  });
}

// ===================================================================
// NEW SALES ORDER DIALOG
// ===================================================================

class NewSalesOrderDialog extends StatefulWidget {
  final String nextNumber;
  final ValueChanged<SalesOrderData> onSave;

  const NewSalesOrderDialog({
    super.key,
    required this.nextNumber,
    required this.onSave,
  });

  @override
  State<NewSalesOrderDialog> createState() => _NewSalesOrderDialogState();
}

class _NewSalesOrderDialogState extends State<NewSalesOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController orderNumberController =
      TextEditingController(text: widget.nextNumber);

  final TextEditingController customerController = TextEditingController();
  final TextEditingController salesPersonController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController termsController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime? expectedShipmentDate;

  final List<_ItemRow> _itemRows = [];

  @override
  void initState() {
    super.initState();
    _itemRows.add(_ItemRow());
  }

  @override
  void dispose() {
    orderNumberController.dispose();
    customerController.dispose();
    salesPersonController.dispose();
    notesController.dispose();
    termsController.dispose();

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

  Future<void> _selectExpectedShipmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expectedShipmentDate ?? selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expectedShipmentDate = picked;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _saveOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (customerController.text.trim().isEmpty) {
      _showMessage('Please select or enter a customer name.');
      return;
    }

    final items = _itemRows
        .where((row) => row.itemController.text.trim().isNotEmpty)
        .map(
          (row) => SalesOrderItem(
            itemName: row.itemController.text.trim(),
            description: row.descriptionController.text.trim(),
            qty: double.tryParse(row.qtyController.text.trim()) ?? 1,
            rate: double.tryParse(row.rateController.text.trim()) ?? 0,
          ),
        )
        .toList();

    widget.onSave(
      SalesOrderData(
        date: selectedDate,
        orderNumber: orderNumberController.text.trim(),
        customerName: customerController.text.trim(),
        salesPerson: salesPersonController.text.trim(),
        expectedShipmentDate: expectedShipmentDate,
        items: items,
        subTotal: subTotal,
        total: total,
        notes: notesController.text.trim(),
        termsAndConditions: termsController.text.trim(),
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
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 660),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'New Sales Order',
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

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
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
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildTextField(
                                label: 'Sales Order # *',
                                controller: orderNumberController,
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

                        SizedBox(
                          width: 220,
                          child: _buildOptionalDateField(
                            label: 'Expected Shipment Date',
                            value: expectedShipmentDate,
                            onTap: _selectExpectedShipmentDate,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildItemsTable(),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: _addRow,
                          icon: const Icon(Icons.add, size: 18),
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

                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 260,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                _buildTotalRow('Sub Total', subTotal),
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

                        const SizedBox(height: 18),

                        const Text(
                          'Notes',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.black),
                          decoration: _inputDecoration(),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: termsController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.black),
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
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
                      onPressed: _saveOrder,
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
                        'Save Sales Order',
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

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E5EA)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: const BoxDecoration(color: Color(0xFFF7F8FA)),
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

          const Divider(height: 1, color: Color(0xFFE1E5EA)),

          ..._itemRows.map(
            (row) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: row.itemController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            decoration: _cellInputDecoration().copyWith(
                              hintText: 'Select or type to search...',
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: row.descriptionController,
                            minLines: 1,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            decoration: _cellInputDecoration().copyWith(
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
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: _cellInputDecoration(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        controller: row.rateController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: _cellInputDecoration(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD7DCE2),
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
                        onPressed: () => _removeRow(row),
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

  InputDecoration _cellInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
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
}

// ===================================================================
// ITEM ROW
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