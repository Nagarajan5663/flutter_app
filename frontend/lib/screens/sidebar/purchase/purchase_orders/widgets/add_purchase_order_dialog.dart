import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../shared/glass_modal_shell.dart';
import '../../vendors/vendor_model.dart';
import '../../vendors/vendor_repository.dart';
import '../purchase_order_item_model.dart';
import '../purchase_order_model.dart';
import '../purchase_order_repository.dart';

// ============================================================
// CATALOG OPTION
// ============================================================

class _CatalogOption {
  final String sourceType;

  final int id;

  final String name;

  final String sku;

  final String description;

  final double purchasePrice;

  const _CatalogOption({
    required this.sourceType,
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.purchasePrice,
  });
}

// ============================================================
// ITEM ROW
// ============================================================

class _ItemRow {
  _CatalogOption? selectedProduct;

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController qtyController = TextEditingController(
    text: '1',
  );

  final TextEditingController rateController = TextEditingController(
    text: '0.00',
  );

  double get amount {
    final double qty = double.tryParse(
          qtyController.text.trim(),
        ) ??
        0;

    final double rate = double.tryParse(
          rateController.text.trim(),
        ) ??
        0;

    return qty * rate;
  }

  void clear() {
    selectedProduct = null;

    descriptionController.clear();

    qtyController.text = '1';

    rateController.text = '0.00';
  }

  void dispose() {
    descriptionController.dispose();

    qtyController.dispose();

    rateController.dispose();
  }
}

// ============================================================
// DIALOG
// ============================================================

class AddPurchaseOrderDialog extends StatefulWidget {
  const AddPurchaseOrderDialog({
    super.key,
    this.initialVendor,
    this.initialOrder,
    this.isDuplicate = false,
  });

  final VendorModel? initialVendor;
  final PurchaseOrderModel? initialOrder;
  final bool isDuplicate;

  @override
  State<AddPurchaseOrderDialog> createState() => _AddPurchaseOrderDialogState();
}

class _AddPurchaseOrderDialogState extends State<AddPurchaseOrderDialog> {
  static const String _baseUrl = 'http://localhost:3000/api';

  final VendorRepository _vendorRepository = InMemoryVendorRepository();

  final PurchaseOrderRepository _orderRepository =
      InMemoryPurchaseOrderRepository();

  final TextEditingController poNumberController = TextEditingController();

  final TextEditingController referenceNumberController =
      TextEditingController();

  List<VendorModel> _vendors = [];

  List<_CatalogOption> _catalog = [];

  VendorModel? selectedVendor;

  DateTime date = DateTime.now();

  DateTime? deliveryExpectedDate;

  DateTime? dueDate;

  final List<String> paymentTermsOptions = const [
    '100% Advance',
    '50% Advance, 50% on Delivery',
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
  ];

  String paymentTerms = '100% Advance';

  final List<_ItemRow> rows = [
    _ItemRow(),
  ];

  bool _isLoading = true;

  bool _isSaving = false;

  String? _errorText;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final Future<List<VendorModel>> vendorsFuture =
          _vendorRepository.getVendors();

      final Future<List<_CatalogOption>> catalogFuture = _loadCatalog();

      final Future<String>? poNumberFuture =
          widget.initialOrder == null || widget.isDuplicate
              ? _orderRepository.nextPoNumber()
              : null;

      final List<VendorModel> vendors = await vendorsFuture;

      final List<_CatalogOption> catalog = await catalogFuture;

      final String? nextPoNumber = await poNumberFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _vendors = vendors;
        final initialOrder = widget.initialOrder;
        final vendorId = initialOrder?.vendorId ?? widget.initialVendor?.id;
        selectedVendor = vendorId == null
            ? null
            : vendors.any((vendor) => vendor.id == vendorId)
                ? vendors.firstWhere((vendor) => vendor.id == vendorId)
                : null;

        _catalog = catalog;

        poNumberController.text = initialOrder != null && !widget.isDuplicate
            ? initialOrder.poNumber
            : nextPoNumber ?? '';
        if (initialOrder != null) {
          referenceNumberController.text = initialOrder.referenceNumber;
          date = initialOrder.date;
          deliveryExpectedDate = initialOrder.deliveryExpectedDate;
          dueDate = initialOrder.dueDate;
          paymentTerms = initialOrder.paymentTerms;
          for (final row in rows) {
            row.dispose();
          }
          rows.clear();
          for (final item in initialOrder.items) {
            final row = _ItemRow();
            row.selectedProduct = _findCatalogOption(
              item.itemName,
              item.rate,
            );
            row.descriptionController.text = item.description;
            row.qtyController.text = item.qty.toString();
            row.rateController.text = item.rate.toStringAsFixed(2);
            rows.add(row);
          }
          if (rows.isEmpty) rows.add(_ItemRow());
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorText = 'Unable to load purchase order data: $error';
      });
    }
  }

  _CatalogOption? _findCatalogOption(String name, double rate) {
    for (final option in _catalog) {
      if (option.name == name && (option.purchasePrice - rate).abs() < 0.005) {
        return option;
      }
    }
    return null;
  }

  // ==========================================================
  // LOAD ITEMS + PARTS
  // ==========================================================

  Future<List<_CatalogOption>> _loadCatalog() async {
    final Future<http.Response> itemFuture = http.get(
      Uri.parse(
        '$_baseUrl/items',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final Future<http.Response> partFuture = http.get(
      Uri.parse(
        '$_baseUrl/parts',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final http.Response itemResponse = await itemFuture;

    final http.Response partResponse = await partFuture;

    final dynamic itemBody = jsonDecode(
      itemResponse.body,
    );

    final dynamic partBody = jsonDecode(
      partResponse.body,
    );

    if (itemBody is! Map<String, dynamic> ||
        itemResponse.statusCode != 200 ||
        itemBody['success'] != true) {
      throw Exception(
        itemBody is Map
            ? itemBody['message'] ?? 'Failed to load items'
            : 'Failed to load items',
      );
    }

    if (partBody is! Map<String, dynamic> ||
        partResponse.statusCode != 200 ||
        partBody['success'] != true) {
      throw Exception(
        partBody is Map
            ? partBody['message'] ?? 'Failed to load parts'
            : 'Failed to load parts',
      );
    }

    final List<_CatalogOption> result = [];

    // ----------------------------------------------------------
    // ITEMS
    // Purchase Order uses purchase_price.
    // ----------------------------------------------------------

    final List<dynamic> itemData =
        itemBody['data'] is List ? itemBody['data'] : <dynamic>[];

    for (final dynamic raw in itemData) {
      final Map<String, dynamic> item = Map<String, dynamic>.from(
        raw as Map,
      );

      final int id = int.tryParse(
            item['id']?.toString() ?? '',
          ) ??
          0;

      final String name = item['name']?.toString() ?? '';

      if (id <= 0 || name.trim().isEmpty) {
        continue;
      }

      result.add(
        _CatalogOption(
          sourceType: 'Item',
          id: id,
          name: name,
          sku: item['sku']?.toString() ?? '',
          description: item['description']?.toString() ?? '',
          purchasePrice: double.tryParse(
                item['purchase_price']?.toString() ?? '0',
              ) ??
              0,
        ),
      );
    }

    // ----------------------------------------------------------
    // PARTS
    // ----------------------------------------------------------

    final List<dynamic> partData =
        partBody['data'] is List ? partBody['data'] : <dynamic>[];

    for (final dynamic raw in partData) {
      final Map<String, dynamic> part = Map<String, dynamic>.from(
        raw as Map,
      );

      final int id = int.tryParse(
            part['id']?.toString() ?? '',
          ) ??
          0;

      final String name = part['name']?.toString() ?? '';

      if (id <= 0 || name.trim().isEmpty) {
        continue;
      }

      result.add(
        _CatalogOption(
          sourceType: 'Part',
          id: id,
          name: name,
          sku: part['sku']?.toString() ?? '',
          description: part['description']?.toString() ?? '',
          purchasePrice: double.tryParse(
                part['purchase_price']?.toString() ?? '0',
              ) ??
              0,
        ),
      );
    }

    return result;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    poNumberController.dispose();

    referenceNumberController.dispose();

    for (final _ItemRow row in rows) {
      row.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // ROWS
  // ==========================================================

  void _addRow() {
    setState(() {
      rows.add(
        _ItemRow(),
      );
    });
  }

  void _removeRow(
    int index,
  ) {
    if (rows.length == 1) {
      setState(() {
        rows[0].clear();
      });

      return;
    }

    setState(() {
      rows[index].dispose();

      rows.removeAt(
        index,
      );
    });
  }

  // ==========================================================
  // TOTAL
  // ==========================================================

  double get _subTotal {
    return rows.fold(
      0.0,
      (
        double sum,
        _ItemRow row,
      ) {
        return sum + row.amount;
      },
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onPicked(
        picked,
      );
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  void _saveOrder() {
    if (_isSaving) {
      return;
    }

    if (selectedVendor == null) {
      setState(() {
        _errorText = 'Please select a vendor';
      });

      return;
    }

    if (selectedVendor!.id == null || selectedVendor!.id!.trim().isEmpty) {
      setState(() {
        _errorText = 'Selected vendor ID is missing';
      });

      return;
    }

    if (poNumberController.text.trim().isEmpty) {
      setState(() {
        _errorText = 'Please enter a purchase order number';
      });

      return;
    }

    final List<PurchaseOrderItemModel> items = [];

    for (final _ItemRow row in rows) {
      if (row.selectedProduct == null) {
        continue;
      }

      final double qty = double.tryParse(
            row.qtyController.text.trim(),
          ) ??
          0;

      final double rate = double.tryParse(
            row.rateController.text.trim(),
          ) ??
          0;

      if (qty <= 0) {
        setState(() {
          _errorText = 'Quantity must be greater than zero';
        });

        return;
      }

      if (rate < 0) {
        setState(() {
          _errorText = 'Rate cannot be negative';
        });

        return;
      }

      items.add(
        PurchaseOrderItemModel(
          itemName: row.selectedProduct!.name,
          description: row.descriptionController.text.trim(),
          qty: qty,
          rate: rate,
        ),
      );
    }

    if (items.isEmpty) {
      setState(() {
        _errorText = 'Please add at least one Item or Part';
      });

      return;
    }

    if (deliveryExpectedDate != null &&
        deliveryExpectedDate!.isBefore(
          DateTime(
            date.year,
            date.month,
            date.day,
          ),
        )) {
      setState(() {
        _errorText = 'Delivery expected date cannot be before PO date';
      });

      return;
    }

    setState(() {
      _isSaving = true;

      _errorText = null;
    });

    final PurchaseOrderModel order = PurchaseOrderModel(
      id: widget.isDuplicate ? null : widget.initialOrder?.id,
      poNumber: poNumberController.text.trim(),
      vendorId: selectedVendor!.id!,
      vendorName: selectedVendor!.vendorName,
      date: date,
      deliveryExpectedDate: deliveryExpectedDate,
      paymentTerms: paymentTerms,
      dueDate: dueDate,
      referenceNumber: referenceNumberController.text.trim(),
      items: items,
      status:
          widget.isDuplicate ? 'Draft' : widget.initialOrder?.status ?? 'Draft',
    );

    Navigator.pop(
      context,
      order,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassModalShell(
      maxWidth: 900,
      maxHeight: 850,
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(
                60,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                34,
                30,
                34,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // HEADER
                  // ============================================

                  GlassDialogHeader(
                    title: widget.initialOrder == null || widget.isDuplicate
                        ? 'New Purchase Order'
                        : 'Edit Purchase Order',
                    icon: Icons.shopping_cart_outlined,
                    onClose: () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ============================================
                  // ERROR
                  // ============================================

                  if (_errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF4E3E3,
                        ),
                        borderRadius: BorderRadius.circular(
                          7,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Color(
                                  0xFFAB2A2A,
                                ),
                              ),
                            ),
                          ),
                          if (_catalog.isEmpty || _vendors.isEmpty)
                            TextButton(
                              onPressed: _init,
                              child: const Text(
                                'Retry',
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],

                  // ============================================
                  // VENDOR + PO NUMBER
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          label: 'Vendor Name *',
                          child: DropdownSearch<VendorModel>(
                            items: (
                              filter,
                              infiniteScrollProps,
                            ) {
                              final String query = filter.trim().toLowerCase();

                              if (query.isEmpty) {
                                return _vendors;
                              }

                              return _vendors.where(
                                (
                                  VendorModel vendor,
                                ) {
                                  return vendor.vendorName
                                          .toLowerCase()
                                          .contains(
                                            query,
                                          ) ||
                                      vendor.companyName.toLowerCase().contains(
                                            query,
                                          ) ||
                                      vendor.email.toLowerCase().contains(
                                            query,
                                          );
                                },
                              ).toList();
                            },
                            itemAsString: (
                              VendorModel vendor,
                            ) {
                              if (vendor.companyName.trim().isEmpty) {
                                return vendor.vendorName;
                              }

                              return '${vendor.vendorName} - ${vendor.companyName}';
                            },
                            compareFn: (
                              VendorModel a,
                              VendorModel b,
                            ) {
                              return a.id == b.id;
                            },
                            selectedItem: selectedVendor,
                            onChanged: (
                              VendorModel? vendor,
                            ) {
                              setState(() {
                                selectedVendor = vendor;
                              });
                            },
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                            ),
                            decoratorProps: DropDownDecoratorProps(
                              decoration: _fieldDecoration(
                                hint: 'Select or type to search...',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _labeledField(
                          label: 'Purchase Order # *',
                          child: _textField(
                            controller: poNumberController,
                            readOnly: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ============================================
                  // DATE + DELIVERY
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          label: 'Date *',
                          child: _dateField(
                            value: date,
                            onTap: () {
                              _pickDate(
                                initial: date,
                                onPicked: (
                                  DateTime value,
                                ) {
                                  setState(() {
                                    date = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _labeledField(
                          label: 'Delivery Expected Date',
                          child: _dateField(
                            value: deliveryExpectedDate,
                            onTap: () {
                              _pickDate(
                                initial: deliveryExpectedDate ?? date,
                                onPicked: (
                                  DateTime value,
                                ) {
                                  setState(() {
                                    deliveryExpectedDate = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ============================================
                  // PAYMENT + DUE DATE
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          label: 'Payment Terms',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF8F9FA,
                              ),
                              borderRadius: BorderRadius.circular(
                                7,
                              ),
                              border: Border.all(
                                color: const Color(
                                  0xFFD9DEE5,
                                ),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: paymentTerms,
                                isExpanded: true,
                                items: paymentTermsOptions.map(
                                  (
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: (
                                  String? value,
                                ) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    paymentTerms = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _labeledField(
                          label: 'Due Date',
                          child: _dateField(
                            value: dueDate,
                            onTap: () {
                              _pickDate(
                                initial: dueDate ?? date,
                                onPicked: (
                                  DateTime value,
                                ) {
                                  setState(() {
                                    dueDate = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ============================================
                  // REFERENCE
                  // ============================================

                  _labeledField(
                    label: 'Reference # (optional)',
                    child: _textField(
                      controller: referenceNumberController,
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ============================================
                  // ITEMS
                  // ============================================

                  const Text(
                    'Item Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(
                        0xFF3D4147,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _SmallHeader(
                          'ITEM / DESCRIPTION',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _SmallHeader(
                          'QTY',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _SmallHeader(
                          'RATE',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _SmallHeader(
                          'AMOUNT',
                        ),
                      ),
                      SizedBox(
                        width: 36,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  ...rows.asMap().entries.map(
                    (
                      MapEntry<int, _ItemRow> entry,
                    ) {
                      final int index = entry.key;

                      final _ItemRow row = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  // ============================
                                  // ITEM / PART SEARCH
                                  // ============================

                                  DropdownSearch<_CatalogOption>(
                                    items: (
                                      filter,
                                      infiniteScrollProps,
                                    ) {
                                      final String query =
                                          filter.trim().toLowerCase();

                                      if (query.isEmpty) {
                                        return _catalog;
                                      }

                                      return _catalog.where(
                                        (
                                          _CatalogOption product,
                                        ) {
                                          return product.name
                                                  .toLowerCase()
                                                  .contains(
                                                    query,
                                                  ) ||
                                              product.sku
                                                  .toLowerCase()
                                                  .contains(
                                                    query,
                                                  ) ||
                                              product.sourceType
                                                  .toLowerCase()
                                                  .contains(
                                                    query,
                                                  );
                                        },
                                      ).toList();
                                    },
                                    itemAsString: (
                                      _CatalogOption product,
                                    ) {
                                      final String sku = product.sku.isEmpty
                                          ? ''
                                          : ' • ${product.sku}';

                                      return '${product.name} [${product.sourceType}]$sku';
                                    },
                                    compareFn: (
                                      _CatalogOption a,
                                      _CatalogOption b,
                                    ) {
                                      return a.sourceType == b.sourceType &&
                                          a.id == b.id;
                                    },
                                    selectedItem: row.selectedProduct,
                                    onChanged: (
                                      _CatalogOption? product,
                                    ) {
                                      setState(() {
                                        row.selectedProduct = product;

                                        if (product == null) {
                                          row.descriptionController.clear();

                                          row.rateController.text = '0.00';

                                          return;
                                        }

                                        row.descriptionController.text =
                                            product.description;

                                        row.rateController.text = product
                                            .purchasePrice
                                            .toStringAsFixed(
                                          2,
                                        );
                                      });
                                    },
                                    popupProps: const PopupProps.menu(
                                      showSearchBox: true,
                                    ),
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: _fieldDecoration(
                                        hint: 'Select Item or Part...',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  _textField(
                                    controller: row.descriptionController,
                                    hint: 'Description',
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.qtyController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.rateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: GlassSurface.fill(
                                    emphasized: true,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    7,
                                  ),
                                ),
                                child: Text(
                                  'INR ${row.amount.toStringAsFixed(2)}',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: IconButton(
                                onPressed: () {
                                  _removeRow(
                                    index,
                                  );
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(
                                    0xFFAB2A2A,
                                  ),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  TextButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    label: const Text(
                      'Add Row',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(
                        0xFF2E7DD1,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ============================================
                  // TOTAL
                  // ============================================

                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sub Total',
                              ),
                              Text(
                                'INR ${_subTotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'INR ${_subTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                    0xFF123456,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ============================================
                  // BUTTONS
                  // ============================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                );
                              },
                        icon: Icons.close,
                        label: 'Cancel',
                        primary: false,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      GlassButton(
                        onPressed: _isSaving ? null : _saveOrder,
                        icon: Icons.save,
                        label:
                            widget.initialOrder != null && !widget.isDuplicate
                                ? 'Update Purchase Order'
                                : 'Save Purchase Order',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // LABEL
  // ==========================================================

  Widget _labeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(
              0xFF3D4147,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        child,
      ],
    );
  }

  // ==========================================================
  // DECORATION
  // ==========================================================

  InputDecoration _fieldDecoration({
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: GlassSurface.fill(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: BorderSide(
          color: GlassSurface.border(),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: BorderSide(
          color: GlassSurface.border(
            focused: true,
          ),
          width: 2,
        ),
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: _fieldDecoration(
        hint: hint,
      ),
    );
  }

  // ==========================================================
  // DATE FIELD
  // ==========================================================

  Widget _dateField({
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: GlassSurface.fill(),
          borderRadius: BorderRadius.circular(
            7,
          ),
          border: Border.all(
            color: GlassSurface.border(),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(
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
// SMALL HEADER
// ============================================================

class _SmallHeader extends StatelessWidget {
  final String text;

  const _SmallHeader(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(
          0xFF5B5B5B,
        ),
      ),
    );
  }
}
