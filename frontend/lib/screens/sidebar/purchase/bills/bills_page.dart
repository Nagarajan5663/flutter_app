import 'package:flutter/material.dart';

import '../shared/glass_modal_shell.dart';
import 'bill_filter.dart';
import 'bill_model.dart';
import 'bill_repository.dart';
import 'widgets/add_bill_dialog.dart';

// ============================================================
// BILLS PAGE
// ============================================================

class BillsPage
    extends StatefulWidget {
  const BillsPage({
    super.key,
  });

  @override
  State<BillsPage>
      createState() =>
          _BillsPageState();
}

class _BillsPageState
    extends State<BillsPage> {
  final BillRepository _repository =
      InMemoryBillRepository();

  List<BillModel> _bills = [];

  bool _isLoading = true;

  String? _errorMessage;

  final TextEditingController
      vendorController =
      TextEditingController();

  DateTime? dateFrom;

  DateTime? dateTo;

  String statusFilter =
      'All';

  // BillModel uses these exact statuses.
  final List<String>
      statusOptions =
      const [
    'All',
    'Unpaid',
    'Partially Paid',
    'Paid',
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadBills();
  }

  @override
  void dispose() {
    vendorController
        .dispose();

    super.dispose();
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  BillFilter get _currentFilter =>
      BillFilter(
        status:
            statusFilter,

        vendorName:
            vendorController.text,

        dateFrom:
            dateFrom,

        dateTo:
            dateTo,
      );

  // ==========================================================
  // LOAD
  // ==========================================================

  Future<void> _loadBills() async {
    setState(() {
      _isLoading =
          true;

      _errorMessage =
          null;
    });

    try {
      final List<BillModel> result =
          await _repository
              .getBills(
        filter:
            _currentFilter,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _bills =
            result;

        _isLoading =
            false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading =
            false;

        _errorMessage =
            error.toString();
      });
    }
  }

  // ==========================================================
  // NEW BILL
  // ==========================================================

  Future<void>
      _openAddBill() async {
    final BillModelDraft? draft =
        await showDialog<
            BillModelDraft>(
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (_) =>
              const AddBillDialog(),
    );

    if (
      !mounted ||
      draft == null
    ) {
      return;
    }

    final BillModel bill =
        BillModel(
      billNumber:
          draft.billNumber,

      vendorInvoiceNumber:
          draft
              .vendorInvoiceNumber,

      invoiceAttachmentPath:
          draft
              .invoiceAttachmentPath,

      vendorId:
          draft.vendorId,

      vendorName:
          draft.vendorName,

      purchaseOrderId:
          draft.purchaseOrderId,

      purchaseOrderNumber:
          draft
              .purchaseOrderNumber,

      billDate:
          draft.billDate,

      dueDate:
          draft.dueDate,

      items:
          draft.items,

      taxAmount:
          draft.taxAmount,
    );

    try {
      await _repository
          .addBill(
        bill,
      );

      await _loadBills();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Bill created successfully',
          ),

          backgroundColor:
              Color(
            0xFF1E7B34,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            'Failed to create bill: $error',
          ),

          backgroundColor:
              const Color(
            0xFFAB2A2A,
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> _deleteBill(
    BillModel bill,
  ) async {
    if (
      bill.id == null
    ) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context:
          context,

      builder:
          (context) {
        return AlertDialog(
          title:
              const Text(
            'Delete Bill',
          ),

          content:
              Text(
            'Delete ${bill.billNumber}?',
          ),

          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed:
                  () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.red,

                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (
      confirmed != true
    ) {
      return;
    }

    try {
      await _repository
          .deleteBill(
        bill.id!,
      );

      await _loadBills();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Bill deleted successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            'Failed to delete bill: $error',
          ),

          backgroundColor:
              const Color(
            0xFFAB2A2A,
          ),
        ),
      );
    }
  }

  // ==========================================================
  // RECORD PAYMENT
  // ==========================================================

  Future<void> _recordPayment(
    BillModel bill,
  ) async {
    if (
      bill.id == null
    ) {
      return;
    }

    if (
      bill.amountDue <= 0
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'This bill is already fully paid',
          ),
        ),
      );

      return;
    }

    final TextEditingController
        controller =
        TextEditingController();

    final double? payment =
        await showDialog<double>(
      context:
          context,

      builder:
          (context) {
        return AlertDialog(
          title:
              const Text(
            'Record Payment',
          ),

          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Bill: ${bill.billNumber}',
              ),

              const SizedBox(
                height:
                    8,
              ),

              Text(
                'Amount Due: INR ${bill.amountDue.toStringAsFixed(2)}',
              ),

              const SizedBox(
                height:
                    16,
              ),

              TextField(
                controller:
                    controller,

                autofocus:
                    true,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal:
                      true,
                ),

                decoration:
                    const InputDecoration(
                  labelText:
                      'Payment Amount',

                  prefixText:
                      'INR ',

                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  context,
                );
              },

              child:
                  const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed:
                  () {
                final double amount =
                    double.tryParse(
                          controller
                              .text
                              .trim(),
                        ) ??
                        0;

                if (
                  amount <= 0 ||
                  amount >
                      bill.amountDue
                ) {
                  return;
                }

                Navigator.pop(
                  context,
                  amount,
                );
              },

              child:
                  const Text(
                'Save Payment',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (
      payment == null
    ) {
      return;
    }

    try {
      await _repository
          .recordPayment(
        bill.id!,
        payment,
      );

      await _loadBills();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Payment recorded successfully',
          ),

          backgroundColor:
              Color(
            0xFF1E7B34,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            'Failed to record payment: $error',
          ),

          backgroundColor:
              const Color(
            0xFFAB2A2A,
          ),
        ),
      );
    }
  }

  // ==========================================================
  // CLEAR FILTER
  // ==========================================================

  void _clearFilters() {
    statusFilter =
        'All';

    vendorController
        .clear();

    dateFrom =
        null;

    dateTo =
        null;

    _loadBills();
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> _pickDate(
    DateTime? initial,
    ValueChanged<DateTime>
        onPicked,
  ) async {
    final DateTime? picked =
        await showDatePicker(
      context:
          context,

      initialDate:
          initial ??
              DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),
    );

    if (
      picked != null
    ) {
      onPicked(
        picked,
      );
    }
  }

  String _fmt(
    DateTime? date,
  ) {
    if (
      date == null
    ) {
      return '-';
    }

    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // ==========================================================
  // STATUS COLORS
  // ==========================================================

  Color _statusBg(
    String status,
  ) {
    switch (status) {
      case 'Paid':
        return const Color(
          0xFFE3F6E8,
        );

      case 'Partially Paid':
        return const Color(
          0xFFFFF3D8,
        );

      default:
        return const Color(
          0xFFF4E3E3,
        );
    }
  }

  Color _statusFg(
    String status,
  ) {
    switch (status) {
      case 'Paid':
        return const Color(
          0xFF1E7B34,
        );

      case 'Partially Paid':
        return const Color(
          0xFF986A00,
        );

      default:
        return const Color(
          0xFFAB2A2A,
        );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassPageBackground(
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets
                .all(
          20,
        ),

        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Expanded(
                  child:
                      Text(
                    'Vendor Bills',

                    style:
                        TextStyle(
                      fontSize:
                          28,

                      fontWeight:
                          FontWeight
                              .bold,

                      color:
                          Color(
                        0xFF123456,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _loadBills,

                  tooltip:
                      'Refresh Bills',

                  icon:
                      const Icon(
                    Icons.refresh,
                  ),
                ),

                const SizedBox(
                  width:
                      8,
                ),

                GlassButton(
                  onPressed:
                      _openAddBill,

                  icon:
                      Icons.add,

                  label:
                      'New Bill',
                ),
              ],
            ),

            const SizedBox(
              height:
                  20,
            ),

            // ==================================================
            // FILTERS
            // ==================================================

            GlassPanel(
              padding:
                  const EdgeInsets
                      .all(
                20,
              ),

              child:
                  Wrap(
                spacing:
                    16,

                runSpacing:
                    16,

                crossAxisAlignment:
                    WrapCrossAlignment
                        .end,

                children: [
                  _filterField(
                    label:
                        'Status',

                    child:
                        Container(
                      width:
                          175,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            12,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF8F9FA,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          7,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD9DEE5,
                          ),
                        ),
                      ),

                      child:
                          DropdownButtonHideUnderline(
                        child:
                            DropdownButton<
                                String>(
                          value:
                              statusFilter,

                          isExpanded:
                              true,

                          items:
                              statusOptions
                                  .map(
                            (
                              String status,
                            ) {
                              return DropdownMenuItem<
                                  String>(
                                value:
                                    status,

                                child:
                                    Text(
                                  status,
                                ),
                              );
                            },
                          ).toList(),

                          onChanged:
                              (
                            String?
                                value,
                          ) {
                            if (
                              value ==
                              null
                            ) {
                              return;
                            }

                            setState(() {
                              statusFilter =
                                  value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  _filterField(
                    label:
                        'Vendor Name',

                    child:
                        SizedBox(
                      width:
                          180,

                      child:
                          _filterTextField(
                        vendorController,
                        'Vendor name...',
                      ),
                    ),
                  ),

                  _filterField(
                    label:
                        'Date From',

                    child:
                        SizedBox(
                      width:
                          160,

                      child:
                          _filterDateField(
                        dateFrom,
                        (
                          DateTime date,
                        ) {
                          setState(() {
                            dateFrom =
                                date;
                          });
                        },
                      ),
                    ),
                  ),

                  _filterField(
                    label:
                        'Date To',

                    child:
                        SizedBox(
                      width:
                          160,

                      child:
                          _filterDateField(
                        dateTo,
                        (
                          DateTime date,
                        ) {
                          setState(() {
                            dateTo =
                                date;
                          });
                        },
                      ),
                    ),
                  ),

                  GlassButton(
                    onPressed:
                        _loadBills,

                    icon:
                        Icons
                            .filter_alt_outlined,

                    label:
                        'Filter',
                  ),

                  GlassButton(
                    onPressed:
                        _clearFilters,

                    icon:
                        Icons.refresh,

                    label:
                        'Clear',

                    primary:
                        false,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height:
                  20,
            ),

            // ==================================================
            // ERROR
            // ==================================================

            if (
              _errorMessage !=
              null
            ) ...[
              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .all(
                  14,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF4E3E3,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    8,
                  ),
                ),

                child:
                    Row(
                  children: [
                    const Icon(
                      Icons
                          .error_outline,

                      color:
                          Color(
                        0xFFAB2A2A,
                      ),
                    ),

                    const SizedBox(
                      width:
                          10,
                    ),

                    Expanded(
                      child:
                          Text(
                        _errorMessage!,
                      ),
                    ),

                    TextButton(
                      onPressed:
                          _loadBills,

                      child:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                    16,
              ),
            ],

            // ==================================================
            // TABLE
            // ==================================================

            GlassPanel(
              child:
                  SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,

                child:
                    SizedBox(
                  width:
                      1200,

                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Container(
                        width:
                            1200,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              18,

                          vertical:
                              18,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors
                                  .white
                                  .withValues(
                            alpha:
                                0.35,
                          ),

                          borderRadius:
                              const BorderRadius
                                  .vertical(
                            top:
                                Radius
                                    .circular(
                              14,
                            ),
                          ),
                        ),

                        child:
                            const Row(
                          children: [
                            Expanded(
                              flex:
                                  2,

                              child:
                                  _HeaderText(
                                'DATE',
                              ),
                            ),

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _HeaderText(
                                'BILL #',
                              ),
                            ),

                            Expanded(
                              flex:
                                  3,

                              child:
                                  _HeaderText(
                                'VENDOR NAME',
                              ),
                            ),

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _HeaderText(
                                'DUE DATE',
                              ),
                            ),

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _HeaderText(
                                'STATUS',
                              ),
                            ),

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _HeaderText(
                                'AMOUNT DUE',
                              ),
                            ),

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _HeaderText(
                                'TOTAL',
                              ),
                            ),

                            Expanded(
                              flex:
                                  1,

                              child:
                                  _HeaderText(
                                'ACTIONS',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height:
                            1,

                        color:
                            Color(
                          0xFFD9DEE5,
                        ),
                      ),

                      if (
                        _isLoading
                      )
                        const SizedBox(
                          width:
                              1200,

                          height:
                              180,

                          child:
                              Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        )
                      else if (
                        _bills
                            .isEmpty
                      )
                        Container(
                          width:
                              1200,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                18,

                            vertical:
                                35,
                          ),

                          child:
                              const Text(
                            'No bills found. Click "+ New Bill" to add one!',

                            style:
                                TextStyle(
                              fontSize:
                                  16,

                              color:
                                  Color(
                                0xFF42474D,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._bills.map(
                          (
                            BillModel bill,
                          ) {
                            return Column(
                              children: [
                                Container(
                                  width:
                                      1200,

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        18,

                                    vertical:
                                        16,
                                  ),

                                  child:
                                      Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            2,

                                        child:
                                            Text(
                                          _fmt(
                                            bill.billDate,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            2,

                                        child:
                                            Text(
                                          bill.billNumber,
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            3,

                                        child:
                                            Text(
                                          bill.vendorName,

                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            2,

                                        child:
                                            Text(
                                          _fmt(
                                            bill.dueDate,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            2,

                                        child:
                                            Align(
                                          alignment:
                                              Alignment
                                                  .centerLeft,

                                          child:
                                              Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  10,

                                              vertical:
                                                  4,
                                            ),

                                            decoration:
                                                BoxDecoration(
                                              color:
                                                  _statusBg(
                                                bill.status,
                                              ),

                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                20,
                                              ),
                                            ),

                                            child:
                                                Text(
                                              bill.status,

                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    12,

                                                fontWeight:
                                                    FontWeight
                                                        .w600,

                                                color:
                                                    _statusFg(
                                                  bill.status,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            2,

                                        child:
                                            Text(
                                          'INR ${bill.amountDue.toStringAsFixed(2)}',

                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            2,

                                        child:
                                            Text(
                                          'INR ${bill.total.toStringAsFixed(2)}',
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            1,

                                        child:
                                            PopupMenuButton<
                                                String>(
                                          icon:
                                              const Icon(
                                            Icons
                                                .more_vert,
                                          ),

                                          onSelected:
                                              (
                                            String
                                                value,
                                          ) {
                                            if (
                                              value ==
                                              'payment'
                                            ) {
                                              _recordPayment(
                                                bill,
                                              );
                                            }

                                            if (
                                              value ==
                                              'delete'
                                            ) {
                                              _deleteBill(
                                                bill,
                                              );
                                            }
                                          },

                                          itemBuilder:
                                              (_) =>
                                                  [
                                            if (
                                              bill.amountDue >
                                              0
                                            )
                                              const PopupMenuItem<
                                                  String>(
                                                value:
                                                    'payment',

                                                child:
                                                    Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .payments_outlined,

                                                      size:
                                                          19,
                                                    ),

                                                    SizedBox(
                                                      width:
                                                          8,
                                                    ),

                                                    Text(
                                                      'Record Payment',
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            const PopupMenuItem<
                                                String>(
                                              value:
                                                  'delete',

                                              child:
                                                  Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .delete_outline,

                                                    color:
                                                        Color(
                                                      0xFFAB2A2A,
                                                    ),

                                                    size:
                                                        19,
                                                  ),

                                                  SizedBox(
                                                    width:
                                                        8,
                                                  ),

                                                  Text(
                                                    'Delete',

                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Color(
                                                        0xFFAB2A2A,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(
                                  height:
                                      1,

                                  color:
                                      Color(
                                    0xFFEDEFF2,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FILTER FIELD
  // ==========================================================

  Widget _filterField({
    required String label,

    required Widget child,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style:
              const TextStyle(
            fontSize:
                13,

            fontWeight:
                FontWeight.w600,

            color:
                Color(
              0xFF5B5B5B,
            ),
          ),
        ),

        const SizedBox(
          height:
              6,
        ),

        child,
      ],
    );
  }

  // ==========================================================
  // FILTER TEXT
  // ==========================================================

  Widget _filterTextField(
    TextEditingController
        controller,
    String hint,
  ) {
    return TextField(
      controller:
          controller,

      decoration:
          InputDecoration(
        hintText:
            hint,

        filled:
            true,

        fillColor:
            const Color(
          0xFFF8F9FA,
        ),

        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal:
              12,

          vertical:
              12,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            7,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            7,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(
              0xFFD9DEE5,
            ),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            7,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(
              0xFF123456,
            ),

            width:
                2,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FILTER DATE
  // ==========================================================

  Widget _filterDateField(
    DateTime? value,
    ValueChanged<DateTime>
        onPicked,
  ) {
    return GestureDetector(
      onTap:
          () {
        _pickDate(
          value,
          onPicked,
        );
      },

      child:
          Container(
        height:
            46,

        padding:
            const EdgeInsets
                .symmetric(
          horizontal:
              12,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFF8F9FA,
          ),

          borderRadius:
              BorderRadius.circular(
            7,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFD9DEE5,
            ),
          ),
        ),

        child:
            Row(
          children: [
            Expanded(
              child:
                  Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : _fmt(
                        value,
                      ),

                style:
                    TextStyle(
                  color:
                      value ==
                              null
                          ? Colors
                              .grey
                          : Colors
                              .black,

                  fontSize:
                      14,
                ),
              ),
            ),

            const Icon(
              Icons
                  .calendar_today_outlined,

              size:
                  16,

              color:
                  Color(
                0xFF888888,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _HeaderText
    extends StatelessWidget {
  final String text;

  const _HeaderText(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,

      style:
          const TextStyle(
        fontSize:
            13,

        fontWeight:
            FontWeight.bold,

        color:
            Color(
          0xFF5B5B5B,
        ),
      ),
    );
  }
}